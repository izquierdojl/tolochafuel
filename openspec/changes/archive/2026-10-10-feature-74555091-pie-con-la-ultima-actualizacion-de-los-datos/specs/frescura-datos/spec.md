# Spec Delta

## Purpose

Comunica al usuario la fecha y antigüedad de la última actualización global de los
precios y avisa cuando la fuente sirve datos de la actualización anterior.

## ADDED Requirements

### Requirement: Fecha global de actualización en el pie

La app SHALL mostrar al pie de las listas de datos (Cercanas, Más económicas, Buscar y
Favoritos) la fecha y hora de la última actualización global de la fuente
(`meta.last_updated` de api.preciosgasolina.es) y su antigüedad, o un texto genérico
(«Datos oficiales actualizados 2 veces al día») si no está disponible. La atribución
completa a Gasolina hoy y al Ministerio (CC BY 4.0) vive en Configuración → Acerca de.

#### Scenario: Pie con fecha en un listado

- **WHEN** el usuario ve un listado con datos
- **THEN** el pie muestra «Datos del dd/mm/aaaa hh:mm» junto a la antigüedad
  («hace X min» o «hace X h»)

#### Scenario: Pie sin fecha disponible

- **WHEN** la API no informa de la fecha de actualización
- **THEN** el pie muestra el texto genérico de actualización dos veces al día

#### Scenario: Pie en Favoritos

- **WHEN** el usuario abre Favoritos y alguna consulta de precio ha devuelto metadatos
- **THEN** el pie muestra la fecha global de la última actualización

#### Scenario: Listado vacío con respuesta correcta

- **WHEN** la API responde sin gasolineras en el radio o territorio
- **THEN** se mantiene el estado vacío y el pie muestra la fecha de actualización

#### Scenario: Sin pie en estado de error

- **WHEN** el listado falla y la pantalla muestra su error con reintento
- **THEN** el pie no se muestra

### Requirement: Aviso de datos en modo stale

Cuando la API responda con `meta.stale = true`, el pie SHALL indicar en español que los
datos pueden ser de la actualización anterior, sin bloquear la lista.

#### Scenario: Fuente caída con copia buena

- **WHEN** la API responde con `stale = true`
- **THEN** el pie muestra el aviso de actualización anterior junto a la fecha

#### Scenario: Datos frescos

- **WHEN** la API responde con `stale = false`
- **THEN** el pie muestra solo la fecha y la antigüedad, sin aviso
