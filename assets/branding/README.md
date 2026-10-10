# Assets de marca

Fuente de verdad de la marca: `assets/icons/tolocha.svg` (el mismo emblema de la cabecera
in-app). Los PNG de este directorio se derivan del SVG y se versionan; se generan con
[`sharp-cli`](https://www.npmjs.com/package/sharp-cli) vía `npx`, por lo que no añaden
dependencias al proyecto.

## Regenerar los PNG

```bash
npx --yes sharp-cli -i assets/icons/tolocha.svg -o assets/branding/app_icon.png resize 1024 1024
npx --yes sharp-cli -i assets/branding/app_icon_foreground.svg -o assets/branding/app_icon_foreground.png resize 1024 1024
```

- `app_icon.png`: icono completo (fondo pine + emblema). Insumo de Android legacy, Windows y
  web.
- `app_icon_foreground.svg` / `.png`: solo el emblema sobre fondo transparente. Foreground
  del icono adaptativo de Android.

## Regenerar los iconos de plataforma

```bash
dart run flutter_launcher_icons
```

La configuración vive en el bloque `flutter_launcher_icons` de `pubspec.yaml`.
