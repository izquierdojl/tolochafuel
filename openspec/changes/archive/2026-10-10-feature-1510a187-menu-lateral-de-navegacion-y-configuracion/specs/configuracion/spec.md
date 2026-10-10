# Spec Delta

## Purpose

Reúne las preferencias locales de la app —tema, radio de búsqueda y pantalla inicial— y
la información «Acerca de» con la atribución, licencia y explicación de los datos.

## ADDED Requirements

### Requirement: Persistencia de preferencias

Las preferencias SHALL guardarse en el dispositivo y aplicarse en el siguiente arranque,
sin cuentas ni conexión. Si no se pueden leer o guardar, la app SHALL continuar con los
valores por defecto y avisar en español sin bloquear el uso.

#### Scenario: Preferencia conservada entre ejecuciones

- **WHEN** el usuario cambia una preferencia y vuelve a abrir la app
- **THEN** la preferencia elegida sigue aplicada

#### Scenario: Fallo al persistir

- **WHEN** el almacenamiento local falla al leer o guardar
- **THEN** la app funciona con los valores por defecto y muestra un aviso en español

### Requirement: Tema claro y oscuro

La app SHALL permitir elegir entre tema claro y oscuro, con el oscuro como valor por
defecto; el cambio SHALL aplicarse al instante y persistir.

#### Scenario: Cambio de tema inmediato

- **WHEN** el usuario cambia el tema en Configuración
- **THEN** toda la app cambia de tema sin reiniciarse

#### Scenario: Tema por defecto

- **WHEN** el usuario abre la app por primera vez
- **THEN** el tema oscuro está activo

#### Scenario: Tema persistente

- **WHEN** el usuario elige el tema claro y reabre la app
- **THEN** la app arranca con el tema claro

### Requirement: Radio de búsqueda configurable

La app SHALL permitir ajustar el radio de búsqueda entre 10 y 50 km, con 25 km por
defecto, y SHALL aplicarlo a las secciones Cercanas y Más económicas. La interfaz SHALL
indicar que 50 km es el máximo que permite la API.

#### Scenario: Radio aplicado a las consultas

- **WHEN** el usuario cambia el radio en Configuración
- **THEN** las siguientes consultas de Cercanas y Más económicas usan el nuevo radio

#### Scenario: Límite de la API

- **WHEN** el usuario intenta configurar un radio mayor de 50 km
- **THEN** la app no lo permite y explica que 50 km es el máximo de la API

### Requirement: Pantalla inicial

La app SHALL permitir elegir la pantalla inicial entre Cercanas, Favoritas, Buscar y Más
económicas, con Cercanas por defecto; Configuración no SHALL ofrecerse como pantalla
inicial.

#### Scenario: Elegir pantalla inicial

- **WHEN** el usuario selecciona «Más económicas» como pantalla inicial y reabre la app
- **THEN** la app abre en la sección Más económicas

#### Scenario: Valor por defecto

- **WHEN** el usuario nunca ha cambiado la pantalla inicial
- **THEN** la app abre en Cercanas y Configuración no aparece entre las opciones

### Requirement: Sección Acerca de

La sección «Acerca de» SHALL mostrar el nombre de la app, la explicación de la fuente
(datos oficiales del Ministerio para la Transición Ecológica y el Reto Demográfico,
servidos por Gasolina hoy, actualizados dos veces al día y no en tiempo real), la
atribución completa y la licencia CC BY 4.0 con enlace, además del enlace al repositorio
de código. Es el único lugar de la app donde se muestra la atribución (decisión del
proyecto).

#### Scenario: Contenido de Acerca de

- **WHEN** el usuario abre Configuración → Acerca de…
- **THEN** ve el nombre de la app, la explicación de los datos, la atribución a Gasolina
  hoy y al Ministerio, y los enlaces de la licencia CC BY 4.0 y del repositorio
