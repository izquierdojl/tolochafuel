# Proposal

## Why

El README actual es una nota para desarrolladores: requisitos, comandos de Flutter y
enlaces de descarga, sin explicar qué ve ni qué gana quien usa la app. TolochaFuel ya
está en la versión 0.9.2 y publica APK, ZIP para Windows y tres formatos para Linux, pero
quien llega desde GitHub no puede hacerse una idea de la aplicación ni de su aspecto. La
documentación técnica y la guía de uso tampoco existen todavía.

Además, no hay fichero `LICENSE` pese a la decisión de licenciar el código bajo MIT. Los
datos de la API siguen bajo CC BY 4.0 con atribución obligatoria, y esa diferencia entre
la licencia del código y la de los datos no está explicada en el repositorio ni en la
pantalla «Acerca de» de la app.

## What Changes

- Añadir `LICENSE` con la licencia **MIT** (titular: TolochaFuel, año 2026) para el
  código del repositorio.
- Reescribir `README.md` con un enfoque divulgativo: qué es TolochaFuel, qué permite
  hacer, galería de capturas, descarga por plataforma, nota breve sobre los datos y la
  atribución, índice de documentación y licencia. Los comandos de desarrollo y los
  detalles técnicos salen del README.
- Añadir capturas de pantalla de ejemplo de la app Android en tema claro (Cercanas,
  histórico, Más económicas, Favoritas, Buscar y Configuración/Acerca de) y una muestra
  del tema oscuro, guardadas en `docs/assets/capturas/`.
- Crear `docs/` con documentación interior: índice, guía de uso, instalación por
  plataforma, datos y licencias, arquitectura y desarrollo/release.
- Mostrar la licencia MIT del código en Configuración → Acerca de, separada de la
  licencia CC BY 4.0 de los datos, y actualizar el widget test correspondiente.
- Actualizar `AGENTS.md` para dejar por escrito que el código es MIT y que los datos
  conservan la CC BY 4.0 con atribución.

## Capabilities

### New Capabilities

_(ninguna: el change es de documentación y presentación del repositorio; no introduce
una capacidad de producto nueva)_

### Modified Capabilities

- `configuracion`: el requisito de la sección «Acerca de» pasa a exigir también la
  licencia MIT del código, diferenciada de la licencia CC BY 4.0 de los datos.

## Impact

- `README.md` (reescritura completa).
- `LICENSE` (nuevo) y `AGENTS.md` (§4 y §11).
- `docs/README.md`, `docs/uso.md`, `docs/instalacion.md`, `docs/datos.md`,
  `docs/arquitectura.md`, `docs/desarrollo.md` y `docs/licencia.md` (nuevos).
- `docs/assets/capturas/*.png` (nuevas, optimizadas para el repositorio).
- `lib/features/configuracion/ui/acerca_de_pantalla.dart` y
  `test/features/configuracion_pantalla_test.dart`.
- Sin cambios en la API, los datos, las dependencias ni el comportamiento de las listas.
- Plataformas afectadas: todas en la pantalla «Acerca de» (UI compartida); las capturas
  se toman en Android, la plataforma principal.

## Fuera de alcance

- Cambiar la licencia de los datos: siguen bajo CC BY 4.0 con atribución a Gasolina hoy y
  al Ministerio para la Transición Ecológica y el Reto Demográfico.
- Publicar una release, subir la versión o tocar el flujo de versionado; el merge a
  `main` seguirá disparando el release automático.
- Configurar la descripción o la imagen social del repositorio en GitHub (requiere la
  interfaz o la API de GitHub, no un fichero del repo).
- Traducir el README a otros idiomas.
- Rediseñar pantallas de la app, añadir funcionalidades o cambiar textos de uso.
- Capturas de iOS o web (plataformas aplazadas) y vídeos o GIF promocionales.
- Reescribir `assets/branding/README.md` ni regenerar iconos de plataforma.
