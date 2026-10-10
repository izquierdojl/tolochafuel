# Proposal

## Why

La pantalla única actual esconde la búsqueda cuando la ubicación funciona: la lupa solo
aparece en modo manual, y no hay forma de llegar a una búsqueda por provincia ni a las
estaciones más económicas. Un menú lateral estilo Material da acceso permanente a todas
las secciones y un lugar natural para la configuración (tema, radio y pantalla inicial) y
el «Acerca de…» con la atribución obligatoria.

## What Changes

- Menú lateral (Drawer) en la cabecera con las secciones: **Cercanas**, **Favoritas**,
  **Buscar**, **Más económicas** y **Configuración**.
- Nueva sección «Buscar»: búsqueda por municipio o provincia **siempre accesible** (deja
  de ser solo el fallback sin ubicación), con la lista de las más baratas del territorio.
- Nueva sección «Más económicas»: las estaciones más baratas en el radio configurado
  alrededor de la ubicación actual, ordenadas por precio (Gasolina 95), con distancia,
  frescura de datos y atribución.
- Nueva sección «Configuración»: tema claro/oscuro, radio de búsqueda (10–50 km, límite
  de la API), pantalla inicial de la app y «Acerca de…» con la atribución CC BY 4.0 y la
  explicación de los datos que hoy vive al pie. Preferencias persistidas localmente.
- El radio configurado se aplica a toda la app (Cercanas y Más económicas); la diferencia
  entre ambas es el orden: distancia frente a precio.
- Cercanas conserva su comportamiento (ubicación al abrir, orden por distancia y
  atribución); si no hay ubicación, dirige a la sección Buscar en lugar de mostrar un
  panel propio.
- La sección Favoritas la aporta el change `feature-de2139cb-favoritos`, cuyo plan de
  navegación se actualizará para integrarse en este menú en vez de la barra inferior.
- Decisión del usuario durante la aplicación: la atribución CC BY 4.0 y la frescura se
  muestran **solo en «Acerca de»**; las listas dejan de mostrar el pie (se actualizan
  AGENTS.md y las specs).

## Capabilities

### New Capabilities

- `navegacion-principal`: menú lateral con las secciones de la app, sección inicial
  configurable y conservación del estado al cambiar de sección.
- `configuracion`: preferencias locales (tema, radio de búsqueda y pantalla inicial) y
  sección «Acerca de» con atribución, licencia y explicación de los datos.

### Modified Capabilities

- `gasolineras-cercanas`: el radio de búsqueda proviene de la configuración (10–50 km);
  la búsqueda manual por municipio o provincia pasa a la sección Buscar, siempre
  disponible; se añade la sección «Más económicas» (cercanas ordenadas por precio); se
  retira el pie de frescura y atribución.
- `favoritos`: la sección deja de mostrar la atribución en su pie (vive en «Acerca de»).

## Impact

- Código: `lib/app` (shell con Drawer y pantalla inicial), `lib/features/configuracion/`
  (`data/` + `ui/`), `lib/features/cercanas/` (controlador y widgets reutilizados por
  Buscar y Más económicas) y `lib/main.dart` (provider de ajustes y `themeMode` reactivo).
- Dependencia: `shared_preferences` para persistir las preferencias (ya prevista en el
  change de favoritos; se añade también aquí si no estuviera).
- API: `/v1/search` (territorios) y `/v1/stations/cheapest` con `lat`, `lng`, `radius_km`
  y `fuel=gasoline_95`; ningún endpoint fuera de la API pública. Sin permisos nuevos.
- Plataformas: todas. Android es la principal; en Windows el fallback manual funciona a
  través de la sección Buscar.
- Changes relacionados: `feature-de2139cb-favoritos` (se actualizará para usar el menú)
  y `feature-4215e734-navegacion-a-gasolinera` (el botón «Navegar» de las tarjetas se
  reutiliza sin cambios).

## Fuera de alcance

- Radio mayor de 50 km por petición (límite de la API): no se trocea el área ni se
  agregan consultas; el máximo configurable es 50 km.
- Selector de carburante: «Más económicas» sigue ordenando por Gasolina 95, como el
  ranking territorial actual, y lo indica en pantalla.
- Enrutador externo (`go_router` u otro), deep links y navegación web/iOS.
- Rediseño de la paleta o la tipografía; se mantiene el tema existente.
- Notificaciones, historial de precios y filtros por marca u horario.
- Número de versión dinámico en «Acerca de» (requeriría una dependencia nueva).
