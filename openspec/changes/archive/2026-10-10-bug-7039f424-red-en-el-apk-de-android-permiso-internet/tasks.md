# Tasks

## 1. Declarar el permiso de red en Android

- [x] 1.1 Añadir `<uses-permission android:name="android.permission.INTERNET"/>` al manifiesto
  principal `android/app/src/main/AndroidManifest.xml` (junto a los permisos de ubicación);
  verificar que `flutter build apk --release` termina sin errores
- [x] 1.2 Añadir `test/android_manifest_test.dart` que lea
  `android/app/src/main/AndroidManifest.xml` y compruebe que contiene
  `android.permission.INTERNET` (guarda de regresión); verificar con
  `flutter test test/android_manifest_test.dart`
- [x] 1.3 Documentar en el commit/PR por qué el permiso debe vivir en `src/main` (los de
  `debug`/`profile` no se aplican al release); verificar que `scripts/check_changes.sh` sigue
  en verde

## 2. Verificación del APK de release

- [ ] 2.1 Construir el APK de release e inspeccionar el manifiesto mergeado del APK para
  confirmar la presencia de `android.permission.INTERNET`
- [ ] 2.2 Instalar el APK en un Android con red y comprobar que lista las gasolineras
  cercanas; repetir sin red y comprobar el estado de error con reintento
- [x] 2.3 Ejecutar `flutter analyze` + `flutter test` en verde y aplicar `dart format .`

## Workflow follow-up

- Archivar el change tras el merge a `dev`; el versionado lo dispara `version.yml`.
