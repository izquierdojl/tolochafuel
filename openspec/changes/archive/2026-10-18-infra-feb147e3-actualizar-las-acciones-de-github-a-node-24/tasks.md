# Tasks

## 1. Acciones de GitHub a Node 24

- [x] 1.1 En `.github/workflows/ci.yml`, subir `actions/checkout@v4` → `@v7` y `actions/setup-node@v4` → `@v7`; verificación: `grep -nE "actions/(checkout|setup-node)@" .github/workflows/ci.yml` muestra solo las versiones nuevas
- [x] 1.2 En `.github/workflows/version.yml`, subir `actions/checkout@v4` → `@v7` y `actions/setup-node@v4` → `@v7`; verificación: `grep -nE "actions/(checkout|setup-node)@" .github/workflows/version.yml` muestra solo las versiones nuevas
- [x] 1.3 En `.github/workflows/release.yml`, subir `actions/checkout@v4` → `@v7`, `actions/upload-artifact@v4` → `@v7` y `actions/download-artifact@v4` → `@v8`; verificación: `grep -nE "actions/(checkout|upload-artifact|download-artifact)@" .github/workflows/release.yml` muestra solo las versiones nuevas
- [x] 1.4 En `.github/workflows/copilot-setup-steps.yml`, subir `actions/checkout@v4` → `@v7`; verificación: `grep -nE "actions/checkout@" .github/workflows/copilot-setup-steps.yml` muestra solo la versión nueva

## 2. Verificación previa al archivo

- [x] 2.1 Comprobar que no queda ninguna acción en `@v4` en `.github/workflows/` y que `subosito/flutter-action` sigue en `@v2` (`grep -rnE "uses: .*@v4$" .github/workflows/`), y que `flutter analyze` + `flutter test` siguen en verde y `dart format .` no cambia nada (el código Dart no se toca en este change)

## Workflow follow-up

- Archivar el change (no tiene specs: `skip_specs`), commitear en `dev` con `git status` limpio y abrir el PR `dev → main`.
- Comprobar en el PR que CI (`calidad` + `linux`) pasa y que los jobs ya no muestran el aviso de Node 20; fusionar en `main` y confirmar que `version.yml` (bump + tag) y `release.yml` (5 assets) completan sin el aviso.
