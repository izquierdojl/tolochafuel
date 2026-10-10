# navegacion-principal Specification

## Purpose

Da acceso permanente desde la cabecera a todas las secciones de la app mediante un menú
lateral Material, con una sección inicial configurable y el estado de cada sección
conservado al cambiar entre ellas.

## Requirements

### Requirement: Menú lateral de secciones

La app SHALL mostrar en la cabecera un botón de menú (hamburguesa) que abre un Drawer
Material con las secciones Cercanas, Favoritas, Buscar, Más económicas y Configuración.
La sección activa SHALL distinguirse visualmente y el Drawer SHALL cerrarse al elegir una
sección.

#### Scenario: Abrir el menú

- **WHEN** el usuario pulsa el botón de menú de la cabecera
- **THEN** se abre el Drawer con las cinco secciones y la sección activa resaltada

#### Scenario: Cambiar de sección

- **WHEN** el usuario elige una sección distinta en el Drawer
- **THEN** el Drawer se cierra y la app muestra la sección elegida

### Requirement: Sección inicial configurable

La app SHALL abrir la sección indicada en la configuración (Cercanas, Favoritas, Buscar o
Más económicas); si no hay preferencia guardada, SHALL abrir Cercanas.

#### Scenario: Arranque sin preferencia

- **WHEN** el usuario abre la app y no ha elegido una pantalla inicial
- **THEN** se muestra la sección Cercanas

#### Scenario: Arranque con preferencia

- **WHEN** el usuario ha elegido otra pantalla inicial en Configuración
- **THEN** la app abre esa sección al iniciarse

### Requirement: Conservación del estado entre secciones

Al cambiar de sección, el estado de las demás SHALL conservarse durante la sesión —
resultados, listados y posición—, y las peticiones ya resueltas SHALL reutilizarse desde
la caché en memoria sin volver a consultar la API.

#### Scenario: Volver a una sección ya cargada

- **WHEN** el usuario visita Cercanas, cambia a Buscar y vuelve a Cercanas sin modificar
  ubicación ni radio
- **THEN** la lista se muestra de inmediato sin repetir las peticiones a la API

#### Scenario: Estado de búsqueda conservado

- **WHEN** el usuario ha buscado un municipio en Buscar, cambia de sección y regresa
- **THEN** la búsqueda y sus resultados siguen visibles

### Requirement: Integración de la sección Favoritas

La sección Favoritas SHALL estar disponible en el menú y mostrar la pantalla de favoritos
de la capacidad `favoritos`, sin barra de navegación inferior propia.

#### Scenario: Acceso a favoritos desde el menú

- **WHEN** el usuario elige Favoritas en el Drawer
- **THEN** se muestra la pantalla de favoritos dentro del mismo shell de navegación
