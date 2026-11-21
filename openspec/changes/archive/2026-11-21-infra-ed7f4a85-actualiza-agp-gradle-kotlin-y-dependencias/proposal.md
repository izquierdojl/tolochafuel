# Proposal

## Why

Tras subir a Flutter 3.50.1, el build de Android avisa de que el soporte de AGP 9.1.1 y
Kotlin 2.4.10 «will soon be dropped», y el proyecto arrastra dependencias Dart y Node con
versiones menores o mayores pendientes. Dejar el toolchain al día evita roturas futuras
cuando Flutter suba sus mínimos, reduce deuda de mantenimiento y aprovecha correcciones
de seguridad y compatibilidad de Gradle, AGP, Kotlin y los paquetes.

Versiones estables vigentes comprobadas: **AGP 9.5.2**, **Gradle 9.9.2**, **Kotlin
2.4.21**, **commitlint 21.2.4**, y para Dart `cupertino_icons 2.0.0`, `fl_chart 1.3.1`,
`flutter_svg 2.5.0` y `geolocator 14.1.2`.

## What Changes

- Subir el Android Gradle Plugin de 9.1.1 a **9.5.2** en `android/settings.gradle.kts`.
- Subir Gradle de 9.3.1 a **9.9.2** en `android/gradle/wrapper/gradle-wrapper.properties`.
- Subir Kotlin de 2.4.0 a **2.4.21** en `android/settings.gradle.kts`.
- Actualizar todas las dependencias Dart: `flutter pub upgrade --major-versions` para
  subir restricciones directas (`cupertino_icons`, `fl_chart`, `flutter_svg`,
  `geolocator`) y `flutter pub upgrade` para resolver transitivas al máximo compatible.
- Actualizar las dependencias Node de gobernanza: `@commitlint/cli` y
  `@commitlint/config-conventional` de 19.8.1 a **21.2.4**.
- Mantener las GitHub Actions en sus majors actuales (`checkout@v7`, `setup-node@v7`,
  `upload-artifact@v7`, `download-artifact@v8`, `subosito/flutter-action@v2`), que ya
  apuntan a las últimas versiones estables.
- Verificar con `npm run verify`, commitlint, `flutter build apk --release` y
  `flutter build linux --release`.
- Archivar el change, commitear y publicar en `dev`; el flujo habitual aplicará el bump
  de patch al fusionar en `main`.

Plataformas afectadas: todas (Android es la que más cambia por AGP/Gradle/Kotlin).

## Capabilities

### New Capabilities

_(ninguna: es infraestructura; no cambia comportamiento observable del producto)_

### Modified Capabilities

_(ninguna: no hay requisitos de producto nuevos ni alterados, por lo que el change
declara `skip_specs: true`)_

## Impact

- `android/settings.gradle.kts` (AGP y Kotlin) y el wrapper de Gradle.
- `pubspec.yaml` y `pubspec.lock` (dependencias directas y transitivas).
- `package.json` y `package-lock.json` (commitlint).
- Posibles ajustes mínimos en `android/` si AGP 9.5 cambia requisitos de SDK o DSL.
- Release: artefactos reconstruidos con el toolchain nuevo al fusionar en `main`.

## Fuera de alcance

- Cambiar la versión de Flutter/Dart (ya está en 3.50.1 / 3.14.0).
- Cambios funcionales, de UI, datos o dependencias que exijan reescribir código.
- Migrar a Kotlin 2.5 (beta/RC) ni a AGP 9.6 (alpha).
- Cambiar la estrategia de release, los secretos de firma o las ramas.
- Publicar en Play Store, iOS, web o Docker.
