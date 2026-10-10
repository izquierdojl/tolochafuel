# Tasks

## 1. Metadatos en los controladores

- [x] 1.1 Guardar `resultado.meta` en `CercanasController` y `MasEconomicasController` (propiedad `MetaDatos? meta`); tests de controlador: disponible tras éxito y conservado en vacío (`flutter analyze` + `flutter test` en verde)
- [x] 1.2 Guardar `resultado.meta` en `BuscarController`; test de controlador equivalente (`flutter analyze` + `flutter test` en verde)
- [x] 1.3 Conservar el meta de la ficha en `DetalleEstacion` y `PreciosGasolinaApi.detalle`, y exponerlo en `FavoritosController`; tests de API (fixture) y de controlador (`flutter analyze` + `flutter test` en verde)

## 2. Widget del pie

- [x] 2.1 Crear `PieFrescura` (recibe `MetaDatos?`, texto con `textoFrescura`, aviso `stale` con color del tema) y widget test de sus estados: con fecha, sin fecha y `stale` (`flutter analyze` + `flutter test` en verde)

## 3. Integración en las listas

- [x] 3.1 Integrar el pie en Cercanas y Más económicas (`Column` + `Expanded`) y widget tests de estados clave: datos, vacío con meta y error sin pie (`flutter analyze` + `flutter test` en verde)
- [x] 3.2 Integrar el pie en Buscar y Favoritos y widget tests equivalentes, incluida la ausencia de meta (`flutter analyze` + `flutter test` en verde)
- [x] 3.3 Verificación final: `dart format .` + `flutter analyze` + `flutter test` en verde y revisión manual del pie en tema claro y oscuro (sin colores literales en widgets)

## Workflow follow-up

- Archivar el change cuando esté implementado y verificado (commit en `dev`, `git status` limpio).
