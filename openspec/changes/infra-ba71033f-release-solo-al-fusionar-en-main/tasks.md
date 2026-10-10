# Tasks

## 1. Workflows

- [x] 1.1 `version.yml`: `on.push.branches: [main]` y push del bump a `main`
  (`HEAD:main --follow-tags`); verificar que el YAML es válido
- [x] 1.2 `ci.yml`: dejar `push: [main]` y `pull_request: [dev, main]`, y quitar el push a
  `dev`; verificar que el YAML es válido

## 2. Gobernanza

- [x] 2.1 Actualizar `AGENTS.md` (§7 ramas, §8 versionado/release, §9 CI) al nuevo modelo
- [x] 2.2 Actualizar `openspec/config.yaml` para reflejar que el release se dispara en
  `main`
- [x] 2.3 `bash scripts/check_changes.sh` en verde

## Workflow follow-up

- Archivar el change tras fusionar en `main`.
