# Proposal

## Why

La auditoría del 2026-10-25 (49 ejecuciones medidas con la API de Actions) muestra trabajo
duplicado y una publicación sin red:

- Cada cambio compila y empaqueta Linux **tres veces**: PR, push a `main` y release. El job
  `linux` tarda 3,7 min (p50) y **114 s** son solo `apt` más el runtime de Flatpak; sube
  370 MB de artefactos `linux-ci` que nadie descarga (967 MB retenidos, 90 días).
- El CI del PR y el de push a `main` prueban el mismo árbol: 9 de 9 merges a `main` vienen
  de un PR, y el merge ref ya se validó.
- `version.yml` no espera a CI: en el run 39074487995 el job `android` empezó a las
  22:18:03 y el CI terminó a las 22:20:57. `main` no tiene protección de rama, así que un
  merge con CI rojo publica (pasó con el PR #1).
- `release.yml` declara `push: tags: ['v*']`, un trigger muerto para los tags que crea
  `GITHUB_TOKEN`: 11 de 12 releases salieron de `workflow_call` y solo uno de un tag manual.
- No hay `concurrency` ni `timeout-minutes`: el 2026-10-10 se acumularon dos ejecuciones del
  mismo PR y tres runs quedaron colgados unas 6,5 h sin crear jobs.

Espera actual del desarrollador: 3,1 min (p50) por PR. Minutos de runner por cambio:
22,4. El repo es público, así que el coste es espera y ruido, no factura.

## What Changes

- **CI**: se dispara en PRs a `dev`/`main` y en push a `dev`; se elimina el push a `main`
  (duplicado del merge ref). `concurrency` cancelable, `permissions: contents: read`,
  `timeout-minutes` y `setup-node`/`npm ci`/commitlint solo en PR.
- **Job `linux` del PR**: solo `flutter build linux --release`, con las dependencias
  mínimas (sin `flatpak`, `flatpak-builder`, `elfutils` ni `imagemagick`); deja de ejecutar
  `packaging/linux/empaquetar.sh` y de subir artefactos. El empaquetado se valida en el
  release, donde ya se publica.
- **Job `cambios`**: omite el build Linux cuando el diff solo toca `openspec/` o `*.md`.
- **`scripts/verificar.sh` + `npm run verify`**: un único comando con
  `check_changes.sh` + `dart format` + `flutter analyze` + `flutter test`, que es lo que
  ejecuta CI.
- **`version.yml`**: nuevo job `comprobar` que exige CI en verde para la punta de `dev`
  (segundo padre del merge) antes del `bump`; si no hay merge commit o no hay CI verde,
  aborta sin tag. `concurrency` no cancelable para no cortar un release.
- **`release.yml`**: fuera `push: tags` (queda `workflow_call` + `workflow_dispatch`),
  `contents: write` solo en `publicar`, `retention-days: 3` en los artefactos intermedios y
  `timeout-minutes` por job.

## Capabilities

_(cambio de tooling de CI/CD: no cambia el comportamiento de la app, por lo que no modifica
specs; el change declara `skip_specs: true`)_

## Impact

- `.github/workflows/{ci,version,release}.yml`, `scripts/verificar.sh` (nuevo),
  `package.json`, `AGENTS.md` (§9) y `README.md`.
- Sin cambios en código Dart, `pubspec`, plataformas ni assets: los nombres y el contenido
  de los artefactos publicados no varían, y sigue habiendo un release por merge a `main`.
- `openspec/**` no se modifica: el flujo, el esquema y los scripts de especificación siguen
  igual; este change solo los usa.
- Verificación: 5 PRs medidos contra la línea base, un release completo y una prueba de
  gate con CI en rojo.

## Fuera de alcance

- Cambiar la cadencia de versión: se mantiene un tag y un release por merge a `main`.
- Publicar o retener imágenes: no hay Docker ni registro en el proyecto.
- Añadir escaneo de seguridad por PR (CodeQL no soporta Dart); como mucho, Dependabot
  semanal en un change posterior.
- Protección de rama en `main`: bloquearía el push del commit `chore(release)` que hace el
  bot; el gate se implementa dentro de `version.yml`.
- Tocar `openspec/**`, `.github/workflows/copilot-setup-steps.yml`, `.github/skills/**`,
  `.github/prompts/**`, `.github/agents/**` ni `scripts/{check_changes,new_change,spec_id,bump}`.
- Caché de Gradle en el release: se mide en un change posterior.
