# Spec Delta

## MODIFIED Requirements

### Requirement: Sección Favoritos con precio vigente

La app SHALL ofrecer una sección «Favoritos» que liste las gasolineras marcadas y muestre
su precio consultando la API por identificador (`/v1/stations/{id}`); la atribución
completa vive en Configuración → Acerca de.

#### Scenario: Consulta de precios

- **WHEN** el usuario abre la sección Favoritos
- **THEN** ve cada gasolinera marcada con su precio vigente

#### Scenario: Precio cargado al marcar

- **WHEN** el usuario marca una gasolinera como favorita desde cualquier lista
- **THEN** la app consulta su precio en ese momento y la sección Favoritos lo muestra
  sin necesidad de recrear la pantalla ni reiniciar la app

#### Scenario: Fallo al consultar en el marcado

- **WHEN** el usuario marca una gasolinera y la consulta de su precio falla
- **THEN** la gasolinera queda marcada igualmente y se ofrece reintentar la consulta

#### Scenario: Favorito sin conexión

- **WHEN** la consulta del precio de un favorito falla
- **THEN** se muestra la gasolinera con un indicador de precio no disponible y opción de
  reintentar
