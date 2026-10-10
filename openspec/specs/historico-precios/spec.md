# historico-precios Specification

## Purpose
Muestra la tendencia del precio de cada producto de una estación según su última
variación registrada y permite consultar sus últimos cambios de precio.

## Requirements

### Requirement: Tendencia por última variación registrada

La tarjeta de gasolinera SHALL indicar, a la derecha del precio de cada producto, la
tendencia según la última variación registrada en el histórico diario de la estación
(hasta 90 días, `/v1/stations/{id}/history`), con los colores del tema. La atribución
completa a Gasolina hoy y al Ministerio (CC BY 4.0) vive en Configuración → Acerca de.

#### Scenario: Precio que baja

- **WHEN** el último precio de los últimos 90 días es menor que el anterior precio
  distinto
- **THEN** la fila del producto muestra una flecha verde hacia abajo a la derecha del
  precio

#### Scenario: Precio que sube

- **WHEN** el último precio de los últimos 90 días es mayor que el anterior precio
  distinto
- **THEN** la fila del producto muestra una flecha roja hacia arriba a la derecha del
  precio

#### Scenario: Precio sin cambios

- **WHEN** todos los precios de los últimos 90 días son iguales
- **THEN** la fila del producto muestra un indicador neutro «=»

#### Scenario: Sin histórico disponible

- **WHEN** la estación no tiene histórico o la consulta falla
- **THEN** la tarjeta muestra el precio sin flecha, sin bloquear la lista

### Requirement: Detalle de los últimos cambios de precio

Al pulsar sobre el precio o la flecha de un producto, la app SHALL abrir un modal con
los últimos cambios de precio de cada producto (según
`/v1/stations/{id}/history?days=90`), agrupados, con su fecha (dd/mm/aaaa) y su
variación. La atribución completa a Gasolina hoy y al Ministerio (CC BY 4.0) vive en
Configuración → Acerca de.

#### Scenario: Apertura del modal

- **WHEN** el usuario pulsa el precio o la flecha de un producto
- **THEN** se abre un modal con los últimos cambios de precio (hasta cinco) de cada
  producto, agrupados y con su fecha

#### Scenario: Producto sin cambios

- **WHEN** el precio de un producto no ha cambiado en los últimos 90 días
- **THEN** el modal indica «Sin cambios en los últimos 90 días» para ese producto

#### Scenario: Resumen de variación por producto

- **WHEN** el usuario abre el modal de histórico
- **THEN** cada producto con cambios muestra, bajo sus precios, su variación en español
  con la fecha desde la que se produjo

#### Scenario: Histórico cargando

- **WHEN** el histórico aún no está disponible al abrir el modal
- **THEN** el modal muestra un indicador de carga y se completa al llegar la respuesta

#### Scenario: Error al consultar el histórico

- **WHEN** la consulta del histórico falla
- **THEN** el modal muestra un mensaje en español con opción de reintentar

#### Scenario: Estación sin histórico

- **WHEN** la estación no tiene datos históricos
- **THEN** el modal lo indica en español sin bloquear el resto de la pantalla

### Requirement: Límites de la API y caché del histórico

La app SHALL tratar `/v1/stations/{id}/history` como consulta pesada (30 pet/min por
IP): SHALL consultarlo solo para estaciones visibles, con concurrencia limitada, y SHALL
cachear cada histórico en memoria hasta la próxima actualización de la fuente
(`meta.next_update`), sin polling.

#### Scenario: Navegación repetida

- **WHEN** el usuario vuelve a ver una estación ya consultada antes de la próxima
  actualización de la fuente
- **THEN** se reutiliza el histórico cacheado y no se repite la petición

#### Scenario: Límite de concurrencia

- **WHEN** muchas tarjetas visibles piden histórico a la vez
- **THEN** las peticiones se limitan para no superar el límite de consultas pesadas
