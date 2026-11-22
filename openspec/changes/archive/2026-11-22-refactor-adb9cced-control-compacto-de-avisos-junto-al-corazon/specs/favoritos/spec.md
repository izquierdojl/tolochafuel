# Spec Delta

## MODIFIED Requirements

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
