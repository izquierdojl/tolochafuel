# Tasks

## 1. Persistencia de favoritos

- [x] 1.1 Añadir `shared_preferences` a `pubspec.yaml`
- [x] 1.2 Modelo `Favorito` con serialización JSON y parseo tolerante
- [x] 1.3 `FavoritosRepository` (leer/guardar/borrar) con tests de ida y vuelta

## 2. Estado compartido

- [x] 2.1 `FavoritosController` (provider) con `esFavorito`, `alternar` y carga inicial
- [ ] 2.2 Registrar el provider en `main.dart` junto al de cercanas

## 3. Interfaz

- [x] 3.1 Icono de favorito en la tarjeta de la lista de cercanas
- [x] 3.2 Sección Favoritos con precios por `id`, estado vacío y error por favorito
- [x] 3.3 Atribución CC BY 4.0 visible también en Favoritos
- [x] 3.4 Widget tests: marcar/desmarcar, persistencia simulada y estado vacío
- [x] 3.5 `flutter analyze` + `flutter test` en verde y `dart format` aplicado
