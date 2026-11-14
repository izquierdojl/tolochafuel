# Spec Delta

## ADDED Requirements

### Requirement: Reordenar favoritos con arrastrar y soltar

La sección Favoritos SHALL permitir cambiar el orden de las gasolineras marcadas
arrastrando una tarjeta a otra posición, con el nuevo orden aplicado de inmediato en la
interfaz. En pantallas táctiles el arrastre SHALL iniciarse con una pulsación larga; en
escritorio SHALL existir además un asa de arrastre visible. Cuando haya menos de dos
favoritos no SHALL mostrarse ningún control de reordenación.

#### Scenario: Reordenar con pulsación larga en Android

- **WHEN** el usuario mantiene pulsada una tarjeta de Favoritos y la arrastra a otra
  posición
- **THEN** la tarjeta se mueve a esa posición y las demás se recolocan en la lista

#### Scenario: Reordenar con el asa en escritorio

- **WHEN** el usuario arrastra el asa de una tarjeta de Favoritos en Windows o Linux
- **THEN** la tarjeta se mueve a la posición donde la suelta

#### Scenario: Soltar en la misma posición

- **WHEN** el usuario arrastra una tarjeta y la suelta en su posición original
- **THEN** el orden no cambia y no se produce ningún aviso

#### Scenario: Un único favorito

- **WHEN** la sección Favoritos muestra una sola gasolinera
- **THEN** no se ofrece asa ni pista de reordenación

#### Scenario: El orden no depende del precio

- **WHEN** se actualiza el precio vigente de uno o varios favoritos
- **THEN** las tarjetas conservan el orden elegido por el usuario

### Requirement: Persistencia del orden de favoritos

El orden en que el usuario deja las gasolineras de Favoritos SHALL guardarse localmente
junto al resto de favoritos y SHALL conservarse entre ejecuciones de la app. Las
gasolineras nuevas SHALL añadirse al final y desmarcar una SHALL mantener el orden
relativo de las restantes.

#### Scenario: Reapertura de la app

- **WHEN** el usuario reordena sus favoritos, cierra la app y vuelve a abrirla
- **THEN** la sección Favoritos muestra las gasolineras en el mismo orden

#### Scenario: Alta de un favorito nuevo

- **WHEN** el usuario marca una gasolinera mientras ya tiene otras favoritas
- **THEN** la nueva se añade al final de la lista sin alterar el orden anterior

#### Scenario: Baja de un favorito

- **WHEN** el usuario desmarca una gasolinera de una lista con varias favoritas
- **THEN** desaparece de Favoritos y las demás conservan su orden relativo

#### Scenario: Fallo al guardar el orden

- **WHEN** el usuario reordena los favoritos y la escritura local falla
- **THEN** el nuevo orden se mantiene durante la sesión y se muestra un aviso en español
  indicando que no se pudo guardar en el dispositivo
