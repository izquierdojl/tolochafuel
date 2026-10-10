# Design

## Context

El emblema Tolocha ya existe como SVG plano (`assets/icons/tolocha.svg`, 64×64) y se usa en
la cabecera in-app. Los recursos de lanzador de Android (`mipmap-*/ic_launcher.png`), el
`.ico` de Windows y los iconos de web son todavía los genéricos de `flutter create`. El
stack está cerrado en AGENTS.md, por lo que añadir una dev-dependency exige decisión
explícita del usuario; ya está tomada (`flutter_launcher_icons`). Ver `proposal.md` para la
motivación.

## Goals / Non-Goals

**Goals:**

- Icono de lanzador Tolocha reproducible en Android y Windows, coherente en web.
- Nombre visible «TolochaFuel» en todas las plataformas activas.
- Una sola fuente de verdad de la marca (el SVG) más un PNG fuente versionado.

**Non-Goals:**

- iOS, splash screen y themed icons de Android 13+.
- Rediseñar el emblema.

## Decisions

- **`flutter_launcher_icons` como dev-dependency**: genera de forma repetible todos los
  tamaños y piezas por plataforma desde un PNG, en lugar de crear a mano decenas de
  PNG/ICO. Alternativa descartada: generar los binarios offline sin dependencia, menos
  reproducible y sin configuración verificable en el repo.
- **PNG fuente 1024×1024** en `assets/branding/app_icon.png`, renderizado desde
  `tolocha.svg` (p. ej. `rsvg-convert`/Inkscape) y commiteado. El SVG sigue siendo la
  fuente de verdad; el PNG es solo el insumo del generador, que no acepta SVG.
- **Icono adaptativo de Android**: `adaptive_icon_foreground` = emblema con margen de
  seguridad sobre fondo transparente; `adaptive_icon_background` = pine oscuro
  (`#08100B`, Pine950 de la paleta) para respetar el tema; se conserva el PNG legacy
  (`image_path`) para API < 26.
- **Nombre visible**: `android:label="TolochaFuel"`; en web `name`/`short_name` y `<title>`
  a «TolochaFuel»; Windows ya usa «TolochaFuel» en `Runner.rc` (se verifica, no se cambia).
- **Configuración declarada en `pubspec.yaml`** (bloque `flutter_launcher_icons`) para que
  `dart run flutter_launcher_icons` regenere todo con un comando.

## Risks / Trade-offs

- **Conversión SVG → PNG**: no hay soporte nativo en Flutter; la conversión se hace fuera
  del build. Mitigación: se versiona el PNG resultante y no se depende de la herramienta en
  CI.
- **Recorte del icono adaptativo**: usar el emblema como foreground puede recortarse en
  máscaras circulares. Mitigación: dejar margen de seguridad en el PNG y verificar en
  dispositivo.
- **Bordes del SVG**: el SVG tiene esquinas redondeadas (`rx`) pensadas para un icono
  cuadrado; al usarlo como foreground adaptativo conviene generar sin el rectángulo de
  fondo o ajustar el encuadre. Se decide en la generación del PNG fuente.

## Open Questions

_Ninguna._
