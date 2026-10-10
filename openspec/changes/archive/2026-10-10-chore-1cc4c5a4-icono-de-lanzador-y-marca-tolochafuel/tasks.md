# Tasks

## 1. Herramienta y fuente de marca

- [x] 1.1 Añadir `flutter_launcher_icons` a `dev_dependencies` y el bloque de configuración
  en `pubspec.yaml`; verificar que `flutter pub get` termina sin errores
- [x] 1.2 Generar `assets/branding/app_icon.png` (1024×1024) desde
  `assets/icons/tolocha.svg` y commitearlo; verificar dimensiones y que abre correctamente
- [x] 1.3 Documentar el comando de regeneración del PNG en `assets/branding/` y verificar
  que volver a ejecutarlo reproduce el mismo fichero

## 2. Iconos por plataforma

- [x] 2.1 Ejecutar `dart run flutter_launcher_icons`; verificar que regenera las mipmaps de
  Android (dejan de coincidir con las del scaffold), `web/icons/*`, `web/favicon.png` y
  `windows/runner/resources/app_icon.ico`
- [x] 2.2 Definir el icono adaptativo de Android (foreground con margen + fondo pine
  `#08100B`) y verificar que existen los recursos generados (`mipmap-anydpi-v26`,
  `ic_launcher_foreground` y `colors`)
- [x] 2.3 Verificar que el `.ico` de Windows es el generado (metadatos/tamaño) y que el
  runner lo referencia (`Runner.rc`)

## 3. Nombre visible

- [x] 3.1 Cambiar `android:label` a «TolochaFuel» en
  `android/app/src/main/AndroidManifest.xml`; verificar con `grep` y con el APK instalado
- [x] 3.2 Poner «TolochaFuel» en `web/manifest.json` (`name`/`short_name`) y en
  `web/index.html` (`<title>` y `apple-mobile-web-app-title`); verificar con `grep`
- [x] 3.3 Confirmar que `windows/runner/Runner.rc` mantiene «TolochaFuel» en
  `FileDescription` y `ProductName`

## 4. Verificación en dispositivo y calidad

- [ ] 4.1 Instalar el APK de release y comprobar el icono (normal y adaptativo) y el nombre
  «TolochaFuel» en el lanzador
- [x] 4.2 Confirmar que el widget test de cabecera sigue en verde (marca «TolochaFuel» +
  emblema `SvgPicture`); añadir la aserción del emblema si falta
- [x] 4.3 Ejecutar `flutter analyze` + `flutter test` en verde y aplicar `dart format .`

## Workflow follow-up

- Archivar el change tras el merge a `dev`; el versionado lo dispara `version.yml`.
