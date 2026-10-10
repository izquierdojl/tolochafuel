# Proposal

## Why

El usuario repostará una y otra vez en las mismas gasolineras: necesita marcarlas para
consultar sus precios hoy sin depender de dónde esté en ese momento ni de volver a
buscarlas en la lista de cercanas.

## What Changes

- Marcar y desmarcar gasolineras como favoritas (icono de corazón) desde la lista.
- Persistencia local con `shared_preferences`: sin cuentas, sin red, sin servidor.
- Sección «Favoritos» con las gasolineras marcadas y su precio vigente, consultado a la
  API por identificador, con la misma atribución CC BY 4.0.
- La sección Favoritos se integrará en el menú lateral del change
  `feature-1510a187-menu-lateral-de-navegacion-y-configuracion`; sin barra de navegación
  inferior propia.

## Capabilities

### New Capabilities

- `favoritos`: gestión local y persistente de gasolineras favoritas y su consulta
  frecuente con precios actualizados.

### Modified Capabilities

_(ninguna)_

## Impact

- Código nuevo: `lib/features/favoritos/{data,ui}`.
- Dependencia nueva: `shared_preferences`.
- Se reutilizan la tarjeta de gasolinera, el cliente API (`GET /v1/stations/{id}`) y,
  cuando exista, el servicio de navegación del change `feature-…-navegacion-a-gasolinera`.
- Sin cambios de permisos ni de backend.

## Fuera de alcance

- Sincronización entre dispositivos o cuentas de usuario (decisión de proyecto: jamás).
- Ordenación personalizada o notas por favorito.
- Notificaciones de bajadas de precio.
- Exportar/importar favoritos.
