# favoritos Specification

## Purpose
Mantiene localmente las gasolineras favoritas del usuario y permite consultar sus precios
actualizados sin depender de la ubicación ni de repetir búsquedas.

## Requirements

### Requirement: Marcar y desmarcar favoritos

La app SHALL permitir marcar y desmarcar cualquier gasolinera como favorita desde la
lista, reflejando el cambio de estado de inmediato en la interfaz.

#### Scenario: Marcar una gasolinera

- **WHEN** el usuario pulsa el icono de favorito de una gasolinera no marcada
- **THEN** la gasolinera queda marcada y el icono cambia de estado

#### Scenario: Desmarcar una gasolinera

- **WHEN** el usuario pulsa el icono de una gasolinera ya marcada
- **THEN** la gasolinera deja de ser favorita y desaparece de la sección Favoritos

### Requirement: Persistencia local

Los favoritos SHALL almacenarse únicamente en el dispositivo (`shared_preferences`) con
identidad suficiente para su consulta (al menos `id`, rótulo, dirección y coordenadas), y
SHALL conservarse entre ejecuciones de la app.

#### Scenario: Reapertura de la app

- **WHEN** el usuario cierra y vuelve a abrir la app
- **THEN** las gasolineras marcadas siguen apareciendo como favoritas

#### Scenario: Sin conexión no se pierden marcas

- **WHEN** el usuario marca un favorito y después abre la app sin conexión
- **THEN** el favorito sigue listado (su precio se mostrará cuando haya conexión)

### Requirement: Sección Favoritos con precio vigente

La app SHALL ofrecer una sección «Favoritos» que liste las gasolineras marcadas y muestre
su precio consultando la API por identificador (`/v1/stations/{id}`); la atribución
completa vive en Configuración → Acerca de.

#### Scenario: Consulta de precios

- **WHEN** el usuario abre la sección Favoritos
- **THEN** ve cada gasolinera marcada con su precio vigente

#### Scenario: Favorito sin conexión

- **WHEN** la consulta del precio de un favorito falla
- **THEN** se muestra la gasolinera con un indicador de precio no disponible y opción de
  reintentar

### Requirement: Estado vacío de Favoritos

La sección SHALL mostrar un estado vacío en español cuando no haya gasolineras marcadas,
explicando cómo añadirlas.

#### Scenario: Primera visita sin favoritos

- **WHEN** el usuario abre Favoritos sin haber marcado ninguna gasolinera
- **THEN** se muestra un mensaje que indica marcar desde la lista de cercanas
