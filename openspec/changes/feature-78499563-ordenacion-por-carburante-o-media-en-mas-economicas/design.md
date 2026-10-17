# Design

## Context

Hoy `MasEconomicasController` llama a `CercanasRepositorio.masEconomicas`, que consulta
`/v1/stations/cheapest` con `fuel=gasoline_95` fijo y descarga las fichas
(`/v1/stations/{id}`) en lotes de 6 con caché por estación y TTL. La pantalla muestra el
subtítulo fijo «Orden por Gasolina 95». Ver `proposal.md` - Why.

Datos verificados de la API (`https://api.preciosgasolina.es/v1/openapi.json`):
`/v1/stations/cheapest` admite `fuel` con el enum de seis carburantes (`gasoline_95`,
`gasoline_98`, `diesel`, `diesel_premium`, `lpg`, `cng`) y devuelve el precio de ese
carburante por estación; **no existe** orden por media ni un endpoint de precios por
estación en bloque, así que la media solo puede calcularse con las fichas. `/v1/stations/nearby`
devuelve `distance_km` y admite `sort=distance`, `limit` ≤ 50. Las fichas mezclan
`fuels` (los seis carburantes) y `products` (otros productos como AdBlue, en €/L o
€/kg según el caso; el GLP puede ir en €/L y el GNC en €/kg). Los ajustes se guardan en
`shared_preferences` con claves `config.*` (`ConfiguracionRepositorio`) y
`ConfiguracionController` los aplica y notifica.

## Goals / Non-Goals

**Goals:**

- Selector con los seis carburantes y «Media de carburantes», persistido y por defecto
  Gasolina 95.
- Con carburante: reutilizar `/v1/stations/cheapest` con `fuel` (una petición, como hoy).
- Con media: calcular €/L por estación con las fichas ya descargadas y hacer el ranking
  en la app sin peticiones nuevas.
- Caché en memoria por criterio y comportamiento de estados (carga, error, vacío)
  existente.

**Non-Goals:**

- Cercanas (sigue por distancia), Buscar y Favoritos.
- Orden por media en servidor o caché en disco.
- Configurar qué carburantes entran en la media o ponderarla por distancia.
- Mostrar estaciones sin media computable.

## Decisions

- **Modelo del criterio en `lib/core/models/`**: se amplía `Carburante` a los seis
  carburantes de la API con etiquetas en español y se añade `CriterioEconomicas` (los
  seis carburantes + `media`, con `clave`/`desdeClave` para persistir y `etiqueta` para
  la UI). Va en `core` porque lo comparten `configuracion` (ajuste) y `cercanas`
  (consulta y pantalla); alternativa descartada: dejarlo en `features/cercanas` y que
  `configuracion` importe de otra feature.
  Palabra clave `media` para la media; cualquier clave desconocida cae a Gasolina 95.

- **Consulta por carburante**: `PreciosGasolinaApi.masBaratasCerca` gana el parámetro
  `fuel` (por defecto `Carburante.gasolina95`) y el repositorio lo pasa desde el
  criterio. Es el mismo camino que hoy, sin cambios de forma en la respuesta.

- **Media calculada en la app**: nuevo `lib/features/cercanas/data/orden_economicas.dart`
  con el cálculo de la media (solo productos cuyo id sea uno de los seis carburantes, con
  `precio` no nulo y unidad `L`; media aritmética) y el orden ascendente. Con
  `criterio == media`, el repositorio pide `/v1/stations/nearby` con
  `sort=distance` y `limit = 50` (máximo de la API) como conjunto de candidatas, reutiliza
  `_conFichas` (lotes de 6, caché por ficha con TTL), descarta estaciones sin media y
  recorta a `limiteListado` (20). Alternativas consideradas: seis llamadas a `cheapest`
  (una por carburante) para unir candidatas → más peticiones y sesgo por carburante; no
  hay endpoint de media (ver Context).

- **Claves de caché por criterio**: `baratas:<fuel>:<lat>,<lng>,<radio>` y
  `media:<lat>,<lng>,<radio>` en `_cacheListados` (el TTL sigue siendo
  `meta.proximaActualizacion`). Volver a un criterio ya consultado no repite peticiones.

- **Estado y recarga**: `MasEconomicasController` deriva `criterio` de
  `ConfiguracionController` (o de un valor local si no hay controlador, como en los
  tests), expone `cambiarCriterio()` (persiste y recarga) y su listener recarga cuando
  cambian el radio **o** el criterio respecto a los últimos usados (`_radioUsado`,
  `_criterioUsado`); los cambios de tema o pantalla inicial no recargan. `_cargar` guarda
  ambos valores junto al resultado. Una sola recarga por cambio: el listener compara
  contra el último criterio usado, no contra el deseado.

- **Ajuste persistido**: `Ajustes.criterioEconomicas` (por defecto Gasolina 95) con clave
  `config.criterioEconomicas`; lectura tolerante (valor inválido → por defecto) y
  `ConfiguracionController.cambiarCriterioEconomicas`. Sin migración: la ausencia de la
  clave mantiene el comportamiento actual.

- **Interfaz**: en la cabecera de Más económicas, `DropdownButton<CriterioEconomicas>`
  con la etiqueta «Ordenar por» (mismo patrón que el selector de pantalla inicial en
  Configuración) que sustituye al subtítulo fijo; muestra siempre el criterio activo. El
  estado vacío del criterio de carburante nombra el criterio («No hay estaciones con
  GNC…»). Widgets sin lógica: llaman a `controller.cambiarCriterio`. Colores y
  tipografía solo del tema. Tarjetas y pie de frescura no cambian; la atribución sigue
  en Configuración → Acerca de.

## Risks / Trade-offs

- [En radios densos puede haber más de 50 estaciones: el ranking por media usa las 50
  más cercanas y podría omitir una estación barata lejana] → límite de la API asumido y
  documentado en la spec; ampliar el radio es la salida; sin peticiones de paginación
  (la API no ofrece offset).
- [El primer cálculo por media descarga hasta 50 fichas] → lotes de 6 (ya existente),
  caché por estación con TTL y respuesta cacheada por criterio; queda margen frente a
  las 120 peticiones/min.
- [El GLP en €/L entra en la media y el GNC en €/kg no] → decisión del usuario de no
  mezclar unidades; se documenta en la spec y las etiquetas de la UI no prometen
  paridad entre estaciones con surtidos distintos.
- [Guardar el criterio falla en el dispositivo] → se mantiene el aviso genérico de
  ajustes y la sesión continúa con el criterio elegido.
- [Doble recarga al cambiar criterio] → el listener de configuración compara con el
  último criterio usado y el cambio local notifica una sola vez.
