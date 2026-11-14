# Tasks

## 1. Modelo y persistencia del tema

- [x] 1.1 Sustituir `Ajustes.temaOscuro` por `Ajustes.tema` (`ThemeMode`, defecto `ThemeMode.system`) y `copyWith`, y añadir la clave `config.tema` en `ConfiguracionRepositorio` con lectura/escritura de `sistema|claro|oscuro`; verificación: `flutter analyze` sin errores en `lib/features/configuracion/data`
- [x] 1.2 Implementar la migración en `cargar()` (clave `config.tema` válida > bool `config.temaOscuro` → oscuro/claro > `sistema`; valores inválidos → `sistema`) sin borrar la clave antigua; verificación: tests de `configuracion_repositorio_test.dart` para defecto, ida y vuelta de los tres modos, migración de `true`/`false` y valor inválido

## 2. Controlador y arranque

- [x] 2.1 Cambiar `ConfiguracionController` a `ThemeMode get tema` y `cambiarTema(ThemeMode)` (eliminando `temaOscuro`) y conectar `themeMode: config.tema` en `lib/main.dart`; verificación: `configuracion_controller_test.dart` actualizado (cambio, persistencia simulada y aviso si falla el guardado) en verde
- [x] 2.2 Actualizar `tema_inicial_test.dart` y `cercanas_radio_test.dart` a la nueva API y añadir un test de que con «Sistema» la app sigue el brillo de la plataforma (`tester.platformDispatcher.platformBrightnessTestValue`), incluido el cambio con la app abierta; verificación: los tests pasan en verde

## 3. Interfaz de Configuración

- [x] 3.1 Reemplazar el `SwitchListTile` «Tema oscuro» por un `ListTile` «Tema» con `SegmentedButton<ThemeMode>` (Sistema · Claro · Oscuro, con iconos, selección única) en `configuracion_pantalla.dart`, sin colores literales y legible en pantallas estrechas; verificación: widget test en `configuracion_pantalla_test.dart` de que el defecto marca «Sistema», que pulsar «Claro»/«Oscuro» actualiza el controlador y guarda, y que se pinta sin desbordes en un ancho de 320 px
- [x] 3.2 Actualizar `shell_pantalla_test.dart` (texto del control en la pantalla de Configuración) y cualquier otro test que use `temaOscuro`; verificación: `grep -r temaOscuro lib test` solo devuelve la clave de migración del repositorio y `flutter test` en verde

## 4. Documentación e integración

- [x] 4.1 Actualizar `AGENTS.md` y `openspec/config.yaml` donde dicen «tema oscuro por defecto + claro» para reflejar «sistema por defecto (claro/oscuro)»; verificación: `grep -rn "oscuro por defecto" AGENTS.md openspec/config.yaml` sin resultados
- [x] 4.2 Verificación final: `dart format .` aplicado, `flutter analyze` + `flutter test` en verde, `bash scripts/check_changes.sh` correcto y revisión manual en Android y escritorio de «Sistema», «Claro» y «Oscuro» (cambio de modo del SO con la app abierta, persistencia al reiniciar y que quien tenía claro u oscuro lo conserva)

## Workflow follow-up

- Archivar el change tras commitear código y specs en `dev` (`git status` limpio).
