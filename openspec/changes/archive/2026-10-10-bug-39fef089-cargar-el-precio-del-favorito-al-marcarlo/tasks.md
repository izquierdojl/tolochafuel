# Tasks

## 1. Corrección del marcado

- [x] 1.1 En `FavoritosController.agregar()`, tras persistir, lanzar `cargarDetalle(id)` sin bloquear el flujo; verificar con test que `ApiFalsa.consultas` registra el id al marcar (`flutter analyze` + `flutter test` en verde)
- [x] 1.2 Ampliar `test/features/favoritos_controller_test.dart`: la consulta no se duplica si ya está en caché o en curso y la marca persiste aunque la consulta falle (`flutter analyze` + `flutter test` en verde)
- [x] 1.3 Verificar `test/features/favoritos_pantalla_test.dart`: tras marcar, la tarjeta muestra el precio y, si la consulta falla, conserva el aviso con «Reintentar» (`flutter analyze` + `flutter test` en verde)
- [x] 1.4 `dart format .` y comprobación manual en Android: marcar una gasolinera en Cercanas, abrir Favoritos y ver el precio sin reiniciar la app

## Workflow follow-up

- Archivar el change cuando esté implementado y verificado (commit en `dev`, `git status` limpio).
