# Tasks

## 1. Modelo del criterio y API

- [x] 1.1 Ampliar `Carburante` a los seis carburantes de la API (Gasolina 95, Gasolina 98, Gasóleo A, Gasóleo premium, GLP y GNC, con sus etiquetas) y crear `CriterioEconomicas` en `lib/core/models/` con `clave`/`desdeClave` y `etiqueta`; tests unitarios de ida y vuelta, clave desconocida → Gasolina 95 y nula → Gasolina 95 (`flutter analyze` + `flutter test` en verde)
- [x] 1.2 Añadir el parámetro `fuel` (por defecto `Carburante.gasolina95`) a `PreciosGasolinaApi.masBaratasCerca` y extender los tests de la API para comprobar que la petición envía el carburante elegido (`flutter analyze` + `flutter test` en verde)

## 2. Media y repositorio

- [x] 2.1 Crear `lib/features/cercanas/data/orden_economicas.dart` con la media €/L por estación y el orden ascendente; tests: media aritmética de varios €/L, exclusión de €/kg (GNC) y de productos no-carburante (AdBlue), precios nulos y estaciones sin media descartadas (`flutter analyze` + `flutter test` en verde)
- [x] 2.2 Extender `CercanasRepositorio.masEconomicas` con el criterio (carburante → `/v1/stations/cheapest` con `fuel`; media → `/v1/stations/nearby` con `sort=distance` y `limit` 50, fichas y recorte a 20) y claves de caché por criterio; tests de repositorio con API falsa: petición por carburante, ranking por media y reutilización de caché al repetir criterio (`flutter analyze` + `flutter test` en verde)

## 3. Ajustes y controlador

- [x] 3.1 Añadir `criterioEconomicas` a `Ajustes` y su clave en `ConfiguracionRepositorio` (lectura tolerante: clave ausente o inválida → Gasolina 95); tests de repositorio de ida y vuelta y de valores inválidos (`flutter analyze` + `flutter test` en verde)
- [x] 3.2 Añadir `ConfiguracionController.cambiarCriterioEconomicas` con el mismo patrón que radio y tema (aplicar, notificar, guardar y aviso si falla); test de controlador (`flutter analyze` + `flutter test` en verde)
- [x] 3.3 `MasEconomicasController`: exponer `criterio`, `cambiarCriterio()` y recargar solo al cambiar radio o criterio (no por tema ni pantalla inicial); tests de controlador: carga con criterio guardado, cambio de criterio recarga una sola vez y criterio conservado al recrear el controlador con los ajustes guardados (`flutter analyze` + `flutter test` en verde)

## 4. Pantalla y verificación

- [x] 4.1 Sustituir el subtítulo fijo de Más económicas por el selector «Ordenar por» con el criterio activo (patrón del selector de pantalla inicial); widget tests: opciones del selector, Gasolina 95 por defecto y cambio a Gasóleo A que recarga y actualiza la cabecera (`flutter analyze` + `flutter test` en verde)
- [x] 4.2 Adaptar el estado vacío al criterio (mensaje con el carburante sin estaciones) y widget tests de los estados clave: carga, error con reintento, vacío por criterio y datos con ranking por media (`flutter analyze` + `flutter test` en verde)
- [x] 4.3 Verificación final: `dart format .` aplicado, `flutter analyze` + `flutter test` en verde, `bash scripts/check_changes.sh` correcto y revisión manual del selector en tema claro y oscuro (sin colores literales en widgets)

## Workflow follow-up

- Commit en `dev` (código + specs) y archivar el change cuando esté verificado, con `git status` limpio.
