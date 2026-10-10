# Design

## Context

La tarjeta (`TarjetaGasolinera`) muestra los productos con `ProductoPrecio` (su `idApi`
coincide con `fuel` de la API: `gasoline_95`, `diesel`, `diesel_premium`…). El
histórico diario por estación está en `GET /v1/stations/{id}/history?days=5` (consulta
pesada: 30 pet/min; una sola llamada devuelve todas las series de carburante). La app
ya usa caché en memoria con TTL por `meta.next_update` (`CercanasRepositorio`). Ver
`proposal.md` - Why.

## Goals / Non-Goals

**Goals:**

- Tendencia visible por producto sin degradar la carga de la lista.
- Modal con los cinco últimos precios agrupados por producto.
- Respetar el límite de consultas pesadas (carga perezosa + caché + concurrencia).

**Non-Goals:**

- Sparklines, alertas, histórico territorial o persistencia local.

## Decisions

- **Modelo `HistoricoEstacion`** en `lib/core/models`: series por carburante con puntos
  `(fecha, precio)` y `proximaActualizacion`; parseo tolerante con las utilidades de
  `parseo.dart`.
- **API**: `PreciosGasolinaApi.historico(int id, {int days = 90})` →
  `/v1/stations/{id}/history?days=90` (máximo de la API), devolviendo también el
  `MetaDatos` de la respuesta. Los cambios se calculan en la app comparando días
  consecutivos.
- **`HistorialController` compartido** (provider en `main.dart`, como
  `FavoritosController`): `historico(id)`, `cargando(id)`, `error(id)`; caché
  `Map<int, HistoricoEstacion>` con TTL `meta.next_update`, deduplicación por id y
  cola de concurrencia (máximo 4 simultáneas). Los errores no se pintan en la tarjeta
  (sin flecha); el modal sí ofrece reintento. Alternativa descartada: incluir el
  histórico en `CercanasRepositorio`; no cubriría Favoritos, que usa otro repositorio.
- **Carga perezosa por tarjeta**: `TarjetaGasolinera` pide `historico(id)` al montarse
  solo si no está en caché; `ListView.builder` limita a las tarjetas visibles (~6-8),
  muy por debajo de 30 pet/min. Sin prefetch del listado completo.
- **Tendencia**: última variación registrada en los 90 días (el último punto frente al
  anterior precio distinto, con precisión de milésima), de modo que los días planos no
  oculten una bajada o subida reciente. Verde ▼ baja, roja ▲ sube, neutra «=» si todo
  el periodo es igual; la flecha va a la derecha del precio.
- **Colores semánticos en el tema**: `ThemeExtension` en `lib/app/theme` con `bajada`,
  `subida` y `neutra` para claro y oscuro (paleta pine/ochre/moss); los widgets nunca
  usan literales.
- **Modal**: `showModalBottomSheet` con secciones por producto (etiqueta y unidad) y
  los últimos cambios de precio (hasta cinco) con fecha (dd/mm/aaaa) y precio; bajo
  cada producto, su variación («Baja 0,030 €/L desde el dd/mm/aaaa» o «Sin cambios en
  los últimos 90 días»). Estados de carga (indicador), error (mensaje en español +
  reintentar) y sin datos. Se abre desde el precio o la flecha; si el histórico no está
  cacheado, el modal dispara la consulta y muestra carga.
- **Fallo silencioso en la tarjeta**: sin histórico, la fila queda sin flecha y el
  precio sigue visible (cumple «sin bloquear»).

## Risks / Trade-offs

- [Ráfaga de peticiones al abrir listas largas] → cola de 4, caché por estación y solo
  tarjetas construidas; la caché evita reincidir al cambiar de sección (el límite
  pesado se comparte con `nearby`).
- [Huecos en la serie (días sin dato)] → la tendencia usa los dos últimos puntos
  disponibles y el modal lista los puntos existentes (menos de cinco si faltan).
- [429 por scroll rápido] → el error se traga (sin flecha) y el modal permite
  reintentar; sin reintento automático.
- [Igualdad de precios con coma flotante] → comparación redondeada a 3 decimales.
