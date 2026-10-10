# Design

## Context

`release.yml` publica hoy APK y ZIP de Windows y `ci.yml` valida formato, análisis y
tests en Ubuntu. El proyecto no tiene `linux/` y AGENTS.md fija Android/Windows con web e
iOS aplazados; este change añade Linux como plataforma secundaria de escritorio. Ver
`proposal.md` para la motivación.

## Goals / Non-Goals

**Goals:**

- Build Linux reproducible en CI y release con tres formatos y nombres estables.
- Un único script de empaquetado compartido por CI y release (sin lógica duplicada).
- Validar la plataforma en cada PR antes de fusionar.

**Non-Goals:**

- Publicar en Flathub ni generar `.deb`/`.rpm`/Snap.
- Geolocalización nativa en Linux.
- Tocar workflows de Android/Windows.

## Decisions

- **Scaffolding con `flutter create --platforms=linux .`**, `BINARY_NAME` `tolochafuel`,
  `APPLICATION_ID` `io.github.izquierdojl.TolochaFuel` (reverse-DNS del repo, válido para
  Flatpak/D-Bus) y título «TolochaFuel» en el runner GTK.
- **Un script `packaging/linux/empaquetar.sh`** que, partiendo de
  `build/linux/x64/release/bundle`, genera los tres assets en `dist/`:
  - **tar.gz**: el bundle se renombra a `tolochafuel/` y se comprime.
  - **AppImage**: AppDir con `AppRun`, `.desktop` e icono; `appimagetool` oficial se
    descarga en el job y se ejecuta con `--appimage-extract-and-run` (los runners no
    tienen FUSE).
  - **Flatpak**: manifiesto `io.github.izquierdojl.TolochaFuel.yml` con runtime
    `org.gnome.Platform//46` (incluye GTK3 y libepoxy, que necesita el runner Flutter),
    `command: tolochafuel`; el bundle precompilado se copia a `/app/bin` con un módulo
    `simple`; `flatpak-builder --disable-rofiles-fuse` y `flatpak build-bundle` con
    `--runtime-repo` de Flathub para que el runtime se resuelva al instalar.
- **El `.desktop` y el icono se copian desde `assets/branding/app_icon.png`** en tiempo
  de empaquetado: no se duplican binarios en el repositorio.
- **CI valida los tres formatos** (job `linux` en `ci.yml`) y el release los publica (job
  `linux` en `release.yml` + `publicar`); así el Flatpak/AppImage no llegan a `main` sin
  haber pasado por un PR.
- **Dependencias del job**: `clang`, `cmake`, `ninja-build`, `pkg-config`,
  `libgtk-3-dev`, `liblzma-dev`, `flatpak`, `flatpak-builder`, `elfutils`; runtime GNOME
  en ámbito de usuario (sin sudo para Flatpak).
- **Nombres de asset estables** para enlaces de descarga directa:
  `tolochafuel-linux-x64.tar.gz`, `.AppImage` y `.flatpak`.

## Risks / Trade-offs

- **Flatpak/AppImage fallan a la primera en CI** → el job `linux` de `ci.yml` los valida
  en el PR; se corrige antes de fusionar.
- **Descarga del runtime GNOME (~1 GB) en cada job** → jobs más lentos; se acepta a
  cambio de validar el formato real; cacheable como mejora futura.
- **`geolocator` sin soporte Linux** → la app cae al aviso con acceso a la sección Buscar
  (comportamiento de escritorio ya probado en Windows).
- **Bundle GTK3 dentro del sandbox Flatpak** → se usa el runtime GNOME (GTK3 + libepoxy)
  en lugar del freedesktop básico.
