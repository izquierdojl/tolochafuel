# Tasks

## 1. Plataforma Linux

- [x] 1.1 Generar `linux/` con `flutter create --platforms=linux .` y ajustar `APPLICATION_ID` a `io.github.izquierdojl.TolochaFuel`, `BINARY_NAME` `tolochafuel` y título «TolochaFuel»; verificación: `flutter build linux --release` compila en el job de CI del PR

## 2. Empaquetado

- [x] 2.1 Crear `packaging/linux/io.github.izquierdojl.TolochaFuel.desktop` (Name, Comment, Exec, Icon, Categories) y el manifiesto `io.github.izquierdojl.TolochaFuel.yml` (org.gnome.Platform//46, command `tolochafuel`, args network/wayland/x11/dri, módulo simple que copia el bundle a `/app/bin`); verificación: `flatpak-builder` valida el manifiesto en CI
- [x] 2.2 Crear `packaging/linux/empaquetar.sh` que genera `dist/tolochafuel-linux-x64.tar.gz`, `.AppImage` (appimagetool con `--appimage-extract-and-run`) y `.flatpak` (`flatpak-builder` + `flatpak build-bundle`); verificación: el script termina con los tres ficheros en CI

## 3. CI y release

- [x] 3.1 Job `linux` en `ci.yml` (dependencias del sistema, build, empaquetado y artefactos) que valide la plataforma en cada PR; verificación: PR con el job en verde y artefactos subidos
- [x] 3.2 Job `linux` en `release.yml` y `publicar` con `needs: [android, windows, linux]` copiando los tres assets con nombres estables; verificación: release con los tres assets adjuntos

## 4. Documentación y cierre

- [x] 4.1 AGENTS.md (§2 distribución, §5 plataformas, §8 nombres de assets) y README (descarga e instrucciones por formato); verificación: revisión del diff
- [x] 4.2 `flutter analyze` + `flutter test` en verde y `dart format` aplicado

## Workflow follow-up

- Archivar el change tras el merge en `dev` y hacer PR `dev → main`.
- Verificar el release: APK + ZIP Windows + tar.gz/AppImage/Flatpak de Linux con nombres estables.
- El versionado lo dispara la fusión en `main` (tipo `infra` → patch); no tocar la versión a mano.
