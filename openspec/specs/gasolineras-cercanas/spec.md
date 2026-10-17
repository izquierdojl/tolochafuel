# gasolineras-cercanas Specification

## Purpose

Permite consultar las gasolineras próximas a una ubicación con los precios de todos los
productos que ofrece cada una, ordenadas por distancia, mostrando la frescura de los
datos y la atribución obligatoria de la fuente.

## Requirements

### Requirement: Ubicación del usuario

La app SHALL obtener la ubicación actual al abrir la sección Cercanas (o la sección
inicial cuando esta sea Más económicas), solicitando el permiso solo en ese momento; si el
permiso se deniega o la plataforma no ofrece ubicación (escritorio), SHALL ofrecer la
sección Buscar como alternativa.

#### Scenario: Permiso concedido en Android

- **WHEN** el usuario abre la sección Cercanas y concede el permiso de ubicación
- **THEN** la app obtiene sus coordenadas y carga las gasolineras cercanas con el radio
  configurado

#### Scenario: Permiso denegado

- **WHEN** el usuario deniega el permiso de ubicación
- **THEN** la app muestra un aviso en español y dirige a la sección Buscar

#### Scenario: Escritorio sin servicio de ubicación

- **WHEN** la app se ejecuta en Windows y el servicio de ubicación no está disponible
- **THEN** la sección Cercanas muestra un aviso y ofrece ir a la sección Buscar (búsqueda
  por municipio o provincia)

#### Scenario: Más económicas sin ubicación

- **WHEN** el usuario abre Más económicas y no hay ubicación disponible
- **THEN** se muestra un aviso en español con un acceso directo a la sección Buscar

### Requirement: Listado ordenado por distancia

La app SHALL mostrar en Cercanas las gasolineras del radio configurado (entre 10 y 50 km)
ordenadas de menor a mayor distancia, indicando la distancia en kilómetros con un
decimal.

#### Scenario: Orden por cercanía

- **WHEN** existen gasolineras dentro del radio de búsqueda
- **THEN** se listan de la más cercana a la más lejana, cada una con su distancia en km

#### Scenario: Radio configurado

- **WHEN** el usuario ha ajustado el radio en Configuración
- **THEN** la consulta de Cercanas usa ese radio, sin superar los 50 km de la API

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

### Requirement: Búsqueda por municipio o provincia (sección Buscar)

La sección Buscar SHALL permitir consultar en cualquier momento por municipio o provincia
(`/v1/search`) y SHALL mostrar las gasolineras más baratas del territorio elegido (orden
por Gasolina 95, `/v1/stations/cheapest` con nivel y código), indicando el orden y el
territorio.

#### Scenario: Búsqueda siempre disponible

- **WHEN** el usuario abre la sección Buscar con o sin ubicación concedida
- **THEN** puede escribir un municipio o provincia y lanzar la búsqueda

#### Scenario: Varias coincidencias

- **WHEN** la búsqueda devuelve varios municipios o provincias
- **THEN** el usuario elige uno y se cargan las gasolineras más baratas de ese territorio

#### Scenario: Sin coincidencias

- **WHEN** la búsqueda no encuentra municipios ni provincias
- **THEN** se muestra un mensaje en español que lo indica

#### Scenario: Error de red en la búsqueda

- **WHEN** la consulta de lugares falla
- **THEN** se muestra el mensaje de error en español y se puede reintentar

#### Scenario: Resultados del territorio

- **WHEN** el usuario elige un lugar
- **THEN** se listan sus gasolineras de menor a mayor precio, con la indicación «Orden
  por Gasolina 95» y el nombre del territorio

### Requirement: Listado Más económicas

La sección Más económicas SHALL mostrar las gasolineras más baratas del radio configurado
alrededor de la ubicación actual según el criterio de orden activo (por defecto, Gasolina
95), con su distancia en kilómetros y la indicación del criterio en la cabecera,
respetando los límites de la API (radio ≤ 50 km, `limit` ≤ 50). Con un carburante como
criterio SHALL usar `/v1/stations/cheapest` con `lat`, `lng`, `radius_km` y `fuel`; la
atribución sigue en Configuración → Acerca de.

#### Scenario: Ranking por precio

- **WHEN** el usuario abre Más económicas con ubicación disponible
- **THEN** se listan de menor a mayor precio del criterio activo las estaciones del radio
  configurado, cada una con su distancia en km

#### Scenario: Sin resultados en el radio

- **WHEN** no hay estaciones en el radio configurado para el criterio activo
- **THEN** se muestra un estado vacío que sugiere ampliar el radio, cambiar de ubicación
  o probar otro criterio de orden

#### Scenario: Error de la API

- **WHEN** la consulta de Más económicas falla
- **THEN** se muestra un mensaje de error en español con acción de reintento

#### Scenario: Consulta repetida

- **WHEN** el usuario vuelve a Más económicas sin cambiar ubicación, radio ni criterio
- **THEN** la app reutiliza la respuesta cacheada y no repite la petición

### Requirement: Criterio de ordenación de Más económicas

La sección Más económicas SHALL ofrecer un selector «Ordenar por» con los seis
carburantes de la API (Gasolina 95, Gasolina 98, Gasóleo A, Gasóleo premium, GLP y GNC)
y la opción «Media de carburantes», con Gasolina 95 por defecto. La elección SHALL
guardarse en los ajustes locales y SHALL aplicarse al volver a la sección o al reiniciar
la app.

#### Scenario: Opciones del selector

- **WHEN** el usuario abre Más económicas
- **THEN** el selector muestra los seis carburantes y la media, con Gasolina 95 activo
  por defecto

#### Scenario: Cambio de criterio

- **WHEN** el usuario elige Gasóleo A en el selector
- **THEN** la lista se recarga ordenada por ese carburante y la cabecera indica el
  criterio activo

#### Scenario: Preferencia conservada

- **WHEN** el usuario elige GLP y reabre la app
- **THEN** Más económicas ordena por GLP sin intervención adicional

#### Scenario: Criterio desconocido

- **WHEN** el criterio guardado no es uno de los reconocidos
- **THEN** la sección usa Gasolina 95

### Requirement: Media de carburantes

Con «Media de carburantes» como criterio, la sección SHALL ordenar las estaciones de
menor a mayor precio medio por litro de los carburantes que ofrece cada una, a partir de
los precios de su ficha (`/v1/stations/{id}`). La media SHALL excluir los precios en
€/kg y los productos que no son carburantes (por ejemplo, AdBlue), y SHALL omitir del
ranking las estaciones sin ningún precio computable.

#### Scenario: Media por litro

- **WHEN** la ficha de una estación ofrece varios carburantes con precio en €/L
- **THEN** su media es la media aritmética de esos precios

#### Scenario: Exclusiones de la media

- **WHEN** la ficha incluye un producto no-carburante (AdBlue) o un carburante medido en
  €/kg (GNC)
- **THEN** esos precios no entran en la media

#### Scenario: Estación sin precio computable

- **WHEN** una estación no tiene ningún carburante con precio en €/L
- **THEN** no aparece en el ranking por media

#### Scenario: Candidatas del radio

- **WHEN** el radio contiene más de 50 estaciones
- **THEN** el ranking por media se calcula con las 50 más cercanas (límite de la API)
  sin peticiones adicionales
