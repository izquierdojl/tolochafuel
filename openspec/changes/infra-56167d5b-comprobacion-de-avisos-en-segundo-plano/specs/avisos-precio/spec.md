# Spec Delta

## ADDED Requirements

### Requirement: Comprobación con la app cerrada en Android

La app SHALL programar una comprobación de fondo en Android después de
`meta.next_update` cuando haya al menos una campana activa. La comprobación SHALL
ejecutarse con red disponible, SHALL recalcular la siguiente a partir de la nueva fecha
y no SHALL usar alarmas exactas. Si no hay fecha, SHALL usar un respaldo de 12 horas.

#### Scenario: Aviso con la app cerrada

- **WHEN** los datos se actualizan y hay una campana activa en Android
- **THEN** la comprobación de fondo detecta el cambio y publica la notificación sin que
  el usuario haya abierto la app

#### Scenario: Primera campana activada

- **WHEN** el usuario activa la primera campana en Android
- **THEN** la app programa la siguiente comprobación después de `meta.next_update`

#### Scenario: Sin fecha de próxima actualización

- **WHEN** la API no devuelve `meta.next_update`
- **THEN** la comprobación se programa con un respaldo de 12 horas

#### Scenario: Tarea adelantada

- **WHEN** la tarea se ejecuta antes de que la API publique la nueva actualización
- **THEN** no se notifica, se conserva la base y se programa la siguiente comprobación

#### Scenario: Tarea retrasada

- **WHEN** el sistema ejecuta la tarea después de la actualización
- **THEN** se comparan los precios, se notifica si cambiaron y se programa la siguiente
  con la fecha nueva

#### Scenario: Sin red

- **WHEN** la tarea se ejecuta sin conexión
- **THEN** no se notifica, se conserva la base y se reintenta en la siguiente
  programación

#### Scenario: Error de la API

- **WHEN** la API responde con error durante la comprobación de fondo
- **THEN** no se publica ninguna notificación y se programa el siguiente intento

### Requirement: Cancelación y reconciliación del trabajo de fondo

La app SHALL cancelar el trabajo de fondo cuando no quede ninguna campana activa. Al
abrir o reanudar la app, SHALL reconciliar la programación: cancelar si no hay avisos,
programar si hay avisos y no hay trabajo vigente, y no SHALL duplicar tareas. La
comprobación de fondo y la de primer plano no SHALL solaparse.

#### Scenario: Apagar la última campana

- **WHEN** el usuario apaga la última campana activa
- **THEN** se cancela el trabajo de fondo

#### Scenario: Desmarcar la última favorita con aviso

- **WHEN** el usuario desmarca la última gasolinera que tenía aviso
- **THEN** se cancelan el aviso y el trabajo de fondo

#### Scenario: Reconciliación al abrir

- **WHEN** el usuario abre la app con avisos activos
- **THEN** la app comprueba la programación y la crea si no existe

#### Scenario: Sin duplicar tareas

- **WHEN** el usuario abre la app varias veces con avisos activos
- **THEN** se mantiene una sola tarea de fondo para los avisos

#### Scenario: Comprobación simultánea

- **WHEN** la comprobación de fondo coincide con una comprobación al abrir la app
- **THEN** solo una de ellas hace el trabajo y no se duplican las notificaciones

#### Scenario: Force-stop de la app

- **WHEN** el usuario fuerza la detención de la app
- **THEN** no se ejecuta trabajo de fondo hasta que vuelva a abrirla y se reconcilie la
  programación

### Requirement: Límites y comportamiento del segundo plano

La comprobación de fondo SHALL respetar los límites de la API, SHALL limitar la
concurrencia y SHALL volver a leer favorito y campana antes de notificar. En Windows y
Linux no SHALL programarse trabajo de fondo. La app SHALL documentar que Doze, la batería
y las capas de algunos fabricantes pueden retrasar el aviso y que no es tiempo real.

#### Scenario: Retraso por Doze o batería

- **WHEN** el sistema retrasa la tarea por Doze o por la gestión de batería del
  fabricante
- **THEN** el aviso llega cuando la tarea se ejecuta, sin garantía de puntualidad

#### Scenario: Varias favoritas con aviso

- **WHEN** la comprobación de fondo revisa varias favoritas
- **THEN** las consultas se hacen con concurrencia limitada y respetan los límites de la
  API

#### Scenario: Favorito desmarcado durante la comprobación

- **WHEN** una estación deja de ser favorita mientras se ejecuta la comprobación de fondo
- **THEN** no se publica ninguna notificación para ella

#### Scenario: Campana apagada durante la comprobación

- **WHEN** el usuario apaga la campana mientras se ejecuta la comprobación de fondo
- **THEN** no se publica ninguna notificación para esa estación

#### Scenario: Reinicio del dispositivo

- **WHEN** el dispositivo se reinicia con avisos activos
- **THEN** la programación se conserva y la siguiente comprobación se ejecuta cuando
  corresponda

#### Scenario: Escritorio

- **WHEN** la app se ejecuta en Windows o Linux
- **THEN** no se programa trabajo de fondo y la comprobación sigue siendo al abrir o
  reanudar

#### Scenario: Límite de peticiones

- **WHEN** la API responde con un límite de peticiones durante la comprobación
- **THEN** se detiene el lote, se conserva la base y se reintenta en la siguiente
  programación
