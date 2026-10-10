# gasolineras-cercanas Specification

## Purpose

Permite consultar las gasolineras próximas a una ubicación con los precios de todos los
productos que ofrece cada una, ordenadas por distancia, mostrando la frescura de los
datos y la atribución obligatoria de la fuente.

## Requirements

### Requirement: Ubicación del usuario

La app SHALL obtener la ubicación actual al abrir la pantalla principal, solicitando el
permiso solo en ese momento; si el permiso se deniega o la plataforma no ofrece ubicación
(escritorio), SHALL ofrecer una búsqueda manual por municipio como alternativa.

#### Scenario: Permiso concedido en Android

- **WHEN** el usuario abre la pantalla principal y concede el permiso de ubicación
- **THEN** la app obtiene sus coordenadas y carga las gasolineras cercanas

#### Scenario: Permiso denegado

- **WHEN** el usuario deniega el permiso de ubicación
- **THEN** la app muestra un aviso en español y ofrece buscar por municipio

#### Scenario: Escritorio sin servicio de ubicación

- **WHEN** la app se ejecuta en Windows y el servicio de ubicación no está disponible
- **THEN** la pantalla principal abre directamente el modo de búsqueda manual por municipio

### Requirement: Listado ordenado por distancia

La app SHALL mostrar las gasolineras del radio consultado ordenadas de menor a mayor
distancia, indicando la distancia en kilómetros con un decimal.

#### Scenario: Orden por cercanía

- **WHEN** existen gasolineras dentro del radio de búsqueda
- **THEN** se listan de la más cercana a la más lejana, cada una con su distancia en km

### Requirement: Productos y precios por gasolinera

Cada tarjeta SHALL mostrar, bajo el nombre y la dirección, todos los productos que ofrece
la estación (gasolinas, gasóleos, GLP/GNC y otros) con su etiqueta, precio y unidad
(€/L o €/kg), obtenidos de la ficha de la estación (`/v1/stations/{id}`).

#### Scenario: Estación con varios productos

- **WHEN** la ficha de una gasolinera devuelve varios combustibles o productos
- **THEN** la tarjeta muestra cada uno con su etiqueta, precio y unidad

#### Scenario: Ficha no disponible

- **WHEN** no se puede obtener la ficha de una gasolinera
- **THEN** la tarjeta se muestra igualmente con nombre, dirección y distancia, indicando
  «Precios no disponibles»

### Requirement: Identidad Tolocha en la cabecera

La cabecera SHALL mostrar el emblema Tolocha adaptado a carburantes (surtidor) y la marca
«TolochaFuel», con «Fuel» en el color de acento de la paleta, usando la tipografía de
marca (Inter) empaquetada en la app.

#### Scenario: Cabecera de la pantalla principal

- **WHEN** el usuario abre la app
- **THEN** la cabecera muestra el emblema Tolocha y la marca «TolochaFuel» con «Fuel» en
  el color de acento

### Requirement: Frescura de los datos y atribución

La pantalla SHALL mostrar la antigüedad de los datos (`meta.last_updated`) y la
atribución «Gasolina hoy (preciosgasolina.es), con datos del Ministerio para la
Transición Ecológica y el Reto Demográfico» con enlace, conforme a la licencia CC BY 4.0.

#### Scenario: Lista con datos

- **WHEN** la lista de gasolineras se muestra con precios
- **THEN** son visibles la fecha de actualización de los datos y la atribución con enlace

### Requirement: Estados de la pantalla

La app SHALL representar cuatro estados —carga, datos, error y vacío— sin bloquear la
navegación; el estado de error SHALL ofrecer reintento y todos los mensajes SHALL estar en
español.

#### Scenario: Error de red

- **WHEN** la petición a la API falla
- **THEN** se muestra un mensaje de error con un botón de reintentar

#### Scenario: Sin resultados

- **WHEN** no hay gasolineras en el radio consultado
- **THEN** se muestra un estado vacío que sugiere ampliar el radio o cambiar de ubicación

### Requirement: Límites de la API y caché en memoria

La app SHALL respetar los límites de la API (radio ≤ 50 km, `limit` ≤ 50) y SHALL cachear
en memoria el listado y la ficha de cada estación (`/v1/stations/{id}`) al menos hasta la
siguiente actualización de la fuente (≈ 8:00 y 20:00), sin polling periódico.

#### Scenario: Navegación repetida

- **WHEN** el usuario vuelve a la pantalla principal sin cambiar de ubicación
- **THEN** la app reutiliza las respuestas cacheadas sin repetir las peticiones

#### Scenario: Datos servidos en modo stale

- **WHEN** la API responde con `meta.stale = true`
- **THEN** la app muestra los datos indicando que pueden ser de la actualización anterior
