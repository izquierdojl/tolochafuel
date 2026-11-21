# Tasks

## 1. Versión fijada en CI y documentación

- [x] 1.1 Cambiar `flutter-version` a `3.50.1` en los dos jobs de
  `.github/workflows/ci.yml` y en los tres jobs de `.github/workflows/release.yml`;
  verificar con `grep -rn "3.47.7" .github/` que no queda ninguna referencia
- [x] 1.2 Actualizar la versión fijada y la fila de UI (`material_ui`) en `AGENTS.md`
  (§2) y la versión en `README.md`; verificar con `grep -rn "3.47.7"` que no queda
  ninguna referencia fuera del historial de changes archivados

## 2. Dart, Material y dependencias

- [x] 2.1 Subir `environment.sdk` de `pubspec.yaml` a `^3.14.0`, añadir
  `material_ui ^1.11.1` y ejecutar `flutter pub get`; verificar en `pubspec.lock` que la
  restricción de Dart resuelta es `>=3.14.0 <4.0.0` y que `material_ui` queda resuelto
- [x] 2.2 Sustituir los 36 imports de `package:flutter/material.dart` por
  `package:material_ui/material_ui.dart` en `lib/` y `test/`; verificar que no queda
  ningún import antiguo y que `flutter analyze` pasa sin avisos de deprecación
- [x] 2.3 Subir el Android Gradle Plugin de `9.1.0` a `9.1.1` en
  `android/settings.gradle.kts` y añadir `android/build/` a `.gitignore`; resolver
  cualquier otra rotura que introduzca 3.50.1 sin cambiar comportamiento

## 3. Verificación e integración

- [x] 3.1 Ejecutar `npm run verify` completo y verificar que formato, configuración
  OpenSpec, análisis y tests quedan en verde
- [x] 3.2 Compilar `flutter build apk --release` y `flutter build linux --release`;
  verificar que los artefactos existen y que el APK está firmado

## Workflow follow-up

- Archivar el change con `openspec archive` y comprobar que `openspec/specs` no cambia
  (no hay deltas).
- Commitear todo el change en `dev` con `git status` limpio y hacer push.
- Vigilar la CI de `dev` y, al fusionar en `main`, el bump automático a 0.2.3 y el
  release de los artefactos.
