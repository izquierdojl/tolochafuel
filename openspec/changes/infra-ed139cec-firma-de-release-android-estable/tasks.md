# Tasks

## 1. Keystore y secretos

- [x] 1.1 Generar el keystore de release fuera del repo (`~/keystores/tolochafuel/`) con `keytool` y contraseñas aleatorias; verificación: `keytool -list` lo abre
- [x] 1.2 Subir los cuatro secretos a GitHub (`ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`); verificación: `gh secret list` los muestra

## 2. Configuración de firma

- [x] 2.1 `android/app/build.gradle.kts`: `signingConfigs.release` desde `android/key.properties` con caída a debug si no existe; verificación: `flutter build apk --release` local compila y `apksigner verify --print-certs` muestra el CN de TolochaFuel
- [x] 2.2 `.gitignore`: excluir `android/key.properties` y `*.jks`; verificación: `git status` no los muestra
- [ ] 2.3 `release.yml`: materializar keystore y `key.properties` desde secretos antes del build, con fallo claro si faltan; verificación: el siguiente release publica el APK firmado con el keystore nuevo

## 3. Documentación y cierre

- [x] 3.1 AGENTS.md §9: firma de release estable en Secrets (Play Store sigue aplazado); verificación: revisión del diff
- [x] 3.2 `flutter analyze` + `flutter test` en verde y `dart format` aplicado

## Workflow follow-up

- Archivar el change tras el merge en `dev` y hacer PR `dev → main`.
- Verificar que el APK del release instala encima del release anterior (primer uso: un desinstalado final).
- El versionado lo dispara la fusión en `main` (tipo `infra` → patch); no tocar la versión a mano.
