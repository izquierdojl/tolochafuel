# Spec Delta

## MODIFIED Requirements

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

## ADDED Requirements

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
