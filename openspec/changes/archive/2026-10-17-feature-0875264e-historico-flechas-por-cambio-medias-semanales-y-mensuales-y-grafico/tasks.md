# Tasks

## 1. Dependencia y gobernanza

- [x] 1.1 Añadir `fl_chart: ^1.2.0` a `pubspec.yaml`, ejecutar `flutter pub get` y actualizar el stack en `AGENTS.md` (§2) y en el contexto de `openspec/config.yaml`; verificación: `flutter pub get` correcto y `flutter analyze` + `flutter test` en verde con la dependencia resuelta

## 2. Modelo del histórico (core)

- [x] 2.1 Añadir `CambioPrecio` (`punto`, `tendencia`, `delta`) y hacer que `SerieCarburante.cambios()` lo devuelva calculando la dirección contra el punto anterior del histórico; tests unitarios: cambio al alza, a la baja, límite de cinco y serie sin cambios (`flutter analyze` + `flutter test` en verde)
- [x] 2.2 Añadir `SerieCarburante.media(n)` y `SerieCarburante.tendenciaMedia(n)` (media de los últimos `n` registros; comparación a tres decimales con los `n` anteriores, `desconocida` sin ventana completa); tests unitarios: ventanas completas e incompletas, medias iguales («=»), serie plana y serie más corta que la ventana (`flutter analyze` + `flutter test` en verde)

## 3. Modal de histórico

- [x] 3.1 Extraer la flecha de tendencia a `lib/features/cercanas/ui/widgets/flecha_tendencia.dart` (colores del tema y etiquetas semánticas en español) y usarla en `tarjeta_gasolinera.dart` sin cambio visual; verificación: los widget tests actuales de la tarjeta siguen en verde (`flutter analyze` + `flutter test` en verde)
- [x] 3.2 Pintar en cada fila de «últimos cambios» la flecha de dirección que devuelve `CambioPrecio` a la derecha del precio; widget tests del modal: flecha verde hacia abajo en un cambio a la baja, roja hacia arriba al alza, y estados de carga, error con reintento, sin histórico y producto sin cambios intactos (`flutter analyze` + `flutter test` en verde)
- [x] 3.3 Sustituir `_ResumenVariacion` por el bloque de medias pulsable («Última semana» y «Último mes» con `formatearPrecio` en la unidad del producto, flecha de tendencia contra la ventana anterior e indicador de que abre el gráfico), con estado de expansión por producto; widget tests: textos y flechas con series de prueba, sin fila con ventana incompleta, sin flecha sin ventana anterior y etiqueta semántica del bloque (`flutter analyze` + `flutter test` en verde)
- [x] 3.4 Crear `lib/features/cercanas/ui/widgets/grafico_historico.dart` con `fl_chart`: línea de los 90 días, punto final resaltado, ejes con fecha/precio, medias de semana y mes discontinuas cuando existan, margen para series planas, tooltip al tocar con fecha (dd/mm/aaaa) y precio en la unidad, y texto del tooltip en función pura; tests unitarios del texto y widget test: al pulsar el bloque aparece el gráfico, al volver a pulsar se contrae y con menos de dos registros no se ofrece (`flutter analyze` + `flutter test` en verde)

## 4. Verificación de integración

- [x] 4.1 Verificación final: `dart format .` aplicado, `flutter analyze` + `flutter test` en verde, `bash scripts/check_changes.sh` correcto y revisión manual del modal (flechas por fila, medias, gráfico y tooltip) en tema claro y oscuro sobre Android y escritorio, sin colores literales en widgets

## Workflow follow-up

- Commit en `dev` (código + specs + gobernanza) y archivar el change cuando esté verificado, con `git status` limpio.
