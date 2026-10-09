# Proposal

## Why

Saber dónde está la gasolinera más barata no sirve de nada sin poder ir a ella: desde la
lista de cercanas (y en el futuro desde favoritos) el usuario necesita lanzar la
navegación hacia la estación elegida con un toque.

## What Changes

- Servicio de navegación externa en `lib/core/services`: abre la app de mapas del sistema
  con el destino en las coordenadas de la gasolinera.
- Botón «Navegar» en cada tarjeta de gasolinera de la lista.
- Android: intent `geo:` con `label` del rótulo; si ninguna app lo maneja, se abre
  Google Maps web como respaldo.
- Windows/escritorio: abre Google Maps web en el navegador predeterminado.
- Mensaje en español si la apertura falla, sin bloquear la lista.

## Capabilities

### New Capabilities

- `navegacion-externa`: apertura de aplicaciones o webs de mapas hacia las coordenadas de
  una gasolinera desde la interfaz, con comportamiento por plataforma.

### Modified Capabilities

_(ninguna)_

## Impact

- Código nuevo: `lib/core/services/navegacion.dart`; cambio en la tarjeta de gasolinera.
- Dependencia nueva: `url_launcher`.
- Sin permisos nuevos: no se consulta ubicación, solo se abren URLs/intents.
- Android: requiere que exista un navegador para el fallback web; en su defecto se
  muestra un aviso.

## Fuera de alcance

- Navegación interna de la app con `go_router` u otro enrutador.
- Rutas con waypoints o selección de medio de transporte distinto del coche.
- Deep links entrantes a la app.
- Integración con navegadores específicos (Waze, OsmAnd…) más allá del intent estándar.
