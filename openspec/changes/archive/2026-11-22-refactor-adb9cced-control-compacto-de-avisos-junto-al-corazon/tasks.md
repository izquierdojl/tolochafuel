# Tasks

> Cada tarea se cierra con `flutter analyze` y `flutter test` en verde, además de la
> verificación indicada.

## 1. Control compacto

- [x] 1.1 Añadir `mostrarAviso` (por defecto `false`) a `TarjetaGasolinera` y renderizar un `IconButton` de campana junto al corazón, relleno si está activo y contorneado si no, solo si la estación es favorita y hay `AvisosController`; verificación: widget test de la tarjeta con `mostrarAviso: true` y ambos estados.
- [x] 1.2 Eliminar `_FilaAviso` y el `Column` de `_FavoritoReordenable`, y pasar `mostrarAviso: true` desde `_FavoritoConPrecio`; verificación: widget test de Favoritos sin `SwitchListTile` y con la campana en la cabecera.
- [x] 1.3 Comprobar que la campana no aparece en Cercanas/Buscar y que la cabecera no desborda a 360 y 320 px; verificación: widget tests de ausencia y de layout estrecho.
- [x] 1.4 Conectar la campana con `AvisosController.alternarAviso`, deshabilitarla mientras está ocupada y conservar el estado tras reabrir; verificación: widget tests de activación, desactivación y persistencia.

## 2. Diálogo de activación

- [x] 2.1 Convertir `mostrarResultadoAviso` en un `AlertDialog` con «Entendido», título y mensaje por resultado, sin diálogo al desactivar; verificación: widget tests de éxito, permiso denegado, notificaciones desactivadas y base pendiente.
- [x] 2.2 Reutilizar el diálogo desde la campana de la ficha y actualizar sus tests; verificación: widget test de la ficha que activa la campana y cierra el diálogo.
- [x] 2.3 Actualizar `docs/uso.md` con la campana junto al corazón y el diálogo; verificación: revisar que la sección de avisos ya no describe una fila inferior.

## 3. Verificación y cierre

- [x] 3.1 Ejecutar `dart format .`, `flutter analyze`, `flutter test`, `bash scripts/check_changes.sh` y `openspec validate --strict`; verificación: todo en verde.
- [x] 3.2 Revisar visualmente el cambio en un dispositivo/emulador si está disponible; verificación: la campana cabe junto al corazón y el diálogo aparece al activar.

## Workflow follow-up

- Archivar el change y commitear en `dev`.
- Push, PR a `main`, merge y release de patch `0.10.1`.
