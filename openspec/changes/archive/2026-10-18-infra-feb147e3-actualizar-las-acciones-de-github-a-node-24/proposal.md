# Proposal

## Why

Los runners de GitHub Actions ya ejecutan Node 24 y avisan en cada ejecución de que las
acciones que declaran `runs.using: node20` se fuerzan a correr sobre Node 24:
`actions/checkout@v4`, `actions/setup-node@v4`, `actions/upload-artifact@v4` y
`actions/download-artifact@v4`. Es una deprecación anunciada: cuando GitHub retire el
soporte de acciones node20, los workflows dejarán de funcionar. Hoy solo ensucia los
logs, pero la actualización es barata y conviene hacerla con margen.

## What Changes

- Subir las cuatro acciones a la primera *major* que declara `node24` en su `action.yml`
  (comprobado consultando sus repositorios):
  - `actions/checkout`: `@v4` → `@v7`
  - `actions/setup-node`: `@v4` → `@v7`
  - `actions/upload-artifact`: `@v4` → `@v7` (ojo: `@v5` todavía declara node20)
  - `actions/download-artifact`: `@v4` → `@v8` (ojo: `@v6` todavía declara node20)
- Aplicarlo en los cuatro workflows afectados: `ci.yml`, `version.yml`, `release.yml` y
  `copilot-setup-steps.yml`.
- `subosito/flutter-action@v2` se mantiene: es una acción compuesta, sin runtime de Node.
- Sin cambios en la versión de Node del proyecto: `.nvmrc` (22) y `engines: >=22` siguen
  igual; eso es el Node que ejecutan `commitlint` y `scripts/bump.js`, no el de las
  acciones.

## Capabilities

_(cambio de tooling de CI: no cambia el comportamiento de la app, por lo que no modifica
specs; el change declara `skip_specs: true`)_

## Impact

- `.github/workflows/{ci,version,release,copilot-setup-steps}.yml` (versiones de las
  acciones).
- Sin cambios en código Dart, `pubspec`, Android/Windows/Linux ni en los assets de las
  releases: los nombres y el contenido de los artefactos publicados no varían.
- Plataformas: todas por igual (el comportamiento de la app no difiere).
- Verificación: PR a `dev` (CI `calidad` + `linux`) y, tras fusionar en `main`, una
  ejecución de `version.yml`/`release.yml` para confirmar que bump, tag y publicación
  siguen funcionando con las acciones nuevas.

## Fuera de alcance

- Migrar de `ubuntu-latest`/`windows-latest` a etiquetas nuevas (el otro aviso de los
  runners se resolverá solo cuando GitHub cambie la etiqueta).
- Fijar las acciones por SHA en lugar de por etiqueta mayor.
- Añadir Dependabot o Renovate para mantener las acciones al día.
- Cambiar la versión de Node del proyecto (`.nvmrc`, `engines`) o de `flutter-action`.
- Tocar `AGENTS.md` §9 (describe los workflows, no las versiones de las acciones).
