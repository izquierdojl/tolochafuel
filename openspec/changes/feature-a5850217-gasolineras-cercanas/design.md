# Design

## Context

App Flutter 3.47 (Dart estricto) con estructura `lib/app`, `lib/core` y
`lib/features/<feature>`. La fuente es la API pública `api.preciosgasolina.es`
(sin clave): 120 req/min por IP (30/min en consultas pesadas), `limit` ≤ 50,
radio ≤ 50 km, actualización 2 veces al día. Android es la plataforma principal;
Windows debe funcionar con fallback manual de ubicación. Ver `proposal.md` para
la motivación.

## Goals / Non-Goals

**Goals:**

- Lista de gasolineras cercanas ordenada por distancia con precio del carburante.
- Ubicación con permiso bajo demanda y fallback manual (escritorio/denegación).
- Caché en memoria alineada con la frescura real de la API, sin polling.
- Atribución y frescura visibles desde la primera versión.

**Non-Goals:**

- Favoritos y navegación externa (tienen sus propios changes).
- Filtros avanzados, mapa embebido e histórico de precios.
- Persistencia en disco de resultados de la API.

## Decisions

- **`http` en vez de `dio`**: una sola API sencilla (GET con parámetros); `http` es el
  paquete oficial y suficiente. Alternativa descartada: `dio` por peso innecesario.
- **`provider` para el estado**: un `ChangeNotifier` (`CercanasController`) expone
  `estado` (carga/datos/error/vacío) y las acciones `cargar`, `reintentar` y
  `cambiarCarburante`. Alternativa descartada: Riverpod/Bloc, sobredimensionados.
- **Cliente API único** en `lib/core/api`: `PreciosGasolinaApi` con `nearby(lat, lng,
  radioKm, carburante, limite)` y `buscarLugar(consulta)`. Deserializa el sobre
  `{data, meta}` y convierte errores RFC 9457 (`application/problem+json`) en
  `ApiException` con mensaje en español.
- **Modelos inmutables** en `lib/core/models`: `Gasolinera` (id, rótulo, dirección,
  municipio, coordenadas, `precios: Map<Carburante, double?>`) y `MetaDatos`
  (`lastUpdated`, `dataAgeSeconds`, `stale`, `attribution`). Parseo tolerante: la API
  puede devolver precios como texto con coma decimal → normalizar a `double`.
- **Distancia**: se usa la distancia devuelta por la API cuando exista; si no, cálculo
  Haversine en `lib/core/utilidades`. La lista se ordena siempre por esa distancia.
- **Radio por defecto 5 km** (`radius_km=5`, `limit=50`), ampliable desde el estado vacío.
- **Caché en memoria** con clave `(lat redondeada a 3 decimales, lng, radio, carburante)`
  y TTL hasta `meta.next_update`; el reingreso a la pantalla reutiliza la caché.
- **Ubicación**: `geolocator` con comprobación de servicio habilitado y permiso
  (`checkPermission`/`requestPermission`). En escritorio o denegación, la pantalla pasa a
  modo manual: búsqueda por municipio (`/v1/search`) y consulta por sus coordenadas.

## Risks / Trade-offs

- **Dependencia de una API de terceros**: si responde `meta.stale`, se avisa en la UI;
  si falla, el estado de error con reintento evita bloqueos.
- **Precisión de distancias**: la distancia devuelta por la API puede diferir ligeramente
  del cálculo local; se prioriza la de la API por coherencia con el servidor.
- **Geolocalización en Windows**: dependiente del servicio del sistema; por eso el
  fallback manual es de primera clase, no un caso excepcional.
