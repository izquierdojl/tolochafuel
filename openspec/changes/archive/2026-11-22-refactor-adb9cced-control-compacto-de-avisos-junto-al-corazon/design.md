# Design

## Context

- El control actual vive en `_FilaAviso`, dentro de `_FavoritoReordenable`: un
  `SwitchListTile` con título y subtítulo que añade una fila completa a cada tarjeta.
- `TarjetaGasolinera` es la tarjeta compartida por todas las listas. Su cabecera tiene
  nombre, 24h, distancia, navegar, corazón y menú.
- `mostrarResultadoAviso` muestra un `SnackBar`; también lo usa la campana de la ficha.
- El estado sigue en `Favorito.avisosPrecio`; `AvisosController` gestiona permiso, base y
  comprobación. Este change no toca esos datos.

## Goals / Non-Goals

**Goals:**

- Un icono de campana junto al corazón, solo en Favoritos.
- Eliminar la fila adicional de avisos.
- Mostrar el resultado de la activación en un diálogo emergente.
- Mantener el comportamiento, la persistencia y las notificaciones sin cambios.

**Non-Goals:**

- Mostrar el control en otras listas.
- Cambiar el contenido o la programación de las notificaciones.
- Cambiar la campana de la ficha.
- Añadir preferencias de carburante o silencio.

## Decisions

### Control en la cabecera

- `TarjetaGasolinera` recibe `mostrarAviso` con valor `false` por defecto. Solo
  `_FavoritoConPrecio` lo activa, así que el control no aparece en Cercanas, Buscar ni
  Más económicas.
- El icono se renderiza solo si `mostrarAviso`, la estación es favorita y hay un
  `AvisosController` disponible.
- Se coloca inmediatamente antes del corazón. Usa un `IconButton` con
  `Icons.notifications` cuando el aviso está activo e `Icons.notifications_none` cuando
  está apagado, con el mismo `iconSize: 20`, `visualDensity: compact` y color
  primario/onSurfaceVariant que el corazón.
  - Alternativa descartada: un `Switch` con campana. Ocupaba más y rompía la fila; el
    usuario prefiere un icono coherente con el corazón.
  - El botón lleva tooltip y semántica: «Avisarme de cambios de precio» o «Desactivar
    avisos de precio». Se deshabilita mientras `AvisosController.estaOcupado(id)`.
  - Si la cabecera se queda estrecha en 360 px, se comprobará con un widget test; el
    nombre seguirá usando `Expanded` con elipsis.
- Se elimina `_FilaAviso` y el `Column` que la envolvía. La tarjeta vuelve a tener la
  altura de una tarjeta normal.

### Diálogo de activación

- `mostrarResultadoAviso` pasa a ser asíncrona y muestra un `AlertDialog` con
  `showDialog`, título, mensaje y la acción «Entendido».
- Resultados:
  - `activado`: «Avisos activados» + «Te avisaremos cuando cambien los precios. Los datos
    se actualizan 2 veces al día.»
  - `activadoSinBase`: «Aviso activado» + se comprobará cuando haya conexión y los datos
    se actualizan 2 veces al día.
  - `permisoDenegado`: «Notificaciones desactivadas» + cómo concederlas en los ajustes.
  - `notificacionesDesactivadas`: «Notificaciones desactivadas» + activarlas en el
    sistema.
  - `noFavorito` y `error`: mensajes en español.
  - `desactivado` y `sinCambios`: no abren diálogo.
- La campana de la ficha reutiliza el mismo diálogo. No se duplica lógica de presentación.

### Estado y ocupación

- El icono lee `FavoritosController.avisosActivos(id)`.
- Se deshabilita mientras `AvisosController.estaOcupado(id)` está activo.
- Al pulsarlo, llama a `alternarAviso(id)` y, si el widget sigue montado, muestra el
  diálogo.

## Risks / Trade-offs

- **Cabecera estrecha** → el icono añade un control a una fila ya cargada. Se prueba a
  360 y 320 px; si hay desbordamiento, se reducen márgenes de los iconos y se mantiene el
  nombre con elipsis.
- **Objetivo táctil** → el `IconButton` conserva el área de pulsación estándar y el icono
  de 20 px queda alineado con el corazón; no se solapan.
- **Diálogo sobre la ficha** → usa el mismo navegador y se cierra con «Entendido»; no
  bloquea la ficha más allá del diálogo.
- **Sin migración** → no cambian claves ni modelos; el rollback solo afecta a la UI.

## Verificación manual

- Abrir Favoritos con una favorita: la campana aparece junto al corazón y no hay fila
  inferior.
- Activar: aparece el diálogo con la explicación de las dos actualizaciones diarias;
  cerrar y comprobar que la campana queda rellena.
- Denegar permiso: la campana vuelve a contornearse y el diálogo explica cómo concederlo.
- Desactivar: no aparece diálogo y la campana vuelve a contornearse.
- Comprobar que Cercanas y Buscar no muestran la campana.
- Revisado en emulador Android 37: campana contorneada apagada, rellena en primario al
  activar y diálogo «Avisos activados»; el widget test confirma que la cabecera no
  desborda a 360 y 320 px.

## Open Questions

_(ninguna: el alcance es una mejora de presentación y no cambia datos ni API.)_
