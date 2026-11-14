# Proposal

## Why

El Flatpak publicado con TolochaFuel usa `org.gnome.Platform` 46, que terminó su vida
útil el 17 de abril de 2025. Al actualizar, Flatpak avisa de que la app depende de un
runtime sin soporte y de las extensiones `org.freedesktop.Platform.GL.default` y
`VAAPI.Intel` 23.08, también obsoletas. Es un problema de seguridad y mantenimiento: la
app funciona, pero deja de recibir correcciones del runtime.

## What Changes

- El manifiesto Flatpak pasa de `org.gnome.Platform`/`org.gnome.Sdk` 46 a la rama 51,
  que es la soportada actualmente en Flathub.
- El job `linux` de `release.yml` instala `org.gnome.Platform//51` y
  `org.gnome.Sdk//51` en lugar de la rama 46.
- La siguiente release reconstruye el Flatpak contra GNOME 51; al actualizar, desaparecen
  los avisos de GNOME 46 y de las extensiones Freedesktop 23.08.
- No cambia el código Dart, la API, los datos ni el comportamiento de la app.
- Plataforma afectada: solo Linux/Flatpak. Android y Windows no cambian.

## Capabilities

### New Capabilities

_(ninguna)_

### Modified Capabilities

_(ninguna: es un cambio de empaquetado; no cambia el comportamiento observable de la app,
por lo que el change declara `skip_specs: true`)_

## Impact

- `packaging/linux/io.github.izquierdojl.TolochaFuel.yml`: `runtime-version` 46 → 51.
- `.github/workflows/release.yml`: runtime y SDK instalados en el job `linux` 46 → 51.
- Release nueva (patch) con `tolochafuel-linux-x64.flatpak` reconstruido.
- Sin dependencias Dart nuevas, sin cambios en CI de PR ni en el resto de plataformas.

## Fuera de alcance

- Migrar la app de GTK3 a GTK4 o cambiar el framework de UI.
- Cambiar el empaquetado tar.gz o AppImage.
- Publicar la app en Flathub; se sigue distribuyendo el bundle en GitHub Releases.
- Cambios funcionales, de datos o de atribución.
- Limpiar automáticamente runtimes antiguos en las máquinas de los usuarios.
