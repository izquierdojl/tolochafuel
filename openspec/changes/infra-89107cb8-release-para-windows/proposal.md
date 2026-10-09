# Proposal

## Why

TolochaFuel es multiplataforma y Windows es la plataforma secundaria acordada: debe poder
descargarse e instalarse con la misma facilidad que el APK. Hoy `release.yml` solo publica
Android.

## What Changes

- Nuevo job `windows` en `release.yml` (runner `windows-latest`): `flutter build windows
  --release` y empaquetado ZIP portable (`tolochafuel-windows-x64.zip`).
- El publicador de releases adjunta el ZIP junto al APK, con nombres estables para enlaces
  de descarga directa.
- Metadatos del ejecutable en `windows/runner` (nombre del producto y versión tomada de
  `pubspec.yaml`).
- README con los enlaces de descarga de ambas plataformas.

## Capabilities

_(cambio de tooling: no cambia el comportamiento de la app, por lo que no modifica
specs; el change declara `skip_specs: true`)_

## Impact

- `.github/workflows/release.yml` (job nuevo y assets del publicador).
- `windows/runner/Runner.rc` y recursos del ejecutable.
- `README.md` (sección Distribución).
- Sin cambios en el código Dart ni en Android.

## Fuera de alcance

- Instalador MSIX o firma de código del ejecutable (evaluable como change futuro).
- Publicación en Microsoft Store.
- Build de Windows fuera de CI (WSL no compila Windows; local exige Visual Studio).
- Firma de producción del APK (sigue aplazada según AGENTS.md).
