# Design

## Context

La app ya muestra gasolineras con coordenadas. `url_launcher` es la pieza del stack para
abrir aplicaciones y URLs externas y soporta Android y Windows. Ver `proposal.md` para la
motivación.

## Goals / Non-Goals

**Goals:**

- Un único servicio `Navegacion` reutilizable por cualquier lista (cercanas, favoritos).
- Comportamiento correcto en Android (intents) y Windows (navegador).
- Fallo controlado y mensaje en español.

**Non-Goals:**

- Elegir app de mapas por el usuario o recordar preferencias.
- Rutas con origen fijo o transporte distinto de coche (se usa el modo por defecto).

## Decisions

- **`url_launcher`** ya está en el stack del proyecto; no se añade dependencia nueva de
  terceros más allá de la que fija AGENTS.md.
- **Android**: se lanza `geo:0,0?q=<lat>,<lng>(<rótulo>)` con
  `LaunchMode.externalApplication`, el estándar que resuelven Google Maps y otras apps de
  mapas. Si devuelve `false`, respaldo a
  `https://www.google.com/maps/dir/?api=1&destination=<lat>,<lng>&travelmode=driving`.
- **Escritorio**: directamente la URL de Google Maps web en
  `LaunchMode.externalApplication` (navegador predeterminado).
- **Servicio puro y testeable**: `Navegacion.abrirDestino(Gasolinera)` construye la URI
  por plataforma en una función separada (`uriParaNavegar`) para poder testear sin lanzar
  la URL.
- **Errores**: el servicio devuelve `bool`; la UI muestra `SnackBar` con mensaje en
  español si es `false`.

## Risks / Trade-offs

- **Rótulo con caracteres especiales**: la etiqueta del intent `geo:` se codifica con
  `Uri.encodeComponent`; algunas apps de mapas muestran solo coordenadas (aceptable).
- **Windows sin navegador predeterminado**: poco frecuente; el estado de error cubre el
  caso sin afectar a la lista.
