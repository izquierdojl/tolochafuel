# Proposal

## Why

La sección Favoritos muestra las gasolineras en el orden en que se marcaron y no ofrece
ninguna forma de cambiarlo. Quien quiere tener arriba sus estaciones habituales no puede
hacerlo, y el orden guardado tampoco se trata como una preferencia explícita del usuario.
Permitir arrastrar las tarjetas para intercambiarlas y conservar ese orden entre
ejecuciones convierte Favoritos en una lista realmente personal.

## What Changes

- La lista de Favoritos pasa a ser reordenable: se mantiene pulsada una tarjeta y se
  arrastra a la posición deseada (en escritorio, además, un asa de arrastre visible).
- El nuevo orden se aplica de inmediato en la interfaz y se persiste en
  `shared_preferences` dentro del mismo listado de favoritos, sin claves nuevas.
- El orden se conserva entre ejecuciones de la app; al volver a abrir Favoritos se
  muestra tal como lo dejó el usuario.
- Las gasolineras nuevas se añaden al final de la lista y desmarcar una no altera el
  orden relativo de las demás.
- Si falla la escritura del nuevo orden, se mantiene en la sesión y se muestra un aviso
  en español, igual que ocurre con el resto de cambios de favoritos.
- La interacción es idéntica en Android, Windows y Linux; no cambia la API ni el modelo
  de datos.

## Capabilities

### New Capabilities

_(ninguna)_

### Modified Capabilities

- `favoritos`: se añade el requisito de reordenar la lista mediante arrastrar y soltar y
  se concreta que el orden elegido forma parte de la persistencia local, con el alta al
  final y la baja sin alterar el orden restante.

## Impact

- `lib/features/favoritos/ui/favoritos_pantalla.dart`: `ReorderableListView` con asa de
  arrastre y manejo de `onReorder`.
- `lib/features/favoritos/ui/favoritos_controller.dart`: operación de movimiento con
  validación de índices, actualización inmediata en memoria y persistencia del listado
  completo; aviso si falla el guardado.
- `lib/features/favoritos/data/favoritos_repositorio.dart`: el orden del array JSON pasa
  a ser el orden de presentación; se unifica el guardado y el borrado para no reescribir
  con una copia desactualizada.
- Tests: repositorio (orden tras guardar y cargar), controlador (mover, límites, fallo de
  guardado) y widget (arrastre, orden persistido y aviso).
- Sin dependencias nuevas, sin cambios en la API y sin migración de datos: los listados
  ya guardados conservan su orden actual.

## Fuera de alcance

- Reordenar Cercanas, Más económicas o Buscar; solo Favoritos.
- Ordenar automáticamente por precio, distancia, nombre o alias.
- Un orden distinto por carburante o por criterio de las otras listas.
- Edición numérica de posiciones, botones de subir/bajar o un modo de edición explícito.
- Sincronizar el orden entre dispositivos o cuentas (los favoritos son locales).
- Cambios en la API, en el modelo `Favorito` o en la atribución de datos.
