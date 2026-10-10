# Design

## Context

`android/app/build.gradle.kts` firma el release con `signingConfigs.getByName("debug")` y
`release.yml` ejecuta `flutter build apk --release` sin claves. En GitHub Actions el
keystore de debug se genera por runner, por lo que cada release cambia de firma y Android
exige desinstalar para actualizar. `scripts/bump.js` ya incrementa el `versionCode` (+N)
automáticamente, así que la versión no es el problema. Ver `proposal.md`.

## Goals / Non-Goals

**Goals:**

- Firma estable y secreta para el APK de release.
- Actualizaciones instalables encima (misma firma entre releases).
- Desarrollo local sin claves: sigue compilando con firma debug.

**Non-Goals:**

- Play Store, App Bundle o Play App Signing.
- Firmar los otros formatos (Windows/Linux van sin firma de código).

## Decisions

- **Keystore RSA 2048 con validez 10000 días**, alias `tolochafuel`, generado con
  `keytool` fuera del repositorio (`~/keystores/tolochafuel/`); copia de seguridad en ese
  mismo directorio y en GitHub Secrets (base64). Nunca se commitea.
- **`android/key.properties`** (gitignored) como fuente de la configuración:
  `storePassword`, `keyPassword`, `keyAlias`, `storeFile`. `build.gradle.kts` lo carga si
  existe; si no, `release` cae a la firma debug (comportamiento local actual).
- **En CI, `release.yml` materializa** `android/app/release.jks` (desde
  `ANDROID_KEYSTORE_BASE64`) y `android/key.properties` (desde los otros tres secretos)
  antes de compilar; si falta algún secreto, el job falla con mensaje claro en lugar de
  publicar un APK no actualizable.
- **Contraseñas aleatorias** generadas en local y guardadas solo en Secrets y en la copia
  fuera del repo.
- **Un único desinstalado final**: los APK antiguos (debug) no pueden actualizarse con la
  firma nueva; a partir del primer release con firma estable, las actualizaciones se
  instalan encima.
- **Validación local**: compilación `flutter build apk --release` con `key.properties`
  apuntando al keystore local y verificación con `apksigner verify --print-certs`.

## Risks / Trade-offs

- **Pérdida del keystore** → sin él no se pueden publicar actualizaciones: copia en
  `~/keystores/tolochafuel/` y en Secrets; documentado en AGENTS.md.
- **Secretos ausentes en un fork/PR** → el workflow de release falla con mensaje claro;
  CI no compila Android y no depende de los secretos.
- **Firma distinta a la debug** → un último desinstalado (anotado en el proposal).
