# Datos y frescura

> [← Volver al README](../README.md)

## De dónde salen los precios

Los precios son los oficiales que las gasolineras comunican al **Ministerio para la
Transición Ecológica y el Reto Demográfico**. **Gasolina hoy** los publica en
`https://api.preciosgasolina.es/v1`, una API pública, sin clave y de solo lectura, que
TolochaFuel consulta directamente desde el dispositivo. No hay backend propio ni copia
intermedia de los datos.

La app no inventa ni estima precios: muestra los importes publicados para cada estación y
producto. Si una estación no tiene precios disponibles, la tarjeta lo indica.

## Cuándo se actualizan

La fuente se actualiza **dos veces al día**, en torno a las **8:00 y las 20:00**. Los
precios **no son en tiempo real**.

La respuesta de la API incluye metadatos de frescura que la app usa para no dar una
imagen engañosa:

| Campo | Uso en la app |
| --- | --- |
| `meta.last_updated` | Fecha de la última actualización de los datos |
| `meta.next_update` | Próxima actualización prevista; la caché caduca en ese momento |
| `meta.data_age_seconds` | Antigüedad de los datos, mostrada en el pie de las listas |
| `meta.stale` | Si es `true`, la app avisa de que pueden ser datos de la actualización anterior |
| `meta.attribution` | Atribución que se muestra en «Acerca de» y en el pie |
| `meta.web_url` | Enlace a la fuente, cuando la API lo proporciona |

El pie de frescura aparece en Cercanas, Favoritas, Más económicas y Buscar. La app no
hace *polling*: cachea las respuestas en memoria y las renueva cuando la API indica una
próxima actualización o cuando el usuario reintenta.

## Avisos de cambio de precio

Los avisos por favorito usan los mismos metadatos: al activar la campana se guarda una
base de precios; al abrir o reanudar la app se comprueba si `meta.next_update` ya pasó y
se lee `meta.last_updated` con una sola ficha. Solo si cambió se consultan las fichas de
las favoritas con aviso, y el aviso muestra la fecha de los datos y el aviso de `stale`
cuando corresponde. La primera comprobación no notifica: solo crea la base.

En Android, la comprobación de fondo usa `meta.next_update` para programar el siguiente
intento con WorkManager, con una restricción de red y sin alarmas exactas. Tras cada
comprobación se reprograma con la fecha nueva; si no hay fecha, se usa un respaldo de 12
horas. Doze o la batería pueden retrasarla. No se hace *polling* ni se consultan estaciones
sin campana.

## Endpoints que usa la app

Todas las peticiones van a `https://api.preciosgasolina.es` y reciben un objeto con
`data` y `meta`.

| Endpoint | Parámetros | Para qué |
| --- | --- | --- |
| `GET /v1/stations/nearby` | `lat`, `lng`, `radius_km`, `sort=distance`, `limit` | Gasolineras cercanas, ordenadas por distancia |
| `GET /v1/stations/cheapest` | `lat`, `lng`, `radius_km`, `fuel`, `limit` | Estaciones más económicas dentro del radio |
| `GET /v1/stations/cheapest` | `level`, `code`, `fuel`, `limit` | Más económicas de un municipio o provincia elegido en Buscar |
| `GET /v1/stations/{id}` | — | Detalle y precios por producto de una estación |
| `GET /v1/stations/{id}/history` | `days` | Serie histórica de precios por carburante |
| `GET /v1/search` | `q`, `limit=10` | Municipios y provincias para la búsqueda manual |

Campos que la app lee de `data`:

- `stations[]`: `id`, `name`, `brand.name`, `address`, `municipality.name`, `lat`, `lng`,
  `web_url`, `price`, `price_updated_at`, `distance_km`, `is_24h`, `hours`.
- `fuels[]` y `products[]`: `fuel` (o `product`/`id`), `label` (o `name`), `unit`,
  `price`.
- `series[]`: `fuel` y `points[]` con `date` y `price`.
- `results[]` de `/v1/search`: `name`, `level`, `code`, `detail`.
- `center` y `area` para completar distancias y el nombre del territorio.

No se usan endpoints ni campos fuera de los anteriores. Para el detalle de la API pública,
consulta su documentación oficial en `api.preciosgasolina.es`.

## Límites de la API

La app respeta los límites publicados:

- **120 peticiones por minuto y por IP**; **30 por minuto** en consultas pesadas.
- `limit` máximo de **50** estaciones.
- `radius_km` máximo de **50 km**; el radio configurable de la app va de 10 a 50 km.
- Histórico máximo de **90 días**.

Por eso las listas cargan como mucho 20 estaciones y las fichas se piden en lotes
pequeños, en lugar de lanzar una petición por estación a la vez. Los avisos usan el mismo
criterio: concurrencia 4, una sola petición cuando no hay datos nuevos y ninguna cuando no
hay campanas activas. Si la API responde con error o se supera el límite, la app muestra
un mensaje en español y ofrece reintentar.

## Atribución y licencia

Los datos se reutilizan bajo **CC BY 4.0**. La atribución obligatoria es:

> Gasolina hoy (preciosgasolina.es), con datos del Ministerio para la Transición
> Ecológica y el Reto Demográfico

Aparece en **Configuración → Acerca de…**. La licencia del código (MIT) es independiente:
consulta [licencia](licencia.md).
