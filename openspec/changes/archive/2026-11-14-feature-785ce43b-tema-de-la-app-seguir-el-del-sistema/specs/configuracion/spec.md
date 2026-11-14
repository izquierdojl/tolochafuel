## MODIFIED Requirements

### Requirement: Tema claro y oscuro

La app SHALL permitir elegir el tema entre «Sistema», «Claro» y «Oscuro», con «Sistema»
como valor por defecto; el cambio SHALL aplicarse al instante y persistir. Con «Sistema»
la app SHALL seguir el brillo del sistema operativo, también cuando este cambie con la
app abierta. Quien ya hubiera elegido claro u oscuro antes de existir «Sistema» SHALL
conservar esa elección.

#### Scenario: Cambio de tema inmediato

- **WHEN** el usuario cambia el tema en Configuración
- **THEN** toda la app cambia de tema sin reiniciarse

#### Scenario: Tema por defecto

- **WHEN** el usuario abre la app por primera vez
- **THEN** la opción «Sistema» está seleccionada y la app usa el tema que indica el
  sistema

#### Scenario: Seguir el sistema

- **GIVEN** que el usuario tiene seleccionada la opción «Sistema»
- **WHEN** el sistema operativo cambia entre modo claro y oscuro con la app abierta
- **THEN** la app cambia al tema correspondiente sin reiniciarse

#### Scenario: Elección fija ignora el sistema

- **GIVEN** que el usuario tiene seleccionada la opción «Claro» u «Oscuro»
- **WHEN** el sistema operativo cambia de modo
- **THEN** la app mantiene el tema elegido

#### Scenario: Tema persistente

- **WHEN** el usuario elige el tema claro y reabre la app
- **THEN** la app arranca con el tema claro

#### Scenario: Elección anterior conservada

- **GIVEN** que el usuario eligió el tema claro u oscuro en una versión anterior
- **WHEN** abre la app tras actualizar
- **THEN** la app arranca con esa misma elección y no con «Sistema»

#### Scenario: Valor guardado inválido

- **WHEN** la preferencia de tema guardada no es legible o no es válida
- **THEN** la app usa «Sistema» sin bloquear el uso
