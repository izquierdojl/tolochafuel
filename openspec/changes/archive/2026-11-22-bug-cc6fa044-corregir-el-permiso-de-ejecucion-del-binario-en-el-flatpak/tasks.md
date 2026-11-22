# Tasks

## 1. Corrección del empaquetado

- [x] 1.1 Añadir `chmod +x /app/bin/tolochafuel` al manifiesto Flatpak y validar el
  YAML
- [x] 1.2 Normalizar el permiso del binario del bundle en `empaquetar.sh` y validar el
  script con `bash -n`

## 2. Verificación

- [x] 2.1 Simular un bundle sin bit de ejecución y comprobar que la secuencia del
  manifiesto deja el binario ejecutable
- [x] 2.2 Ejecutar `npm run verify` (formato, análisis, tests y checks de OpenSpec) en
  verde

## Workflow follow-up

- Fusionar el change en `dev`, preparar la siguiente release y comprobar que
  `flatpak run io.github.izquierdojl.TolochaFuel` arranca desde el `.flatpak` publicado.
- Archivar el change tras la verificación.
