# Proposal

## Why

Los precios se actualizan dos veces al día y hoy solo se ve el valor actual: no hay
forma de saber si una estación está subiendo o bajando sus precios. La API pública
ofrece el histórico diario por estación (`GET /v1/stations/{id}/history`, hasta 90 días,
con todas las series de carburante en una sola llamada), así que no hace falta guardar
nada en el dispositivo.

## What Changes

- Modelo `HistoricoEstacion` (series por carburante con puntos fecha/precio) en
  `lib/core/models`.
- `PreciosGasolinaApi.historico(id, {days = 5})` contra
  `/v1/stations/{id}/history?days=5`, con parseo tolerante.
- `HistorialController` compartido (provider en `main.dart`) con carga perezosa por
  tarjeta visible, caché en memoria con TTL hasta `meta.next_update`, deduplicación,
  concurrencia limitada y errores silenciosos: el histórico es consulta pesada
  (30 pet/min) y no debe agotar el límite.
- Flecha de tendencia en cada fila de producto de la tarjeta, comparando el último día
  con el anterior: verde ▼ si baja, roja ▲ si sube y neutra «=» si igual (colores
  semánticos del tema, claro y oscuro).
- Modal al pulsar el precio o la flecha: los cinco últimos precios diarios con su fecha
  (dd/mm/aaaa), agrupados por producto, con estados de carga, error (con reintento) y
  sin datos.
- La atribución completa (Gasolina hoy + Ministerio, CC BY 4.0) sigue viviendo en
  Configuración → Acerca de.

## Capabilities

### New Capabilities

- `historico-precios`: consulta del histórico diario por estación, indicación visual de
  la tendencia por producto y detalle de los últimos precios.

### Modified Capabilities

_(ninguna)_

## Impact

- Código: `lib/core/models` (modelo nuevo), `lib/core/api/precios_gasolina_api.dart`,
  `lib/app/theme` (colores semánticos de tendencia en claro y oscuro),
  `lib/features/cercanas/ui/widgets/tarjeta_gasolinera.dart`,
  `lib/features/cercanas/ui/historial_controller.dart` (nuevo) y `lib/main.dart`.
  Afecta a todas las listas que usan la tarjeta (Cercanas, Más económicas, Buscar y
  Favoritos).
- API: peticiones a `/v1/stations/{id}/history` (consulta pesada, 30 pet/min por IP),
  mitigadas con carga perezosa, caché y concurrencia limitada.
- Sin dependencias nuevas. Todas las plataformas (Android, Windows, Linux).

## Fuera de alcance

- Sparklines o gráficas; alertas y notificaciones de bajadas de precio.
- Histórico territorial (`/v1/history`) y medias de mercado.
- Persistir precios o históricos en el dispositivo (la API cubre el caso; guardar las
  últimas consultas queda descartado).
- Periodos distintos de cinco días y comparaciones más allá del último día con el
  anterior.
