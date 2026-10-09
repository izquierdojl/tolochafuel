# Proposal

## Why

TolochaFuel nace para consultar de un vistazo los precios de los carburantes de las
gasolineras más cercanas, ordenadas por distancia, sin abrir webs del Ministerio ni
comparadores. Es la capacidad fundacional sobre la que se apoyan navegación y favoritos.

## What Changes

- Cliente de la API pública `api.preciosgasolina.es` en `lib/core/api`: único punto de
  acceso a la red, con caché en memoria y metadatos de frescura (`meta.last_updated`,
  `meta.data_age_seconds`, `meta.stale`).
- Modelo de gasolinera con parseo tolerante (precios como texto con coma decimal).
- Pantalla principal: lista de gasolineras cercanas ordenada por distancia, con distancia
  en km, rótulo, dirección y precio del carburante seleccionado.
- Ubicación con `geolocator` (permiso en Android) y fallback a búsqueda manual por
  municipio cuando no hay ubicación (escritorio o permiso denegado).
- Selector de carburante (Gasolina 95 y Gasóleo A).
- Estados de carga, error con reintento y vacío.
- Atribución visible CC BY 4.0 (Gasolina hoy + Ministerio) y antigüedad de los datos.

## Capabilities

### New Capabilities

- `gasolineras-cercanas`: consulta y presentación de las estaciones de servicio próximas a
  una ubicación, con precios por carburante ordenados por distancia, frescura de datos y
  la atribución obligatoria.

### Modified Capabilities

_(ninguna: es la primera capacidad del proyecto)_

## Impact

- Código nuevo: `lib/core/api`, `lib/core/models`, `lib/features/cercanas/{data,ui}`.
- Dependencias nuevas: `http`, `provider`, `geolocator`.
- `lib/main.dart` monta la pantalla principal en lugar del placeholder.
- Android: permiso de ubicación (`ACCESS_COARSE_LOCATION`/`ACCESS_FINE_LOCATION`) pedido
  solo al usarlo; sin cambios en iOS/Windows más allá del fallback manual.
- Sin backend: consumo directo de la API pública, con atribución y sin polling.

## Fuera de alcance

- Navegación externa a la gasolinera (change `feature-…-navegacion-a-gasolinera`).
- Favoritos (change `feature-…-favoritos`).
- Filtros avanzados (marca, horario 24h, GLP/GNC) e histórico de precios.
- Mapa embebido de gasolineras.
