# Design

## Context

`version.yml` se dispara en push a `dev` y encadena `bump.js` → tag `vX.Y.Z` →
`release.yml`. `ci.yml` corre en `pull_request` y en `push` a `dev`/`main`; commitlint solo
en PRs. Ver `proposal.md` para la motivación.

## Goals / Non-Goals

**Goals:**

- Un solo release por fusión en `main`; `dev` sin releases ni CI en push.
- Gobernanza (AGENTS.md, config) coherente con el nuevo modelo.

**Non-Goals:**

- Protección de ramas y required checks.
- Builds manuales por `workflow_dispatch`.

## Decisions

- **`version.yml` en `main`**: `on.push.branches: [main]` y publicar el bump con
  `git push origin HEAD:main --follow-tags` (hoy `dev`). Se mantiene el `if` que evita
  re-disparar cuando el commit es `chore(release)`.
- **`ci.yml`**: `push: [main]` + `pull_request: [dev, main]`. El `push` a `dev` se elimina
  para no gastar minutos; commitlint sigue solo en PR.
- **Documentar en `AGENTS.md`** el nuevo modelo, porque la gobernanza prevalece sobre los
  skills y no debe quedar desactualizada.
- Alternativa descartada: mantener el release en `dev` y filtrar por etiquetas; no reduce el
  número de releases.

## Risks / Trade-offs

- **El bump commitea en `main`**: requiere `permissions: contents: write` (ya presente) y
  que `main` acepte el push del bot.
- **`dev` sin CI en push**: menos minutos, pero un push directo a `dev` no se valida hasta
  el PR a `main`; los PRs a dev sí corren CI.
- **Histórico**: los tags existentes se conservan; `bump.js` parte del último tag.

## Open Questions

_Ninguna._
