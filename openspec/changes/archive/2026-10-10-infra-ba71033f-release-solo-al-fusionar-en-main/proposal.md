# Proposal

## Why

Hoy `version.yml` se dispara en cada push a `dev`: cualquier integración genera bump de
versión, tag y release (APK). Eso produce un release por cambio y consume minutos de GitHub
sin necesidad. Se quiere que el versionado y la publicación del APK ocurran **solo al
fusionar en `main`** (producción), dejando `dev` como rama de integración sin releases.

## What Changes

- `version.yml`: disparar solo en `push` a `main` y publicar el commit/tag en `main` (hoy
  `dev`).
- `ci.yml`: mantener `pull_request` (dev/main) y `push` a `main`; quitar el `push` a `dev`
  para no gastar minutos de CI en cada integración.
- Actualizar `AGENTS.md` (§7, §8, §9) y `openspec/config.yaml` para reflejar el nuevo
  modelo: `dev` = integración, `main` = producción y disparador del release.
- Sin cambios en el código de la app ni en las specs de comportamiento.

## Capabilities

### New Capabilities

_(ninguna: es gobernanza/CI, no una capacidad de la app. El change declara `skip_specs: true`)_

### Modified Capabilities

_(ninguna: no cambia el comportamiento especificado. `skip_specs: true`)_

## Impact

- `.github/workflows/version.yml`, `.github/workflows/ci.yml`.
- `AGENTS.md` y `openspec/config.yaml` (convención del proyecto).
- Cambia la convención del proyecto, documentada en AGENTS.md.

## Fuera de alcance

- Protección de ramas / required checks en GitHub (configuración del remoto).
- Estrategia `workflow_dispatch` para builds manuales.
- Cambios en `release.yml` (los assets y el build del APK siguen igual).
