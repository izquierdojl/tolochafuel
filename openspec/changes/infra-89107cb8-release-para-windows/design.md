# Design

## Context

`release.yml` ya construye y publica el APK en GitHub Releases vía `gh release` con
nombres de asset estables. Los runners de GitHub incluyen Visual Studio con el workload
C++ de escritorio, requisito de `flutter build windows`. La app ya trae la carpeta
`windows/` generada por `flutter create`. Ver `proposal.md` para la motivación.

## Goals / Non-Goals

**Goals:**

- ZIP portable publicado automáticamente en cada release, junto al APK.
- Nombres estables: `tolochafuel-windows-x64.zip` (enlace `releases/latest/download/...`).
- Metadatos correctos del ejecutable (nombre «TolochaFuel», versión de `pubspec.yaml`).

**Non-Goals:**

- Firma de código y SmartScreen (se documentará el aviso al usuario en el README).
- Instalador (MSIX/Inno Setup).

## Decisions

- **Job separado `windows`** en `release.yml` que sube el ZIP como artefacto; el job
  `publicar` espera a `android` y `windows` y adjunta ambos assets. Un fallo de Windows
  bloquea el release: plataforma secundaria pero verificada en CI (advisory 3 de AGENTS.md).
- **`Compress-Archive`** (PowerShell del runner) en lugar de `zip` externo: disponible por
  defecto y sin dependencias.
- **Versión del ejecutable**: Flutter toma `version:` de `pubspec.yaml` para las
  propiedades del producto en Windows; se verifica `Runner.rc` y se ajusta el nombre del
  producto a «TolochaFuel» si el scaffold deja otro.
- **Solo CI compila Windows**: se documenta en README que desde WSL no se puede compilar;
  para probar localmente se necesita Windows con Visual Studio.
- **Idempotencia**: el publicador usa `gh release upload --clobber`/`create` como en
  Android, por lo que un re-run no duplica assets.

## Risks / Trade-offs

- **Minutos de CI**: el runner Windows consume minutos ×2 en repos privados; aceptable por
  ser un merge a `dev` puntual (1 por release).
- **ZIP sin firma**: SmartScreen puede avisar al primer arranque; se documenta como
  limitación conocida hasta que exista firma de código.
