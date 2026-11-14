# Design

## Context

Ver `proposal.md` - Why. Hoy `FavoritosPantalla` pinta `ListView.builder` con
`_FavoritoConPrecio` y `TarjetaGasolinera`; `FavoritosController` mantiene la lista en
memoria y `FavoritosRepositorio` la guarda como array JSON bajo la clave `favoritos` de
`shared_preferences`. El orden del array ya se conserva en `cargar()` y `agregar()`
añade al final, pero no existe ninguna operación de reordenación. `aviso` del
controlador se escribe pero no se muestra en la pantalla de Favoritos.

## Goals / Non-Goals

**Goals:**

- Modelar el orden como el propio orden del listado persistido, sin claves ni campos
  nuevos.
- Concentrar la reordenación en el controlador (validación, actualización inmediata y
  persistencia), dejando la pantalla solo con la traducción de `onReorder`.
- Ofrecer una interacción clara en táctil (pulsación larga) y escritorio (asa), con el
  mismo código de lista.
- Mostrar el aviso de fallo de guardado que hoy queda oculto.

**Non-Goals:**

- Reordenar otras listas, ordenar por criterios o mantener órdenes alternativos.
- Cambiar `Favorito`, la API, la caché de precios o el esquema de almacenamiento.
- Introducir un modo de edición, botones de subir/bajar o numeración visible.

## Decisions

- **El orden es el array JSON existente.** `FavoritosRepositorio.cargar()` ya respeta el
  orden y `guardar()` ya serializa en orden; no hace falta un campo `orden` ni una clave
  `favoritos_orden`. Alternativa descartada: guardar una lista de ids aparte, que
  duplicaría la fuente de verdad y exigiría migración y limpieza al desmarcar.

- **`FavoritosController.mover(int desde, int hasta)` con índices finales.** La
  operación valida que ambos índices existan en la lista, que sean distintos y que la
  lista tenga al menos dos elementos; después extrae el favorito, lo inserta en la
  posición final, notifica a la interfaz y persiste. Es síncrona en memoria hasta el
  `await` del guardado, así que la lista se repinta en el mismo frame del gesto. La
  pantalla usa `onReorderItem`, que entrega la posición final ya ajustada tras extraer el
  elemento, y la pasa tal cual a `mover`.

- **Persistir siempre el listado completo.** `quitar` deja de llamar a
  `FavoritosRepositorio.borrar(id)` (que releía disco y podía reescribir una copia
  antigua) y guarda la lista actual en memoria. Se elimina `borrar` del repositorio. Así
  el orden y las altas/bajas comparten una sola ruta de escritura y una reordenación
  seguida de una baja no puede perder el orden. Las escrituras se encadenan en el
  controlador con una cola de futuros para que dos arrastres rápidos terminen en el
  orden del último gesto, no en el de la última respuesta del sistema.

- **`ReorderableListView.builder` con asa propia.** La pantalla sustituye el
  `ListView.builder`, conserva `PieFrescura` debajo y usa
  `buildDefaultDragHandles: false`. Cada elemento lleva `ValueKey(favorito.id)` y se
  envuelve en `ReorderableDelayedDragStartListener` (pulsación larga en toda la tarjeta);
  al lado, un asa `ReorderableDragStartListener` con `Icons.drag_handle` y área táctil de
  48 px inicia el arrastre inmediato en escritorio y también en táctil. El asa solo se
  pinta con dos o más favoritos. Alternativas descartadas: los asas por defecto de
  `ReorderableListView` (en escritorio se superponen al contenido de la tarjeta, a la
  altura del precio y de los iconos) y reordenar solo con pulsación larga (poco
  descubrible con ratón).

- **Aviso visible reutilizando `FavoritosController.aviso`.** `FavoritosPantalla` pinta
  un aviso compacto sobre la lista (o sobre el estado vacío) cuando `aviso` no es nulo,
  con colores del tema (`errorContainer`/`onErrorContainer`). El controlador limpia
  `aviso` al inicio de una escritura correcta para que el mensaje desaparezca cuando el
  guardado vuelve a funcionar. No se añade un botón de reintento: reordenar o volver a
  marcar reintenta la escritura de forma natural.

- **Sin cambios en la tarjeta compartida.** `TarjetaGasolinera` se mantiene igual para
  Cercanas, Más económicas y Buscar; el asa y el gesto viven en el envoltorio de
  Favoritos, de modo que las otras listas no ganan controles de reordenación.

- **Plataformas:** mismo comportamiento y misma persistencia en Android, Windows y
  Linux; `ReorderableDelayedDragStartListener` y `ReorderableDragStartListener` aceptan
  puntero táctil y ratón. Sin dependencias nuevas.

## Risks / Trade-offs

- [La pulsación larga sobre un botón de la tarjeta (navegar, favorito, menú) puede
  iniciar el arrastre en lugar de mostrar su tooltip] → el asa es la vía principal y la
  pulsación larga sigue funcionando en el cuerpo de la tarjeta; los toques cortos de los
  botones no cambian.
- [El asa ocupa ancho útil en pantallas estrechas] → icono compacto de 48 px de área
  táctil fuera de la tarjeta y solo visible con dos o más favoritos.
- [Dos arrastres rápidos pueden solapar escrituras] → cola de persistencia con la
  instantánea más reciente; la interfaz nunca espera al disco para repintar.
- [Un fallo de `shared_preferences` deja el orden solo en la sesión] → aviso visible en
  español y la siguiente escritura correcta actualiza el estado persistido.
- [Listados antiguos o corruptos] → no se migra nada: los que ya existen conservan su
  orden; `cargar()` sigue ignorando entradas inválidas y devuelve lista vacía si el JSON
  no es válido.
