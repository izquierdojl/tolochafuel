# Design

## Context

La app es una pantalla única (`CercanasPantalla`) con `CercanasController` (provider),
un repositorio con caché en memoria y un cliente API; la búsqueda manual por
municipio/provincia solo aparece como fallback dentro de esa pantalla y no hay ajustes.
Ver `proposal.md` para la motivación. Restricciones que condicionan el diseño:

- API pública: radio ≤ 50 km y `limit` ≤ 50 por petición; los precios se actualizan dos
  veces al día (caché, sin asumir tiempo real). `/v1/stations/nearby` admite
  `sort=distance|price` y `/v1/stations/cheapest` admite consultas por punto
  (`lat`+`lng`+`radius_km`) o por territorio (`level`+`code`), con `fuel` opcional.
- `shared_preferences` aún no está en `pubspec.yaml` (lo introducirá también el change
  `feature-de2139cb-favoritos`).
- La capacidad Favoritas la aporta ese mismo change, que hoy planea una barra inferior;
  este diseño la integra como una sección del menú.
- Sin router ni dependencias nuevas: se mantiene la navegación con los widgets de
  Material y `provider`.

## Goals / Non-Goals

**Goals:**

- Un shell de navegación con menú lateral que conserve el estado de cada sección durante
  la sesión y no dispare peticiones hasta que una sección se visita.
- Preferencias (tema, radio, pantalla inicial) aplicadas al instante y persistidas.
- Reutilizar al máximo el repositorio, los controladores, la tarjeta y los widgets de
  estados existentes en Cercanas/Buscar/Más económicas.

**Non-Goals:**

- Enrutador declarativo, deep links o múltiples `Navigator`.
- Sincronizar preferencias o favoritos entre dispositivos.
- Agregar varias consultas para radios > 50 km.
- Cambiar la paleta, la tipografía o la estructura del cliente API.

## Decisions

- **Shell con `NavigationDrawer` + `IndexedStack` perezoso.** `lib/app/shell/` alberga
  `ShellPantalla` (Scaffold, AppBar con la cabecera Tolocha y el botón de menú) y
  `MenuLateral` (Drawer Material 3 con las cinco secciones y la activa resaltada). Las
  secciones se montan en un `IndexedStack` con marcadores para las no visitadas: el
  estado sobrevive a los cambios de sección sin repetir peticiones, pero ninguna sección
  consulta la API hasta abrirse. Alternativas descartadas: `Navigator` con rutas (pierde
  estado salvo reconstrucción manual), `go_router` (fuera de alcance).
- **Sección inicial y estado del shell**: el índice inicial sale de
  `ConfiguracionController.pantallaInicial`; cambiarlo en Configuración no mueve la
  sección actual, solo el arranque siguiente (evita saltos inesperados).
- **Preferencias con `ConfiguracionController` (provider)** en
  `lib/features/configuracion/data/` y `ui/`: repositorio sobre `shared_preferences`
  (claves `tema`, `radioKm`, `pantallaInicial`) cargado en `main()` antes de `runApp`
  (lectura local rápida); si falla, valores por defecto —tema oscuro, radio 25 km,
  pantalla Cercanas— y aviso en español. `MaterialApp.themeMode` se alimenta del
  controlador, por lo que el cambio de tema es inmediato. Alternativa descartada: cargar
  de forma asíncrona tras el primer frame (parpadeo de tema).
- **Radio configurable 10–50 km, por defecto 25 km**: ligado a los controladores de
  Cercanas y Más económicas. La clave de caché del repositorio ya incluye el radio, así
  que al cambiarlo las respuestas anteriores no se reutilizan; el controlador recarga si
  su último resultado usó otro radio. El máximo se justifica en la UI («máximo de la
  API»): 50 km por petición es límite duro de `api.preciosgasolina.es`.
- **Más económicas** usa `/v1/stations/cheapest` con `lat`, `lng`, `radius_km` y
  `fuel=gasoline_95` (mismo carburante de referencia que el ranking territorial actual,
  indicado en pantalla) y `limit` 20, como Cercanas. La respuesta ya incluye
  `distance_km`, así que la tarjeta reutilizada muestra distancia y precio sin lógica
  extra. Alternativa descartada: `/v1/stations/nearby?sort=price` (mismo resultado, pero
  separar «cercanas» y «más baratas» en dos métodos del repositorio refleja mejor la
  semántica de la API).
- **Buscar como sección propia**: `BuscarController` + pantalla reutilizan
  `buscarLugar` (`/v1/search`) y `masBaratas` (`/v1/stations/cheapest` por territorio)
  del repositorio común; desaparece el modo manual embebido en Cercanas y el estado
  vacío/aviso de Cercanas enlaza con esta sección.
- **Una sola feature de listados**: las pantallas de Cercanas, Buscar y Más económicas
  viven en `lib/features/cercanas/` (ui + su repositorio compartido) porque comparten
  datos, caché, tarjeta y estados; dividirlas en features obligaría a duplicar el
  repositorio o a importar entre features. `CercanasRepositorio` se amplía con
  `masEconomicas(...)` y se documenta como repositorio de listados.
- **Sin lógica de negocio en widgets**: cada sección tiene su controlador (`provider`);
  el shell solo compone AppBar, Drawer e `IndexedStack`. Colores y tipografía salen del
  tema (`lib/app/theme`) como hasta ahora.
- **Errores**: se mantiene el manejo actual de `ApiException` (RFC 9457) con mensajes en
  español y reintento en los estados de cada sección; Buscar y Más económicas reutilizan
  `estados_cercanas.dart`.
- **Atribución solo en «Acerca de»** (decisión del usuario durante la aplicación): se
  retira `PieAtribucion` de Cercanas, Buscar, Más económicas y Favoritos; la atribución y
  la explicación de la frescura quedan en Configuración → Acerca de, y AGENTS.md se
  actualiza en consecuencia. Sin número de versión dinámico: `package_info` sería una
  dependencia nueva y queda fuera (decisión registrada en el proposal).
- **Integración de Favoritas**: el shell importa la pantalla del change
  `feature-de2139cb-favoritos`. Prerrequisito: aplicar (o actualizar primero) ese change
  para que su pantalla exista y su tarea de barra inferior pase a ser el destino del
  menú.

## Risks / Trade-offs

- **Dependencia del change de favoritos** → coordinar el orden de aplicación; este change
  no se implementa hasta que `favoritos` esté aplicado o su plan actualizado.
- **Cambio de radio con resultados en memoria** → la clave de caché incluye el radio y el
  controlador detecta el desajuste y recarga; no se muestran datos de otro radio.
- **Más secciones = más peticiones** → montaje perezoso por sección y caché en memoria
  con TTL hasta la siguiente actualización de la fuente; nunca polling.
- **50 km puede quedarse corto en zonas despobladas** → la UI explica el límite de la
  API; la agregación de consultas queda como change futuro si el usuario la pide.
- **`IndexedStack` retiene las secciones visitadas** → coste de memoria bajo (listas de
  ≤ 20 elementos) y evita repetir peticiones; aceptado.
- **Fallo de `shared_preferences`** → arranque con valores por defecto y aviso; nunca
  bloquea la app.
