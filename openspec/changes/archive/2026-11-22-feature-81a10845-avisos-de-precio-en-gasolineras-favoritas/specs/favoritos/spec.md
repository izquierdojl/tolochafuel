# Spec Delta

## ADDED Requirements

### Requirement: Avisos de precio asociados al favorito

La sección Favoritos SHALL ofrecer en cada tarjeta un control de campana para activar o
desactivar los avisos de cambio de precio. El control SHALL mostrarse solo para
gasolineras favoritas, SHALL reflejar el estado guardado y SHALL conservarse entre
ejecuciones. Desmarcar la gasolinera SHALL eliminar el aviso; volver a marcarla SHALL
empezar con la campana apagada.

#### Scenario: Campana en una favorita

- **WHEN** el usuario abre Favoritos con una gasolinera marcada
- **THEN** la tarjeta muestra la campana con su estado actual

#### Scenario: Sin campana fuera de Favoritos

- **WHEN** una gasolinera no es favorita o se muestra en otra lista
- **THEN** no se ofrece el control de avisos

#### Scenario: Activar el aviso

- **WHEN** el usuario activa la campana de una favorita
- **THEN** el aviso queda activado y se conserva al reabrir la app

#### Scenario: Desactivar el aviso

- **WHEN** el usuario desactiva la campana
- **THEN** el aviso queda desactivado sin dejar de ser favorita

#### Scenario: Desmarcar una favorita con aviso

- **WHEN** el usuario desmarca una gasolinera que tenía la campana activada
- **THEN** la gasolinera deja de ser favorita y su aviso se elimina

#### Scenario: Volver a marcarla

- **WHEN** el usuario vuelve a marcar como favorita una gasolinera cuyo aviso se eliminó
- **THEN** la campana aparece apagada

#### Scenario: Fallo al guardar el estado

- **WHEN** la escritura local del estado del aviso falla
- **THEN** el cambio se mantiene durante la sesión y se muestra un aviso en español
