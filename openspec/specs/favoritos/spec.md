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

### Requirement: Estado vacío de Favoritos

La sección SHALL mostrar un estado vacío en español cuando no haya gasolineras marcadas,
explicando cómo añadirlas.

#### Scenario: Primera visita sin favoritos

- **WHEN** el usuario abre Favoritos sin haber marcado ninguna gasolinera
- **THEN** se muestra un mensaje que indica marcar desde la lista de cercanas

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

### Requirement: Avisos de precio asociados al favorito

La sección Favoritos SHALL ofrecer en la cabecera de cada tarjeta un icono de campana
junto al corazón, sin una fila adicional, para activar o desactivar los avisos de cambio
de precio. El icono SHALL mostrarse relleno cuando el aviso esté activo y contorneado
cuando esté apagado, con el mismo tratamiento visual que el corazón, y SHALL conservarse
entre ejecuciones. Al activarlo, la app SHALL mostrar un diálogo emergente con el
resultado y la explicación de que los datos se actualizan dos veces al día. Desmarcar la
gasolinera SHALL eliminar el aviso; volver a marcarla SHALL empezar con la campana
contorneada.

#### Scenario: Campana en una favorita

- **WHEN** el usuario abre Favoritos con una gasolinera marcada
- **THEN** la cabecera de la tarjeta muestra un icono de campana junto al corazón,
  relleno si el aviso está activo y contorneado si está apagado, sin una fila adicional

#### Scenario: Sin campana fuera de Favoritos

- **WHEN** una gasolinera no es favorita o se muestra en otra lista
- **THEN** no se ofrece el control de avisos

#### Scenario: Activar el aviso

- **WHEN** el usuario pulsa el icono de campana de una favorita
- **THEN** el aviso queda activado, la campana pasa a rellena, se muestra un diálogo
  emergente con la explicación de que los datos se actualizan dos veces al día y el estado
  se conserva al reabrir la app

#### Scenario: Permiso denegado

- **WHEN** el usuario pulsa el icono de campana y deniega el permiso de notificaciones
- **THEN** la campana vuelve a contornearse y el diálogo emergente explica cómo concederlo
  desde los ajustes del sistema

#### Scenario: Desactivar el aviso

- **WHEN** el usuario pulsa el icono de campana relleno
- **THEN** el aviso queda desactivado sin dejar de ser favorita, la campana pasa a
  contorneada y no se muestra ningún diálogo

#### Scenario: Desmarcar una favorita con aviso

- **WHEN** el usuario desmarca una gasolinera que tenía el aviso activado
- **THEN** la gasolinera deja de ser favorita y su aviso se elimina

#### Scenario: Volver a marcarla

- **WHEN** el usuario vuelve a marcar como favorita una gasolinera cuyo aviso se eliminó
- **THEN** la campana aparece contorneada

#### Scenario: Fallo al guardar el estado

- **WHEN** la escritura local del estado del aviso falla
- **THEN** el cambio se mantiene durante la sesión y se muestra un aviso en español
