# Spec Delta

## Purpose

Permite consultar las gasolineras próximas a una ubicación con sus precios de carburante,
ordenadas por distancia, mostrando la frescura de los datos y la atribución obligatoria
de la fuente.

## ADDED Requirements

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

### Requirement: Precio del carburante seleccionado

Cada elemento de la lista SHALL mostrar el precio del carburante seleccionado (Gasolina 95
por defecto) y la pantalla SHALL permitir cambiar entre al menos Gasolina 95 y Gasóleo A.

#### Scenario: Cambio de carburante

- **WHEN** el usuario selecciona Gasóleo A en el selector
- **THEN** la lista se recarga con el precio de gasóleo A de cada gasolinera

#### Scenario: Gasolinera sin precio del carburante

- **WHEN** una gasolinera del radio no comunica precio del carburante seleccionado
- **THEN** se muestra «Sin precio» en lugar de una cifra, sin romper el orden por distancia

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
las respuestas en memoria al menos hasta la siguiente actualización de la fuente
(≈ 8:00 y 20:00), sin polling periódico.

#### Scenario: Navegación repetida

- **WHEN** el usuario vuelve a la pantalla principal sin cambiar ubicación ni carburante
- **THEN** la app reutiliza la respuesta cacheada sin repetir la petición

#### Scenario: Datos servidos en modo stale

- **WHEN** la API responde con `meta.stale = true`
- **THEN** la app muestra los datos indicando que pueden ser de la actualización anterior
