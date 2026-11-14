# Tasks

## 1. Persistencia y controlador

- [x] 1.1 Simplificar `FavoritosRepositorio` para que todas las mutaciones guarden el
  listado completo en orden, eliminar `borrar(int id)` y añadir un test que guarde tres
  favoritos, los recargue y compruebe que conservan el orden. Verificar con
  `flutter analyze && flutter test test/features/favoritos_repositorio_test.dart`.
- [x] 1.2 Añadir `FavoritosController.mover(desde, hasta)` con validación de índices,
  actualización inmediata y persistencia encadenada; hacer que `quitar` guarde la lista
  en memoria y que `aviso` se limpie tras una escritura correcta. Cubrir con tests de
  controlador el movimiento, los índices inválidos, la persistencia del orden, la baja
  sin alterar el orden restante y el fallo de guardado. Verificar con
  `flutter analyze && flutter test test/features/favoritos_controller_test.dart`.

## 2. Lista reordenable y avisos

- [x] 2.1 Sustituir el `ListView.builder` de `FavoritosPantalla` por
  `ReorderableListView.builder` con claves por id, pulsación larga en la tarjeta, asa
  visible solo con dos o más favoritos y uso de `onReorderItem`. Verificar con un widget
  test que arrastra el asa y comprueba el nuevo orden, otro que confirma que sin asa con
  un solo favorito y que el estado vacío sigue mostrándose, y
  `flutter analyze && flutter test test/features/favoritos_pantalla_test.dart`.
- [x] 2.2 Mostrar en Favoritos el `aviso` del controlador con colores del tema cuando
  falle el guardado del orden, sin romper los estados de carga, error y vacío. Añadir
  widget tests del aviso tras un `mover` fallido y de la progresión de precio en curso,
  y verificar con `flutter analyze && flutter test test/features/favoritos_pantalla_test.dart`.

## 3. Verificación de integración

- [x] 3.1 Ejecutar `dart format --output=none --set-exit-if-changed .`,
  `flutter analyze` y `flutter test` completos; probar en el emulador Android que se
  puede reordenar con pulsación larga y que el orden se mantiene al cerrar y abrir la
  app, y en Linux de escritorio que el asa arrastra la tarjeta. Verificar también que
  Cercanas, Más económicas y Buscar no muestran controles de reordenación ni cambian de
  comportamiento.
