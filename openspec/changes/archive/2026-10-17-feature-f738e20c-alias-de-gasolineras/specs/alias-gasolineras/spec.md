# Spec Delta

## Purpose

Permite al usuario poner nombres locales y persistentes a las gasolineras que consulta,
independientemente de la API y de los favoritos, para distinguir estaciones con rótulos
genéricos o repetidos.

## ADDED Requirements

### Requirement: Gestión del alias desde la tarjeta

La app SHALL permitir poner, cambiar o quitar el alias de cualquier gasolinera desde el
menú de acciones de su tarjeta, disponible en todas las listas (Cercanas, Más económicas,
Buscar y Favoritos), sin necesidad de marcarla como favorita.

#### Scenario: Poner un alias

- **WHEN** el usuario abre el menú de una gasolinera sin alias, elige «Poner alias…» y
  guarda un texto
- **THEN** la estación muestra ese texto como nombre en todas las listas

#### Scenario: Cambiar un alias

- **WHEN** el usuario elige «Editar alias…» en una gasolinera con alias y guarda otro
  texto
- **THEN** el nuevo texto sustituye al anterior en todas las listas

#### Scenario: Quitar un alias

- **WHEN** el usuario elige «Quitar alias» en el diálogo o guarda el texto vacío
- **THEN** la estación vuelve a mostrar el rótulo de la API

#### Scenario: Espacios sobrantes

- **WHEN** el usuario guarda un alias con espacios al principio o al final
- **THEN** el alias se guarda recortado

#### Scenario: Límite de longitud

- **WHEN** el usuario escribe más de 40 caracteres en el diálogo
- **THEN** el campo no admite más de 40 caracteres

#### Scenario: Alias repetido

- **WHEN** el usuario pone el mismo alias a dos gasolineras distintas
- **THEN** ambas lo muestran sin avisos ni conflictos

### Requirement: Presentación del alias

Donde se muestre una gasolinera con alias, la app SHALL usar el alias como nombre
principal y SHALL mantener el rótulo original de la API en la línea secundaria junto a la
dirección, también en el encabezado del histórico de precios. Sin alias, la presentación
no cambia respecto a la actual.

#### Scenario: Tarjeta con alias

- **WHEN** una gasolinera tiene alias
- **THEN** su tarjeta muestra el alias como título y, bajo él, el rótulo original junto a
  la dirección y el municipio

#### Scenario: Tarjeta sin alias

- **WHEN** una gasolinera no tiene alias
- **THEN** su tarjeta muestra el rótulo de la API como hasta ahora

#### Scenario: Alias igual al rótulo

- **WHEN** el alias coincide con el rótulo de la API
- **THEN** el rótulo no se repite en la línea secundaria

#### Scenario: Estación sin rótulo

- **WHEN** una gasolinera sin rótulo en la API tiene alias
- **THEN** la tarjeta muestra el alias como título y no muestra «Sin rótulo»

#### Scenario: Histórico de precios

- **WHEN** el usuario abre el histórico de una gasolinera con alias
- **THEN** el encabezado del histórico usa el alias

### Requirement: Persistencia local e independencia de favoritos

Los alias SHALL guardarse solo en el dispositivo (`shared_preferences`, por id de
estación) y SHALL conservarse entre consultas, cambios de sección y reinicios, sin
depender de la API ni de los favoritos. Desmarcar una favorita SHALL NOT borrar su alias y
el alias SHALL mantenerse aunque la API renombre la estación.

#### Scenario: Reinicio de la app

- **WHEN** el usuario pone un alias y reabre la app
- **THEN** las listas muestran el alias sin intervención adicional

#### Scenario: Nuevas consultas

- **WHEN** el usuario vuelve a encontrar la estación en otra lista o tras actualizar los
  datos
- **THEN** la estación sigue mostrando su alias

#### Scenario: La API renombra la estación

- **WHEN** el rótulo que devuelve la API cambia y la estación tiene alias
- **THEN** el alias se mantiene como nombre principal

#### Scenario: Desmarcar favorita

- **WHEN** el usuario quita una estación de favoritos
- **THEN** su alias se conserva y se sigue mostrando

#### Scenario: Sin conexión

- **WHEN** el usuario abre la app sin conexión
- **THEN** los alias de las estaciones que aparezcan se siguen mostrando

### Requirement: Errores y datos locales inválidos

La carga de alias SHALL ser tolerante: los datos locales inválidos se ignoran sin
bloquear la app. Si falla el guardado de un alias, la app SHALL mostrar un aviso en
español y la sesión SHALL continuar con el alias aplicado en memoria.

#### Scenario: Datos locales inválidos

- **WHEN** los alias guardados no se pueden interpretar
- **THEN** la app arranca sin alias y el resto de secciones funcionan con normalidad

#### Scenario: Fallo al guardar

- **WHEN** el guardado del alias falla
- **THEN** se muestra un aviso en español y la estación sigue mostrando el alias en la
  sesión actual
