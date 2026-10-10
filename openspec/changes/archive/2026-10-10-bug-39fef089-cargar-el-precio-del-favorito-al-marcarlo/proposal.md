# Proposal

## Why

Al marcar una gasolinera como favorita, su tarjeta en la sección Favoritos se queda sin
precios («Precios no disponibles») hasta que la pantalla se recrea (por ejemplo, al
reiniciar la app). El marcado y la consulta del precio están desconectados: la carga de
fichas solo se dispara al construir la pantalla de Favoritos, no al marcar.

## What Changes

- `FavoritosController.agregar()` consulta el detalle de la estación
  (`/v1/stations/{id}`) en el momento de marcarla, reutilizando la caché y la
  deduplicación existentes de `cargarDetalle`.
- La marca y su persistencia no se bloquean ni se pierden si la consulta falla; el error
  ya se muestra en la tarjeta con opción de reintentar.
- Tests del controlador: la consulta se lanza al marcar, no se duplica si ya está en
  curso o en caché, y la marca sobrevive a un fallo de consulta.

## Capabilities

### New Capabilities

_(ninguna)_

### Modified Capabilities

- `favoritos`: el requisito «Sección Favoritos con precio vigente» gana el escenario en
  el que el precio de una gasolinera recién marcada ya se consulta al marcarla, sin
  recrear la pantalla ni reiniciar la app.

## Impact

- Código: `lib/features/favoritos/ui/favoritos_controller.dart`; tests en
  `test/features/favoritos_controller_test.dart` y `test/features/favoritos_pantalla_test.dart`.
- API: una petición más a `/v1/stations/{id}` (120 pet/min) por favorito nuevo, dentro
  de los límites.
- Sin dependencias nuevas ni cambios de interfaz. Todas las plataformas (Android,
  Windows, Linux).

## Fuera de alcance

- Persistir precios en el favorito (seguirán consultándose a la API).
- Compartir la caché de fichas entre `CercanasRepositorio` y `FavoritosController`.
- Rediseño de la tarjeta o del estado de error de favoritos.
