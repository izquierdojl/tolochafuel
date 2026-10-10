# Proposal

## Why

TolochaFuel ya publica APK (Android) y ZIP portable (Windows), pero los usuarios de Linux
no tienen paquete: el código es multiplataforma y el runner de Ubuntu de CI puede
generarlo sin coste adicional. El usuario quiere los tres formatos habituales de escritorio
Linux (tar.gz, AppImage y Flatpak) disponibles en cada release.

## What Changes

- Plataforma `linux/` generada con Flutter (runner GTK), id de aplicación
  `io.github.izquierdojl.TolochaFuel` y título de ventana «TolochaFuel».
- Empaquetado reproducible en `packaging/linux/`: **tar.gz** (bundle portable),
  **AppImage** (ejecutable único) y **Flatpak** (bundle standalone con runtime de Flathub),
  con un script compartido por CI y release.
- Job `linux` en `release.yml` que construye y adjunta los tres assets con nombres
  estables (`tolochafuel-linux-x64.tar.gz`, `tolochafuel-linux-x64.AppImage`,
  `tolochafuel-linux-x64.flatpak`).
- Job `linux` en `ci.yml` que compila y empaqueta en cada PR para validar la plataforma
  antes de fusionar.
- AGENTS.md (§2, §5, §8) y README con la plataforma y los enlaces de descarga.

## Capabilities

_(cambio de tooling y distribución: no cambia el comportamiento de la app, por lo que no
modifica specs; el change declara `skip_specs: true`)_

## Impact

- Nuevos: `linux/` (scaffolding Flutter) y `packaging/linux/` (script, `.desktop`,
  manifiesto Flatpak).
- `.github/workflows/release.yml` y `.github/workflows/ci.yml`.
- AGENTS.md y README.
- Sin cambios en el código Dart ni dependencias nuevas. `geolocator` no soporta Linux: la
  app usa el fallback ya existente a la sección Buscar.

## Fuera de alcance

- Publicación en Flathub, Snap, `.deb`/`.rpm` y AUR (evaluables como change futuro).
- Ubicación nativa en Linux (`geolocator` no ofrece implementación).
- Cambios en Android, Windows o web.
