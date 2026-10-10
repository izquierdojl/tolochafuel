# Design

## Context

La sección Favoritos carga las fichas en el `initState` de su pantalla
(`favoritos_pantalla.dart`), pero el shell usa un `IndexedStack` que conserva la
pantalla viva una vez visitada: marcar un favorito después no dispara ninguna consulta.
`FavoritosController.cargarDetalle` ya existe con caché (`_detalles`), deduplicación
(`_consultando`) y errores por id. Ver `proposal.md` - Why.

## Goals / Non-Goals

**Goals:**

- Que marcar un favorito deje su tarjeta lista con precio sin recrear la pantalla.
- Reutilizar el mecanismo de consulta y error existente; sin cambios de interfaz.

**Non-Goals:**

- Unificar cachés entre features (`CercanasRepositorio` y `FavoritosController`).
- Persistir productos en `Favorito`.

## Decisions

- **Disparar la consulta en `agregar()`**, no en la pantalla: es lógica de negocio del
  controlador (regla de arquitectura) y funciona con cualquier lista que marque
  favoritos (Cercanas, Más económicas, Buscar). Alternativa descartada: que la pantalla
  de Favoritos detecte ids nuevos al construir; mete lógica en el widget y depende de
  que la pantalla esté montada.
- **No bloquear la marca**: se persiste primero y la consulta se lanza después sin
  bloquear el flujo del usuario; si falla, `_erroresDetalle` ya pinta el aviso con
  «Reintentar». `cargarDetalle` es idempotente (caché + `_consultando`), así que no hay
  peticiones duplicadas.
- **Sin cambios en `Favorito`**: los precios no se persisten (quedarían caducados); la
  fuente sigue siendo `/v1/stations/{id}`.
- La consulta al marcar no reutiliza la caché de fichas de `CercanasRepositorio`
  (instancias distintas); es una petición de las de 120 pet/min, aceptable.

## Risks / Trade-offs

- [Petición extra al marcar una estación ya cacheada por Cercanas] → aceptada: límite
  de fichas 120 pet/min y solo una por favorito nuevo.
- [La consulta falla y el usuario cree que no se marcó] → el corazón cambia al
  instante (estado en memoria + persistencia) y el error de precio aparece con
  reintento.
