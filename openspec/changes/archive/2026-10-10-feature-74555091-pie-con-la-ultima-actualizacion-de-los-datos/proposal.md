# Proposal

## Why

El usuario no puede comprobar en la app cuándo se actualizaron los datos, aunque la API
lo informa (`meta.last_updated`, `meta.data_age_seconds`, `meta.stale`) y ya exista un
formateador sin usar (`textoFrescura`). Además, el requisito de indicar cuando la fuente
sirve datos en modo `stale` sigue sin implementarse.

## What Changes

- Pie fijo al pie de las listas de Cercanas, Más económicas, Buscar y Favoritos con la
  frescura global de los datos: fecha y hora de `meta.last_updated` y su antigüedad
  (reutilizando `textoFrescura`), o un texto genérico («Datos oficiales actualizados 2
  veces al día») cuando la fecha no esté disponible.
- Aviso visible en el pie cuando `meta.stale` es verdadero: los datos pueden ser de la
  actualización anterior.
- Los controladores de listas (Cercanas, Más económicas y Buscar) dejan de descartar
  `MetaDatos`; Favoritos conserva el meta de las fichas que consulta.
- La atribución completa (Gasolina hoy + Ministerio, CC BY 4.0) sigue viviendo en
  Configuración → Acerca de.

## Capabilities

### New Capabilities

- `frescura-datos`: comunicación de la fecha y antigüedad global de la última
  actualización de los precios y aviso de datos servidos en modo `stale`.

### Modified Capabilities

_(ninguna)_

## Impact

- Código: `lib/features/cercanas/ui/cercanas_controller.dart`,
  `lib/features/cercanas/ui/mas_economicas_controller.dart`,
  `lib/features/cercanas/ui/buscar_controller.dart` y
  `lib/features/favoritos/ui/favoritos_controller.dart` (guardar el meta),
  `lib/core/models/detalle_estacion.dart` (conservar el meta de la ficha),
  nuevo widget de pie e integración en las cuatro pantallas de lista.
- Sin dependencias nuevas. Todas las plataformas (Android, Windows, Linux).

## Fuera de alcance

- Hora de actualización por estación en cada tarjeta (`price_updated_at`).
- Polling periódico o recarga automática por frescura.
- Cambios en Configuración → Acerca de.
- Histórico de precios y tendencia (change aparte).
