# Tasks

## 1. Toolchain Android

- [x] 1.1 Subir AGP a `9.5.2` y Kotlin a `2.4.21` en `android/settings.gradle.kts`;
  verificar que no queda `9.1.1` ni `2.4.0` en la configuración Android
- [x] 1.2 Subir el wrapper a `gradle-9.9.2-all.zip` en
  `android/gradle/wrapper/gradle-wrapper.properties`; verificar que `./gradlew --version`
  informa Gradle 9.9.2 con JDK 21

## 2. Dependencias

- [x] 2.1 Ejecutar `flutter pub upgrade --major-versions` y `flutter pub upgrade`;
  verificar que `pubspec.yaml` recoge las últimas directas y que `pubspec.lock` resuelve
  sin conflictos
- [x] 2.2 Actualizar `@commitlint/cli` y `@commitlint/config-conventional` a `21.2.4`,
  regenerar `package-lock.json` y validar con `npx commitlint` sobre un commit reciente
- [x] 2.3 Resolver cualquier rotura de API o de build que introduzcan las actualizaciones,
  sin cambiar comportamiento; verificar `flutter analyze` y `flutter test`

## 3. Verificación e integración

- [x] 3.1 Ejecutar `npm run verify` completo y comprobar formato, changes, análisis y
  tests en verde
- [x] 3.2 Compilar `flutter build apk --release` y `flutter build linux --release`;
  verificar que los artefactos existen y que el APK está firmado
- [x] 3.3 Comprobar que `flutter build apk --release` ya no muestra los avisos de AGP y
  Kotlin «soon to be dropped»

## Workflow follow-up

- Archivar el change con `openspec archive` y comprobar que `openspec/specs` no cambia.
- Commitear todo en `dev` con `git status` limpio y hacer push.
- Vigilar la CI de `dev` y, al fusionar en `main`, el bump automático y el release.
