#!/usr/bin/env bash
set -euo pipefail

# Empaqueta el bundle de Flutter para Linux en tar.gz, AppImage y Flatpak.
# Requisitos: flutter build linux --release, flatpak-builder, curl.
# Uso: bash packaging/linux/empaquetar.sh

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RAIZ="$(dirname "$(dirname "$DIR")")"
BUNDLE="$RAIZ/build/linux/x64/release/bundle"
DIST="$RAIZ/dist"
APP_ID="io.github.izquierdojl.TolochaFuel"
ICONO="$RAIZ/assets/branding/app_icon.png"

if [ ! -x "$BUNDLE/tolochafuel" ]; then
  echo "No existe el bundle ($BUNDLE); ejecuta antes: flutter build linux --release" >&2
  exit 1
fi

rm -rf "$DIST"
mkdir -p "$DIST"

ICONO_512="$DIST/icon-512.png"
if command -v convert >/dev/null 2>&1; then
  convert "$ICONO" -resize 512x512 "$ICONO_512"
else
  cp "$ICONO" "$ICONO_512"
fi

echo "==> tar.gz"
cp -r "$BUNDLE" "$DIST/tolochafuel"
tar -C "$DIST" -czf "$DIST/tolochafuel-linux-x64.tar.gz" tolochafuel
rm -rf "$DIST/tolochafuel"

echo "==> AppImage"
APPDIR="$DIST/AppDir"
mkdir -p "$APPDIR/usr/bin" \
  "$APPDIR/usr/share/applications" \
  "$APPDIR/usr/share/icons/hicolor/512x512/apps"
cp -r "$BUNDLE/." "$APPDIR/usr/bin/"
install -Dm644 "$DIR/$APP_ID.desktop" "$APPDIR/$APP_ID.desktop"
install -Dm644 "$DIR/$APP_ID.desktop" \
  "$APPDIR/usr/share/applications/$APP_ID.desktop"
install -Dm644 "$ICONO_512" "$APPDIR/$APP_ID.png"
install -Dm644 "$ICONO_512" \
  "$APPDIR/usr/share/icons/hicolor/512x512/apps/$APP_ID.png"
cat > "$APPDIR/AppRun" <<'EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f "$0")")"
exec "$HERE/usr/bin/tolochafuel" "$@"
EOF
chmod +x "$APPDIR/AppRun"

HERRAMIENTA="$DIST/appimagetool"
if [ ! -x "$HERRAMIENTA" ]; then
  curl -fsSL -o "$HERRAMIENTA" \
    "https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage"
  chmod +x "$HERRAMIENTA"
fi
ARCH=x86_64 "$HERRAMIENTA" --appimage-extract-and-run \
  "$APPDIR" "$DIST/tolochafuel-linux-x64.AppImage"
rm -rf "$APPDIR" "$HERRAMIENTA" "$DIST/squashfs-root"

echo "==> Flatpak"
WORK="$DIST/flatpak"
mkdir -p "$WORK/fuente"
cp -r "$BUNDLE/." "$WORK/fuente/"
install -Dm644 "$DIR/$APP_ID.desktop" "$WORK/fuente/$APP_ID.desktop"
install -Dm644 "$DIR/$APP_ID.yml" "$WORK/fuente/$APP_ID.yml"
install -Dm644 "$ICONO_512" "$WORK/fuente/icon.png"

flatpak-builder --user --force-clean --disable-rofiles-fuse \
  --repo="$WORK/repo" "$WORK/build" "$WORK/fuente/$APP_ID.yml"
flatpak build-bundle "$WORK/repo" "$DIST/tolochafuel-linux-x64.flatpak" \
  "$APP_ID" --runtime-repo=https://flathub.org/repo/flathub.flatpakrepo
rm -rf "$WORK"

echo "==> Listo"
ls -lh "$DIST"/tolochafuel-linux-x64.*
