# Design

## Matriz de disparadores

| Evento | `calidad` | `cambios` | `linux` (solo build) | Gate | Release |
|---|---|---|---|---|---|
| PR a `dev`/`main` | sí | sí | sí, si hay código | — | — |
| Push a `dev` | sí | sí | no | — | — |
| Push a `main` | no se dispara | — | — | comprueba CI de `dev` | sí |

El push a `main` deja de ejecutar CI porque el merge ref del PR ya validó el mismo árbol.
El release no se queda sin red: `version.yml` exige que la punta de `dev` tenga CI verde.

## Gate del release

Se implementa dentro de `version.yml` con un job `comprobar` del que depende `bump`:

1. `git rev-parse HEAD^2` obtiene la punta de `dev` (segundo padre del merge).
2. Consulta `GET /repos/{repo}/actions/workflows/ci.yml/runs?head_sha=<sha>` con el
   `GITHUB_TOKEN` (`actions: read`).
3. Mientras haya ejecuciones sin concluir, espera hasta 10 min (40 intentos de 15 s): así
   un merge hecho antes de que termine la CI no se queda sin release.
4. Exige al menos una ejecución en `success` y ninguna en `failure`, `timed_out`,
   `startup_failure` o `action_required`. Las `cancelled` se ignoran (son ejecuciones
   sustituidas por un push posterior). Si algo falla, no se crea tag, release ni artefacto.

Se descartó la protección de rama porque el `bump` empuja `chore(release)` directamente a
`main` con `GITHUB_TOKEN` y quedaría bloqueado. También se descartó re-ejecutar la suite en
`version.yml`: el árbol ya se validó en `dev` y añadiría ~1,4 min por release sin señal
nueva.

Casos límite: un squash merge no tiene segundo padre y el gate falla en cerrado (no se
publica nada). Un push directo a `main` tampoco publica. Un merge desde una rama `feature`
funciona si esa punta tiene una ejecución de CI en verde, porque la consulta es por
`head_sha` y no filtra por evento.

## Por qué el build Linux sigue en el PR

El PR valida el merge ref, que es el árbol que llegará a `main`; compilar Linux ahí detecta
roturas de compilación de escritorio antes de fusionar. Lo que se saca del PR es el
empaquetado (tar.gz, AppImage, Flatpak), que solo se consume en el release y que costaba
114 s de `apt` más Flatpak y 370 MB de artefactos por cambio.

El push a `dev` no compila Linux: da feedback rápido (solo `calidad`) sin duplicar el
trabajo del PR, y el paquete se construye en el release.

## Medición

Línea base (2026-10-25, 49 ejecuciones): PR 3,1 min p50 / 4,1 min p95; `Versionado` 8,3 min
p50; `linux` 3,7 min p50; 22,4 min de runner por cambio; 3 empaquetados Linux por cambio;
967 MB de artefactos.

Objetivo: PR ≤ 1,8 min p50, 0 ejecuciones de CI en push a `main`, 1 empaquetado por
release, 0 artefactos `linux-ci` y 0 releases sin CI verde. Se re-mide con
`gh run list --json` tras 5 PRs, sin cambiar el método.
