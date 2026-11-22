# Spec Delta

## MODIFIED Requirements

### Requirement: Sección Acerca de

La sección «Acerca de» SHALL mostrar el nombre de la app, la explicación de la fuente
(datos oficiales del Ministerio para la Transición Ecológica y el Reto Demográfico,
servidos por Gasolina hoy, actualizados dos veces al día y no en tiempo real), la
atribución completa, la licencia CC BY 4.0 de los datos y la licencia MIT del código,
ambas con enlace, además del enlace al repositorio. Es el único lugar de la app donde se
muestra la atribución (decisión del proyecto).

#### Scenario: Contenido de Acerca de

- **WHEN** el usuario abre Configuración → Acerca de…
- **THEN** ve el nombre de la app, la explicación de los datos, la atribución a Gasolina
  hoy y al Ministerio, y los enlaces de las licencias CC BY 4.0 y MIT y del repositorio

#### Scenario: Licencias diferenciadas

- **WHEN** el usuario consulta las licencias en «Acerca de»
- **THEN** la licencia CC BY 4.0 aparece asociada a los datos y la licencia MIT al
  código, sin presentarlas como una única licencia
