# Tasks

## 1. Configuración del runtime

- [x] 1.1 Actualizar `packaging/linux/io.github.izquierdojl.TolochaFuel.yml` a
  `org.gnome.Platform`/`org.gnome.Sdk` 51 y `.github/workflows/release.yml` para instalar
  `org.gnome.Platform//51 org.gnome.Sdk//51`. Verificar con
  `grep -R "Platform//46\|Sdk//46\|runtime-version: '46'"` que no queda ninguna
  referencia fuera de `openspec/changes/archive/`, que el runtime 51 instalado contiene
  `libgtk-3.so.0` y `libepoxy.so.0`, y que siguen en verde `flutter analyze` y
  `flutter test`.

## 2. Verificación del empaquetado

- [x] 2.1 Instalar en ámbito de usuario `org.flatpak.Builder` y `org.gnome.Sdk//51` si no
  están disponibles, ejecutar `flutter build linux --release` (con el shim de Clang si
  hace falta) y `bash packaging/linux/empaquetar.sh`, instalar el bundle generado con
  `flatpak install --user --bundle` y comprobar con `flatpak info` que la app declara
  `org.gnome.Platform/x86_64/51`; desinstalar la app de prueba al terminar. Verificar
  también `flutter analyze` y `flutter test`.

## Workflow follow-up

- Archivar el change y commitear código, manifiesto y workflow en `dev`.
- Hacer push, abrir el PR `dev → main`, esperar la CI y fusionar con merge commit.
- Comprobar que `version.yml` y `release.yml` publican la nueva release patch con los
  cinco assets y el Flatpak construido contra GNOME 51.
