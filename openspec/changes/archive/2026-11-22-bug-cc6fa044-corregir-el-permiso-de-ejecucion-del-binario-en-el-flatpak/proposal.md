# Proposal

## Why

El manifiesto Flatpak copia el bundle de Flutter con `cp -r` y confía en que el
binario llegue con el bit de ejecución. Si el bundle pierde ese permiso (por ejemplo,
al pasar por un artefacto de GitHub Actions, como ocurre en tolochameteo, o al copiarlo
a mano con modo `0644`), el paquete instala `/app/bin/tolochafuel` sin permiso de
ejecución y `flatpak run io.github.izquierdojl.TolochaFuel` falla con
`Permiso denegado`.

Hoy el Flatpak de TolochaFuel se construye en el mismo job que compila el bundle
(`release.yml`, job `linux`), por lo que la release publicada no está afectada; el
riesgo es latente y depende de cómo se obtenga el bundle. El arreglo hace el
empaquetado autosuficiente, igual que en tolochameteo.

## What Changes

- Añadir `chmod +x /app/bin/tolochafuel` a las `build-commands` del manifiesto
  Flatpak, justo después de copiar el bundle.
- Normalizar el permiso del binario del bundle en `packaging/linux/empaquetar.sh`
  antes de generar los paquetes, para que `tar.gz`, AppImage y Flatpak se construyan
  siempre desde un binario ejecutable.
- Verificar en local que un bundle sin bit de ejecución queda ejecutable tras aplicar
  la secuencia del manifiesto.

## Capabilities

No cambia el comportamiento de la app: es un arreglo del empaquetado Linux. Se marca
`skip_specs: true`.

## Impact

- `packaging/linux/io.github.izquierdojl.TolochaFuel.yml`.
- `packaging/linux/empaquetar.sh`.
- Sin cambios en código Dart, dependencias de la app ni datos.

## Fuera de alcance

- Republicar o reetiquetar la release existente; el arreglo entra en la próxima release.
- Cambiar el layout de instalación, el runtime GNOME o los permisos del sandbox.
- Modificar los paquetes de Android o Windows.
- Alterar el comportamiento de la app o del resto de formatos de Linux.
