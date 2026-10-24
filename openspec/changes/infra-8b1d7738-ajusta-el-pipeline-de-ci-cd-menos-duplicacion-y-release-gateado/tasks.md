# Tasks

## 1. Red de seguridad local

- [x] 1.1 Crear `scripts/verificar.sh` con `check_changes.sh`, `dart format --output=none --set-exit-if-changed lib test`, `flutter analyze` y `flutter test`; verificación: `bash scripts/verificar.sh` termina en verde en ~18 s
- [x] 1.2 Añadir `"verify": "bash scripts/verificar.sh"` a `package.json`; verificación: `npm run verify` termina en verde
- [x] 1.3 Repetir la suite 20 veces seguidas sin fallos; verificación: `for i in $(seq 20); do npm run verify >/dev/null || exit 1; done`

## 2. Quitar duplicaciones en CI

- [x] 2.1 En `.github/workflows/ci.yml`, cambiar los disparadores a `pull_request` (`dev`, `main`) + `push` (`dev`), añadir `permissions: contents: read` y `concurrency` con `cancel-in-progress: true`; verificación: `grep -nE "branches|concurrency|permissions" .github/workflows/ci.yml`
- [x] 2.2 En `ci.yml`, ejecutar la verificación con `bash scripts/verificar.sh` y limitar `setup-node`, `npm ci` y `commitlint` a `pull_request`; verificación: revisar que el job `calidad` no instala Node en push
- [x] 2.3 En `ci.yml`, dejar el job `linux` en solo compilación (apt mínimo, sin `empaquetar.sh` ni `upload-artifact`) y condicionarlo a `pull_request`; verificación: `grep -n "empaquetar\|upload-artifact\|flatpak" .github/workflows/ci.yml` no devuelve nada
- [x] 2.4 Añadir el job `cambios` que omite `linux` cuando el diff solo toca `openspec/` o `*.md`; verificación: un PR de solo documentación no ejecuta `linux`
- [x] 2.5 Añadir `timeout-minutes` a todos los jobs de `ci.yml`; verificación: `grep -c "timeout-minutes" .github/workflows/ci.yml`

## 3. Gate del versionado

- [x] 3.1 En `.github/workflows/version.yml`, añadir el job `comprobar` que exige CI en verde para la punta de `dev` (`HEAD^2`); verificación: con un merge cuya punta de `dev` no tenga CI verde, el run falla antes del `bump`
- [x] 3.2 Encadenar `bump` con `needs: comprobar` y ajustar permisos por job (`actions: read` en `comprobar`, `contents: write` en `bump` y `publicar`); verificación: `grep -n "needs\|permissions" .github/workflows/version.yml`
- [x] 3.3 Añadir `concurrency` no cancelable al workflow; verificación: dos merges seguidos no se cancelan entre sí

## 4. Release y artefactos

- [x] 4.1 En `.github/workflows/release.yml`, quitar `push: tags` y dejar `workflow_call` + `workflow_dispatch`; verificación: `grep -n "on:" -A 6 .github/workflows/release.yml`
- [x] 4.2 Limitar `contents: write` al job `publicar` y añadir `timeout-minutes`; verificación: `grep -n "permissions" .github/workflows/release.yml`
- [x] 4.3 Añadir `retention-days: 3` a los artefactos intermedios; verificación: `grep -n "retention-days" .github/workflows/release.yml`

## 5. Documentación

- [x] 5.1 Actualizar `AGENTS.md` §9 (CI en `dev`, no en `main`; Linux solo compila en PR; gate del versionado); verificación: la sección coincide con los workflows
- [x] 5.2 Añadir `npm run verify` a los comandos de `README.md`; verificación: `grep -n "verify" README.md`

## Workflow follow-up

- Archivar el change (`skip_specs`), commitear en `dev` con `git status` limpio y abrir el PR `dev → main`.
- Medir 5 PRs con `gh run list --json name,event,createdAt,updatedAt,conclusion` y comparar con la línea base (PR 3,1 min p50; 22,4 min de runner por cambio; 3 empaquetados).
- Probar el gate: un commit que rompa `flutter test` en `dev` no debe producir tag ni release.
- Confirmar en un release completo: 5 assets, un build por plataforma y 0 artefactos `linux-ci`.
