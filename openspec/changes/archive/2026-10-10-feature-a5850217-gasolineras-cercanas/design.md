# Design

## Context

App Flutter 3.47 (Dart estricto) con estructura `lib/app`, `lib/core` y
`lib/features/<feature>`. La fuente es la API pública `api.preciosgasolina.es`
(sin clave). El listado `/v1/stations/nearby` solo trae el precio de un carburante, pero
la ficha `/v1/stations/{id}` trae `fuels` (etiqueta, unidad y precio) y `products`:
mostrar todos los productos por estación implica una petición por estación (N+1
controlado). La identidad visual (emblema Tolocha, paleta pine/ochre/moss e Inter) viene
de `izquierdojl/tolocharadio`. Ver `proposal.md` para la motivación.

## Goals / Non-Goals

**Goals:**

- Lista de gasolineras cercanas ordenada por distancia con **todos los productos y
  precios** de cada estación (sin selector de carburante).
- Cabecera con el emblema Tolocha y la marca «TolochaFuel» con la tipografía de marca.
- Ubicación con permiso bajo demanda y fallback manual (escritorio/denegación).
- Caché en memoria de listado y fichas, alineada con la frescura real de la API.

**Non-Goals:**

- Favoritos y navegación externa (tienen sus propios changes).
- Filtros (marca, 24h, GLP/GNC), mapa embebido e histórico de precios.
- Persistencia en disco de resultados de la API.

## Decisions

- **`http` en vez de `dio`**: una sola API sencilla (GET con parámetros); `http` es el
  paquete oficial y suficiente.
- **`provider` para el estado**: un `ChangeNotifier` (`CercanasController`) expone
  `estado` (carga/datos/error/vacío) y las acciones `cargar`, `reintentar` y la navegación
  del modo manual. Sin selector de carburante: cada tarjeta muestra todos los productos.
- **Cliente API único** en `lib/core/api`: `PreciosGasolinaApi` con `cercanas` (nearby
  **sin** `fuel`, con `sort=distance`), `masBaratas` (ranking por Gasolina 95),
  `buscarLugar` y `detalle(id)` (ficha con `fuels` + `products`). Deserializa el sobre
  `{data, meta}` y convierte errores RFC 9457 (`application/problem+json`) en
  `ApiException` con mensaje en español.
- **Modelos inmutables** en `lib/core/models`: `Gasolinera` (id, rótulo, dirección,
  municipio, coordenadas, distancia, `productos: List<ProductoPrecio>`), `ProductoPrecio`
  (idApi, etiqueta, unidad, precio) y `DetalleEstacion` (productos + `proximaActualizacion`).
  Parseo tolerante: precios como texto con coma decimal → normalizar a `double`.
- **Fichas N+1 controlado**: `limit` por defecto 20 para el listado; las fichas se piden
  en paralelo con concurrencia 6 y se cachean por id con vigencia hasta
  `meta.next_update`. Si una ficha falla, la estación se muestra igualmente sin productos
  («Precios no disponibles») sin tumbar la lista. Peor caso por carga: 21 peticiones
  (límite de la API: 120/min).
- **Distancia**: se usa la devuelta por la API; si falta, cálculo Haversine local
  (`data.center`). La lista se ordena siempre por distancia.
- **Caché en memoria**: claves `(lat redondeada, lng, radio)` y `(nivel, código)`, más la
  caché de fichas por id; sin polling.
- **Ubicación**: `geolocator` con timeout defensivo en la comprobación del servicio; en
  escritorio o denegación, modo manual: búsqueda por municipio/provincia (`/v1/search`,
  que devuelve `level`+`code` sin coordenadas) y `/v1/stations/cheapest?level=…&code=…`.
  La API exige un carburante para ordenar el ranking → se usa Gasolina 95 y la pantalla
  lo indica en un subtítulo («Orden por Gasolina 95»).
- **Identidad Tolocha**: emblema SVG propio en el estilo de `tolocharadio` (badge oscuro
  con degradado pine, sol ocre y sierra) pero con un **surtidor de carburante** como
  motivo central para diferenciarlo del de la radio, renderizado con `flutter_svg`;
  wordmark «Tolocha» + «Fuel» (color de acento) con `Text.rich`; fuente **Inter 4.1**
  (TTF estáticas 400/500/600/700) empaquetada en `assets/fonts` y aplicada desde
  `lib/app/theme`.

## Risks / Trade-offs

- **N+1 de fichas**: mitigado con límite 20, concurrencia 6 y caché; si la API cambia su
  clasificación de peticiones "pesadas", habría que revisar el límite.
- **Emblema oscuro también en tema claro**: el badge oscuro es parte de la marca y
  funciona en ambos; parametrizar por tema sería un change futuro.
- **Peso del bundle**: Inter añade ~1,7 MB (aceptable para una app móvil).
- **Dependencia de una API de terceros**: `meta.stale` se avisa en la UI; los errores
  tienen reintento.
