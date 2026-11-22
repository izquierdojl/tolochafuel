# Spec Delta

## ADDED Requirements

### Requirement: Mensaje emergente de activación

Al activar un aviso, la app SHALL mostrar un diálogo emergente con el resultado de la
activación: aviso activado, base pendiente, permiso denegado o notificaciones del sistema
desactivadas. El diálogo SHALL incluir una acción para cerrarlo y, cuando el aviso quede
activo, SHALL explicar que los datos se actualizan dos veces al día. La desactivación no
SHALL abrir ningún diálogo.

#### Scenario: Activación correcta

- **WHEN** el usuario activa un aviso y la base de precios se crea correctamente
- **THEN** se muestra un diálogo con «Avisos activados» y la explicación de que los datos
  se actualizan dos veces al día

#### Scenario: Base pendiente

- **WHEN** el usuario activa un aviso y la consulta inicial de precios falla
- **THEN** el diálogo indica que el aviso queda activo y se comprobará cuando haya
  conexión

#### Scenario: Permiso denegado

- **WHEN** el usuario activa un aviso y deniega el permiso de notificaciones
- **THEN** el diálogo explica cómo concederlo desde los ajustes del sistema

#### Scenario: Notificaciones desactivadas

- **WHEN** el usuario activa un aviso y las notificaciones del sistema están desactivadas
- **THEN** el diálogo explica que debe activarlas para recibir avisos

#### Scenario: Desactivación

- **WHEN** el usuario desactiva un aviso
- **THEN** no se muestra ningún diálogo y la campana refleja el estado apagado
