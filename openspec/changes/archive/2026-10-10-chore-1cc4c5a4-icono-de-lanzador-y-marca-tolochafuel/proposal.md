# Proposal

## Why

El APK instalado en el móvil muestra el icono genérico de Flutter y el nombre
«tolochafuel» en minúsculas, así que la app no se reconoce como TolochaFuel en el
lanzador. El emblema Tolocha ya existe (`assets/icons/tolocha.svg`) pero solo se usa dentro
de la cabecera de la app; los recursos de lanzador siguen siendo los del scaffold de
`flutter create`.

## What Changes

- Icono de lanzador con el emblema Tolocha en Android (mipmaps legacy + icono adaptativo),
  Windows (`.ico`) y web (favicon e iconos del manifest), de forma reproducible.
- Nombre visible «TolochaFuel» en el lanzador de Android (`android:label`), el manifest web
  y el `<title>` de la web. Windows ya muestra «TolochaFuel».
- `flutter_launcher_icons` como dev-dependency y un PNG fuente de marca (1024×1024)
  derivado de `tolocha.svg`, que sigue siendo la fuente de verdad de la marca.

No cambia ningún comportamiento especificado: son recursos de identidad de plataforma, no
una capacidad funcional. El change declara `skip_specs: true`.

## Capabilities

### New Capabilities

_(ninguna: es un cambio de assets e identidad de plataforma, sin capacidad funcional)_

### Modified Capabilities

_(ninguna: no cambia el comportamiento especificado. El change declara `skip_specs: true`)_

## Impact

- `pubspec.yaml`: dev-dependency `flutter_launcher_icons` + bloque de configuración y assets
  de marca.
- Android: `android/app/src/main/res/mipmap-*/` y recursos del icono adaptativo;
  `android:label` en `android/app/src/main/AndroidManifest.xml`.
- Web: `web/manifest.json`, `web/index.html`, `web/icons/*`, `web/favicon.png`.
- Windows: `windows/runner/resources/app_icon.ico`.
- Asset nuevo: `assets/branding/` (imagen de marca 1024×1024).
- Sin cambios en el código Dart de la app ni en la API.
- Plataformas afectadas: **Android** (principal) y **Windows**; web actualizado por
  coherencia. iOS fuera de alcance.

## Fuera de alcance

- Icono y assets de iOS (aplazados en AGENTS.md).
- Splash screen / pantalla de arranque personalizada.
- Iconos temáticos/monocromos de Android 13+ y sonido/animación del icono.
- Rediseño del emblema: se reutiliza `tolocha.svg`.
