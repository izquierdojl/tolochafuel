# Proposal

## Why

La CI y los releases se compilan con Flutter 3.47.7 (Dart 3.13.5), una versión anterior
a la stable vigente. La stable actual es Flutter 3.50.1 (Dart 3.14.0, publicada el 20 de
noviembre de 2026), que incluye correcciones y mejoras del toolchain. Además, Flutter
3.50 marca `package:flutter/material.dart` como obsoleto: `flutter analyze` falla con 36
avisos de deprecación y el paquete oficial de Material pasa a ser `material_ui`.

Alinear el SDK local, la CI y los artefactos publicados con la stable vigente evita
diferencias entre lo que se prueba y lo que se distribuye, y deja el proyecto listo para
seguir desarrollando sin deuda de deprecaciones.

## What Changes

- Fijar **Flutter 3.50.1** (canal stable, Dart 3.14.0) en `.github/workflows/ci.yml` y
  `.github/workflows/release.yml` (sustituye a 3.47.7 en los cinco jobs de build).
- Subir la restricción de Dart de `pubspec.yaml` a `^3.14.0` y regenerar `pubspec.lock`.
- Añadir el paquete oficial `material_ui ^1.11.1` y sustituir los 36 imports de
  `package:flutter/material.dart` por `package:material_ui/material_ui.dart` en `lib/` y
  `test/` (migración mecánica, sin cambios de comportamiento).
- Subir el Android Gradle Plugin de 9.1.0 a 9.1.1, mínimo que exige Flutter 3.50.1.
- Actualizar las referencias documentales a la versión fijada (`AGENTS.md`, `README.md`).
- Verificar con `npm run verify` y compilar el APK release y el binario Linux release.
- Publicar: archivar el change, commit y push a `dev`; la CI valida y el flujo habitual
  de release aplica el bump automático de patch.

Plataformas afectadas: todas (Android, Windows y Linux comparten el SDK y la capa de UI).

## Capabilities

### New Capabilities

_(ninguna: es infraestructura; no cambia comportamiento observable del producto)_

### Modified Capabilities

_(ninguna: no hay requisitos de producto nuevos ni alterados, por lo que el change
declara `skip_specs: true`)_

## Impact

- Workflows de GitHub Actions (`ci.yml`, `release.yml`) y documentación de gobernanza.
- `pubspec.yaml` y `pubspec.lock` (restricción de Dart, `material_ui` y resolución de
  dependencias).
- `android/settings.gradle.kts` (AGP 9.1.1).
- Imports de Material en 22 archivos de `lib/` y 14 de `test/`.
- Posibles ajustes puntuales si Flutter 3.50.1 introduce otros avisos o requisitos.
- Release: nuevo tag `v0.2.3` y artefactos reconstruidos con la stable nueva.

## Fuera de alcance

- Actualizar dependencias a versiones mayores por iniciativa propia; solo lo que exija
  la compatibilidad con Flutter 3.50.1.
- Cambios de comportamiento, UI, datos o funcionalidades de la app.
- Cambiar la estrategia de release, los secretos de firma o las ramas.
- Migrar a otro canal de Flutter (beta/master) ni a FVM.
- Subir la versión a `1.0.0` (lo decide el usuario).
