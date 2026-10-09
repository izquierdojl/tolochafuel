# Tasks

## 1. Persistencia de favoritos

- [ ] 1.1 Añadir `shared_preferences` a `pubspec.yaml`
- [ ] 1.2 Modelo `Favorito` con serialización JSON y parseo tolerante
- [ ] 1.3 `FavoritosRepository` (leer/guardar/borrar) con tests de ida y vuelta

## 2. Estado compartido

- [ ] 2.1 `FavoritosController` (provider) con `esFavorito`, `alternar` y carga inicial
- [ ] 2.2 Registrar el provider en `main.dart` junto al de cercanas

## 3. Interfaz

- [ ] 3.1 Icono de favorito en la tarjeta de la lista de cercanas
- [ ] 3.2 Sección Favoritos con precios por `id`, estado vacío y error por favorito
- [ ] 3.3 `NavigationBar` inferior Cercanas/Favoritos
- [ ] 3.4 Atribución CC BY 4.0 visible también en Favoritos
- [ ] 3.5 Widget tests: marcar/desmarcar, persistencia simulada y estado vacío
- [ ] 3.6 `flutter analyze` + `flutter test` en verde y `dart format` aplicado
