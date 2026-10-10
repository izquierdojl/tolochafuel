# Spec Delta

## Purpose

Permite abrir la aplicación de mapas (o Google Maps web) con la ruta hacia las
coordenadas de una gasolinera elegida, desde cualquier lista donde se muestre.

## ADDED Requirements

### Requirement: Acción Navegar por gasolinera

Cada gasolinera mostrada en una lista SHALL ofrecer una acción «Navegar» que lanza la
navegación externa hacia sus coordenadas.

#### Scenario: Pulsación en Android con app de mapas

- **WHEN** el usuario pulsa «Navegar» sobre una gasolinera en Android y hay una app de mapas instalada
- **THEN** se abre el intent `geo:` con las coordenadas de la gasolinera como destino

#### Scenario: Android sin app de mapas

- **WHEN** no hay ninguna aplicación que pueda manejar el intent `geo:`
- **THEN** se abre Google Maps web en el navegador con la ruta al destino

### Requirement: Comportamiento en escritorio

En Windows/escritorio, «Navegar» SHALL abrir Google Maps web en el navegador
predeterminado con la ruta a las coordenadas de la gasolinera.

#### Scenario: Pulsación en Windows

- **WHEN** el usuario pulsa «Navegar» sobre una gasolinera en Windows
- **THEN** se abre el navegador predeterminado con la URL de Google Maps apuntando al destino

### Requirement: Error de apertura controlado

Si no se puede abrir ninguna aplicación ni navegador, la app SHALL informarlo en español
mediante un aviso no bloqueante.

#### Scenario: Fallo de apertura

- **WHEN** `launchUrl` devuelve `false` o lanza un error
- **THEN** se muestra un aviso en español y la lista permanece utilizable
