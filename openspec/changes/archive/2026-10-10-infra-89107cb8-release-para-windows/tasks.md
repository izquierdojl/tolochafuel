# Tasks

## 1. Build y empaquetado en CI

- [x] 1.1 Job `windows` en `release.yml` (`windows-latest`, `flutter build windows --release`)
- [x] 1.2 Empaquetar `build/windows/x64/runner/Release/*` en `tolochafuel-windows-x64.zip`
- [x] 1.3 Subir el ZIP como artefacto y adjuntarlo en el job `publicar` (junto al APK)
- [x] 1.4 Verificar que un merge a `dev` genera el release con ambos assets

## 2. Metadatos y documentación

- [x] 2.1 Ajustar nombre del producto y versión en `windows/runner/Runner.rc`
- [x] 2.2 README: enlaces de descarga del APK y del ZIP y nota sobre SmartScreen
- [x] 2.3 `flutter analyze` + `flutter test` en verde y `dart format` aplicado
