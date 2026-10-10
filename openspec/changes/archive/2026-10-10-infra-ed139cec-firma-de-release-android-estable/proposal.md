# Proposal

## Why

Instalar una versión nueva del APK exige desinstalar la anterior: el release se firma con
la clave **debug** y, en GitHub Actions, el keystore de debug se regenera en cada runner,
así que cada release tiene una firma distinta. Android solo actualiza si la firma coincide;
con una clave de release estable en GitHub Secrets, las actualizaciones se instalan encima
sin desinstalar.

## What Changes

- **Keystore de release** generado y guardado en GitHub Secrets (nunca en el repo):
  `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` y
  `ANDROID_KEY_PASSWORD`.
- `android/app/build.gradle.kts`: `signingConfigs.release` a partir de
  `android/key.properties`; si no existe (desarrollo local sin claves), cae a la firma
  debug como hasta ahora.
- `release.yml`: el job `android` materializa el keystore y `key.properties` desde los
  secretos antes de compilar y falla con mensaje claro si faltan.
- `.gitignore`: excluye `android/key.properties` y el keystore.
- AGENTS.md §9 actualizado: la firma de release deja de estar aplazada; Play Store sigue
  aplazado.

## Capabilities

_(cambio de tooling y distribución: no cambia el comportamiento de la app, por lo que no
modifica specs; el change declara `skip_specs: true`)_

## Impact

- `android/app/build.gradle.kts`, `.gitignore`, `.github/workflows/release.yml` y
  AGENTS.md.
- Secretos nuevos en GitHub (los inyecta el owner; el repositorio no guarda claves).
- Sin cambios en el código Dart.
- Nota: la primera instalación con la firma nueva exige **un último desinstalado**; a
  partir de ahí las actualizaciones entran encima.

## Fuera de alcance

- Publicación en Play Store y App Bundle (sigue aplazada).
- Rotación automatizada de claves o firma por Play App Signing.
