# Design

## Context

Ver `proposal.md` para la motivación. El repositorio tiene hoy un único README técnico
de 50 líneas, sin `LICENSE` ni carpeta `docs/`, y una pantalla «Acerca de» que solo
menciona la licencia CC BY 4.0 de los datos. El proyecto hermano `izquierdojl/tolocharadio`
ya usa el patrón que se busca: README divulgativo con índice de documentación, `docs/`
interior y licencia MIT en el código.

La app se compila y prueba con Flutter 3.50.1 y publica artefactos para Android, Windows
y Linux. Las capturas se tomarán en el AVD local `Medium_Phone_API_37.0`; la app no
necesita backend propio y consume la API pública en directo.

## Goals / Non-Goals

**Goals:**

- Separar la puerta de entrada (README para quien usa o descubre la app) de la
  documentación técnica y de gobernanza (`docs/` y `AGENTS.md`).
- Dejar la licencia MIT del código por escrito en el repositorio y en la app, sin tocar
  la licencia CC BY 4.0 de los datos.
- Mostrar la app real con capturas reproducibles, ligeras y con texto alternativo.
- Evitar duplicación: el README resume y `docs/` amplía; `AGENTS.md` sigue siendo la
  constitución del desarrollo.

**Non-Goals:**

- Cambiar comportamiento, textos de uso, datos, dependencias o diseño visual de la app.
- Crear una web, un catálogo de capturas interactivo o vídeos.
- Documentar la API externa más allá de lo que la app consume y sus límites.
- Sustituir `AGENTS.md` por `docs/` ni duplicar en `docs/` las reglas de gobernanza.

## Decisions

### 1. README divulgativo con índice, documentación técnica en `docs/`

El README se reescribe con este orden: presentación y emblema, qué es TolochaFuel,
características en lenguaje de usuario, galería de capturas, descarga por plataforma,
nota de datos y atribución, tabla de documentación y licencia. Los requisitos de
desarrollo, comandos, CI, arquitectura y versionado se mueven a `docs/`.

Alternativas descartadas: añadir capturas al README actual (sigue siendo técnico y
mezcla públicos) y crear un `CONTRIBUTING.md` aparte (el proyecto es de una sola persona
y la documentación de desarrollo cabe en `docs/desarrollo.md`).

Los documentos interiores siguen el patrón de tolocharadio: cada página empieza con
«← Volver al README», usa español y enlaza a las demás cuando conviene.

| Documento | Responsabilidad |
| --- | --- |
| `docs/README.md` | Índice y para quién es cada página |
| `docs/uso.md` | Qué hace la app y cómo se usa, con capturas |
| `docs/instalacion.md` | Descarga e instalación en Android, Windows y Linux |
| `docs/datos.md` | Fuente, frescura, límites de la API y atribución |
| `docs/arquitectura.md` | Capas de `lib/`, estado, caché, red y plataformas |
| `docs/desarrollo.md` | Entorno, comandos, tests, CI, release y capturas |
| `docs/licencia.md` | MIT del código y CC BY 4.0 de los datos |

### 2. MIT para el código; CC BY 4.0 intacta para los datos

`LICENSE` en la raíz con el texto MIT estándar y «Copyright (c) 2026 TolochaFuel», el
mismo criterio que tolocharadio. El README y `docs/licencia.md` explican que la licencia
MIT cubre el código y los materiales propios del repositorio, mientras que los datos de
la API siguen bajo CC BY 4.0 y conservan la atribución obligatoria a Gasolina hoy y al
Ministerio para la Transición Ecológica y el Reto Demográfico.

`AGENTS.md` §4 pasa a titularse «Datos, límites y licencias» y añade la licencia del
código; §11 incorpora un advisory que fija la separación MIT (código) / CC BY 4.0
(datos). Así la decisión no depende de que se recuerde en cada change.

En «Acerca de» se añade un `ListTile` «Licencia MIT del código» después del de CC BY 4.0,
con subtítulo que aclara que cubre el código y enlace a `https://opensource.org/license/mit`.
Se reutiliza `_abrirEnlace` y el estilo de los tiles existentes; no se añade lógica de
negocio ni colores literales. El enlace al repositorio se mantiene.

### 3. Capturas Android reales, claras y ligeras

Se capturan nueve pantallas con el AVD `Medium_Phone_API_37.0` y la app en ejecución:

| Archivo | Pantalla | Tema |
| --- | --- | --- |
| `01-cercanas-claro.png` | Lista Cercanas con precios, distancias y pie de frescura | Claro |
| `02-historico-claro.png` | Hoja de histórico con gráfico y medias | Claro |
| `03-mas-economicas-claro.png` | Más económicas con selector de criterio | Claro |
| `04-favoritas-claro.png` | Favoritas con tres estaciones y asas de orden | Claro |
| `05-buscar-claro.png` | Buscar con resultados de un municipio | Claro |
| `06-configuracion-claro.png` | Configuración con tema, radio y pantalla inicial | Claro |
| `07-acerca-de-claro.png` | Acerca de con atribución, CC BY 4.0 y MIT | Claro |
| `08-cercanas-oscuro.png` | Cercanas en tema oscuro | Oscuro |
| `09-mas-economicas-oscuro.png` | Más económicas en tema oscuro | Oscuro |

Procedimiento reproducible (se documentará en `docs/desarrollo.md`):

1. Si el AVD principal ya está en marcha, crear un AVD clon (`TolochaFuel_Capturas`) y
   arrancarlo en otro puerto; una instancia `-read-only` sobre un AVD cuyo otro proceso no
   es read-only se rechaza. Esperar a `adb wait-for-device`.
2. Fijar una ubicación pública y genérica de Madrid con
   `adb emu geo fix -3.7038 40.4168` (longitud, latitud) y conceder los permisos de
   ubicación con `adb shell pm grant com.izquierdojl.tolochafuel ...`.
3. Abrir la app, esperar a que carguen los precios y navegar por las secciones. Marcar
   tres favoritas para la captura de Favoritas. Para el histórico, abrir una fila de
   precio con datos y desplegar el gráfico.
4. Capturar con `adb exec-out screencap -p > captura.png`.
5. Recortar la barra de estado, redimensionar a 540 px de ancho, eliminar metadatos y
   optimizar con ImageMagick y `optipng`; guardar en `docs/assets/capturas/`.

Se usan PNG (no WebP) por compatibilidad con cualquier visor y con el renderizado de
GitHub; el límite de 540 px mantiene el detalle en la galería y deja el total por debajo
de ~1,5 MB. No se capturan datos personales: la ubicación es el centro de Madrid y el
estado del sistema se deja limpio. Las capturas son ilustrativas: los precios cambian
dos veces al día y no se actualizan solas.

En el README se muestran en dos tablas HTML de tres columnas (claro) y dos columnas
(oscuro), con `alt` descriptivo en español y pie de foto. En `docs/uso.md` se reutilizan
las mismas imágenes por pantalla, sin duplicar archivos.

### 4. Verificación de enlaces y tono

Los enlaces internos serán relativos (`docs/...`, `../README.md`) y se comprobarán con un
script puntual de Python que extrae destinos Markdown y verifica que el fichero existe;
no se añade una dependencia de Node para esto. Los enlaces externos se limitan a GitHub,
la API, Creative Commons y Open Source Initiative.

El README no incluirá comandos de desarrollo ni badges de servicios externos; la
descarga se resuelve con enlaces directos a `releases/latest/download/...`, que ya usan
nombres estables.

## Risks / Trade-offs

- **Datos de ejemplo desactualizados o poco representativos** → capturar tras una
  actualización de la API, revisar que no haya errores ni listas vacías y repetir la
  captura si sale un estado raro. Las capturas se presentan como ilustrativas.
- **La ubicación o el permiso del emulador fallan** → conceder permisos por `adb` y
  documentar el comando; si el emulador no coopera, usar la sección Buscar como
  respaldo, pero las capturas principales deben ser de Cercanas.
- **Peso del repositorio** → 540 px, `-strip`, compresión PNG y `optipng`; revisar el
  tamaño total antes de commitear.
- **Ambigüedad de licencias** → texto explícito y separado en README, `docs/licencia.md`
  y «Acerca de»; la licencia de los datos no se modifica.
- **Enlaces rotos al mover contenido** → comprobación automática puntual y revisión
  manual de la tabla de documentación.
- **El test de «Acerca de» se vuelve frágil** → se comprueba la presencia de las dos
  licencias por texto, sin probar la apertura de URLs externas.
- **Capturas que envejecen** → procedimiento documentado para regenerarlas cuando cambie
  la UI; no se promete que reflejen la última versión.

## Migration Plan

No hay migración de datos ni de usuarios. Orden de implementación: licencia y «Acerca
de» (cambio pequeño y verificable), documentación interior, capturas, README y
verificación final con `npm run verify`. Si algo falla, se revierte el commit del change;
la app sigue funcionando igual porque solo cambian textos de «Acerca de» y documentación.

## Open Questions

Ninguna: las decisiones de alcance (MIT solo para código, capturas Android en claro y
oscuro, mención en «Acerca de») se resolvieron con el usuario antes de proponer.
