# Design

## Context

Ver `proposal.md`. El proyecto fija la versión de Flutter en los workflows `ci.yml`
(dos jobs) y `release.yml` (tres jobs), y la cita en `AGENTS.md` y `README.md`. El SDK
local `~/flutter` ya está en Flutter 3.50.1 / Dart 3.14.0, así que el trabajo se centra
en alinear la configuración del repositorio y en resolver la deprecación de Material.

Flutter 3.50.1 empaqueta Dart 3.14.0. El proyecto declara `environment.sdk: ^3.13.5`,
que técnicamente admite Dart 3.14 pero no documenta el mínimo real. `flutter analyze`
falla (código 1) con 36 avisos `deprecated_member_use` por importar
`package:flutter/material.dart`.

## Goals / Non-Goals

**Goals:**

- Que SDK local, CI y artefactos de release usen exactamente Flutter 3.50.1 / Dart 3.14.0.
- Dejar el rango de Dart de `pubspec.yaml` coherente con el SDK que compila.
- Eliminar la deuda de deprecación de Material migrando al paquete oficial `material_ui`.
- Mantener Android, Windows y Linux compilando y los tests en verde.

**Non-Goals:**

- Actualizar dependencias por gusto o cambiar comportamiento de la app.
- Alterar la estrategia de release, los secretos de firma o las ramas.
- Migrar a otro canal de Flutter (beta/master) ni a FVM.
- Cambiar el diseño visual: la paleta y los widgets siguen siendo los mismos.

## Decisions

### 1. Una sola cifra de versión, replicada en CI y documentación

Se cambia `flutter-version: '3.47.7'` por `'3.50.1'` en `ci.yml` y `release.yml`, y se
actualizan `AGENTS.md` y `README.md`. Alternativa considerada: usar `channel: stable` sin
versión; se descarta porque rompe la reproducibilidad y la regla del proyecto de fijar la
versión en CI.

### 2. Dart no se instala aparte: viene con Flutter

`subosito/flutter-action` descarga el SDK de Flutter, que incluye su Dart. La restricción
`sdk:` de `pubspec.yaml` es un mínimo de compatibilidad, no la versión de compilación; se
sube a `^3.14.0` para documentar el mínimo real y se regenera `pubspec.lock` con
`flutter pub get`.

### 3. Sustituir Material de Flutter por `material_ui`

Se añade el paquete oficial `material_ui ^1.11.1` y se sustituye el import en `lib/` y
`test/`. `material_ui` reexporta `package:flutter/widgets.dart` y los mismos widgets, así
que el cambio es mecánico y no altera comportamiento. Alternativa considerada: silenciar
`deprecated_member_use` en `analysis_options.yaml`; se descarta porque oculta
deprecaciones futuras y va contra la dirección de Flutter. Decisión consultada y aprobada
por el usuario por afectar a una librería base.

### 4. Compatibilidad: verificar y corregir solo lo que falle

Tras actualizar se ejecutan `flutter pub get`, `npm run verify`, `flutter build apk
--release` y `flutter build linux --release`. Si aparecen avisos de análisis, tests rotos
o incompatibilidades de Gradle, se corrigen de forma mínima dentro de este change.
Flutter 3.50.1 exige como mínimo AGP 9.1.1, así que se sube el plugin de 9.1.0 a 9.1.1.
Windows no se puede compilar en Linux; la CI de PR valida Linux y el release valida
Windows. Si el problema exigiera cambios grandes, se detiene y se consulta.

### 5. Release automático, sin bump manual

El change es `infra`, así que `version.yml` aplicará un bump de patch al fusionar en
`main`: 0.2.2 → 0.2.3. No se edita la versión a mano ni se crea el tag localmente; el
flujo existente espera la CI verde, hace el commit `chore(release)` y dispara
`release.yml`. Los assets mantienen sus nombres estables.

## Risks / Trade-offs

- **Flutter 3.50.1 rompe el build Android** (AGP, Gradle, lints nuevos) → se corrige lo
  mínimo y, si el alcance crece, se para y se propone un change aparte.
- **`material_ui` no reexporta algún símbolo usado** → `flutter analyze` lo detecta; se
  importa el origen correcto (`flutter/widgets.dart`, `flutter/services.dart`) sin
  duplicar Material.
- **La caché de `subosito/flutter-action` reutiliza artefactos de 3.47.7** → la acción
  incluye la versión en la clave de caché; aun así se comprueba `flutter --version` en
  el log de CI.
- **Windows no se puede probar en local** → la CI de PR y el release compilan Windows
  como hasta ahora; el cambio de UI es Dart puro y no toca código nativo.
- **Rollback**: revertir el commit de actualización y el tag si el release saliera mal;
  la versión anterior sigue disponible en GitHub Releases.

## Migration Plan

1. Actualizar versiones, documentación y restricción de Dart.
2. Añadir `material_ui`, sustituir imports y subir AGP.
3. Ejecutar la verificación completa y los builds release de Android y Linux.
4. Archivar el change y commitear todo en `dev`.
5. Push a `dev`: CI valida; el PR `dev → main` dispara el bump de patch y el release.
6. Comprobar el release y los artefactos publicados.

## Open Questions

_(ninguna)_
