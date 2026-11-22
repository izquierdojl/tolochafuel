# Desarrollo y release

> [← Volver al README](../README.md)

## Entorno

| Herramienta | Versión / ruta |
| --- | --- |
| Flutter | Stable **3.50.1** (fijada en CI); SDK local en `~/flutter` |
| Dart | `^3.14.0`, incluido con Flutter |
| JDK | 21 |
| Android SDK | `~/Android/Sdk` (con `adb` en `platform-tools`) |
| Node.js | 22 (`.nvmrc`), para scripts, Commitlint y OpenSpec |
| Linux | Dependencias de escritorio: `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`, `liblzma-dev` |

La app usa Dart estricto con `flutter_lints`. Antes de dar una tarea por terminada:
`dart format`, `flutter analyze` y `flutter test` en verde.

## Puesta en marcha

```bash
flutter pub get
flutter run -d <dispositivo>
```

Dispositivos habituales: el AVD `Medium_Phone_API_37.0` (`emulator -list-avds`) o un
Android físico por USB. Para escritorio Linux, `flutter run -d linux` (sin ubicación
nativa: usa la sección Buscar).

## Comandos

```bash
flutter pub get
flutter run -d <dispositivo>
flutter analyze
flutter test
dart format .
npm run verify              # check_changes + formato + analyze + tests
npm run check:changes       # valida meta.yaml y nombres de los changes
npm run release:patch       # manual y excepcional
```

Compilaciones:

```bash
flutter build apk --release
flutter build linux --release
bash packaging/linux/empaquetar.sh   # tar.gz, AppImage y Flatpak
flutter build windows --release      # solo en Windows
```

`npm run verify` ejecuta `scripts/verificar.sh`, que comprueba los changes de OpenSpec,
el formato de `lib/` y `test/`, el análisis y toda la batería de tests.

## CI

- **`ci.yml`**: se ejecuta en PRs a `dev`/`main` y en push a `dev`. Valida los changes,
  el formato, `flutter analyze`, `flutter test` y Commitlint. En PRs que tocan código
  también compila Linux.
- **`version.yml`**: se dispara al fusionar en `main`. Exige que `main` apunte a un merge
  y que la CI de la punta de `dev` esté en verde; después calcula el bump, actualiza la
  versión, crea el tag y llama al release.
- **`release.yml`**: construye el APK Android firmado, el ZIP portable de Windows y los
  tres formatos de Linux, y los publica en GitHub Releases con nombres estables.

Los secretos de firma Android (`ANDROID_KEYSTORE_*`) viven en GitHub Secrets. Nunca se
commitean keystores ni contraseñas.

## Ramas, commits y versionado

- `main` = producción; `dev` = integración y destino de todos los PR.
- Los changes que lo necesiten usan una rama `feature/<tipo>-<id8>-<slug>` con PR a
  `dev`; el resto se trabaja directamente en `dev`.
- Commits convencionales en español: `feat:`, `fix:`, `docs:`, `infra:`, `refactor:`,
  `test:`, `chore:`; `BREAKING CHANGE` o `!` para major. Commitlint lo valida.
- Al fusionar en `main` el bump es automático: `feat`/`feature` → minor,
  `fix`/`bug` → patch, `BREAKING` → major; el resto → patch. No se toca la versión a mano
  salvo decisión explícita.
- Toda funcionalidad empieza como change en `openspec/changes/` y se archiva al
  terminarla. El proceso completo está en [`AGENTS.md`](../AGENTS.md).

## Capturas para el README y la documentación

Las capturas viven en `docs/assets/capturas/` y se toman con la app real en Android. Usa
un **AVD propio** para no compartir estado ni foco con otras tareas de la máquina. Si el
AVD principal ya está arrancado, una instancia `-read-only` sobre el mismo AVD puede
rechazarse (todos los emuladores tendrían que haberse iniciado en ese modo); en ese caso,
crea un clon y arranca en otro puerto:

```bash
avdmanager create avd -n TolochaFuel_Capturas \
  -k "system-images;android-37.0;google_apis_playstore;x86_64" -d medium_phone
~/Android/Sdk/emulator/emulator -avd TolochaFuel_Capturas -port 5556 \
  -no-window -no-audio -no-boot-anim -gpu swiftshader_indirect -no-snapshot &
~/Android/Sdk/platform-tools/adb -s emulator-5556 wait-for-device
flutter run -d emulator-5556
```

En otra terminal, fija una ubicación pública (centro de Madrid), concede los permisos y
reinicia la app:

```bash
ADB=~/Android/Sdk/platform-tools/adb
$ADB -s emulator-5556 emu geo fix -3.7038 40.4168
$ADB -s emulator-5556 shell pm grant com.izquierdojl.tolochafuel android.permission.ACCESS_COARSE_LOCATION
$ADB -s emulator-5556 shell pm grant com.izquierdojl.tolochafuel android.permission.ACCESS_FINE_LOCATION
$ADB -s emulator-5556 shell am force-stop com.izquierdojl.tolochafuel
$ADB -s emulator-5556 shell am start -n com.izquierdojl.tolochafuel/.MainActivity
```

Si el AVD con Google Play no entrega la ubicación con la precisión media, comprueba que
la ubicación del sistema está activa y que los permisos siguen concedidos. Como último
recurso puntual para capturar, se puede subir temporalmente la precisión en
`lib/core/services/ubicacion.dart` y revertir el cambio antes de commitear; no forma
parte del código que se publica.

Navega por las pantallas y captura con:

```bash
$ADB -s emulator-5556 exec-out screencap -p > captura.png
```

Optimiza antes de guardar: 540 px de ancho, sin metadatos y con compresión PNG.

```bash
magick captura.png -resize 540x -strip docs/assets/capturas/01-cercanas-claro.png
optipng docs/assets/capturas/01-cercanas-claro.png
```

Usa nombres descriptivos (`01-cercanas-claro.png`, `08-cercanas-oscuro.png`…) y revisa
que no aparezcan diálogos del sistema, datos personales ni errores de la API. Las
capturas son ilustrativas: los precios cambian dos veces al día.
