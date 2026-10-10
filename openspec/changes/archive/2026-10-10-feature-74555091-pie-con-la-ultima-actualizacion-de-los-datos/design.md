# Design

## Context

`MetaDatos` ya parsea `last_updated`, `data_age_seconds` y `stale`, y `textoFrescura()`
existe sin uso. Los controladores de listas descartan `resultado.meta`
(`cercanas_controller.dart` y equivalentes); Favoritos solo conserva
`proximaActualizacion` en `DetalleEstacion`. Las pantallas son `ListView` dentro del
cuerpo del shell. Ver `proposal.md` - Why.

## Goals / Non-Goals

**Goals:**

- Pie visible y no intrusivo en las cuatro listas, con fecha global y antigüedad.
- Aviso de `stale` sin bloquear.
- Un único widget y una única fuente de verdad (el meta de la respuesta).

**Non-Goals:**

- Hora por estación (`price_updated_at`) en las tarjetas.
- Refresco automático o polling por frescura.
- Tocar la atribución de Configuración → Acerca de.

## Decisions

- **Guardar `MetaDatos` en los controladores**: `CercanasController`,
  `MasEconomicasController` y `BuscarController` exponen `meta` (el de la última
  respuesta con éxito). El pie es un widget sin lógica que recibe `MetaDatos?`.
- **Favoritos**: `DetalleEstacion` conserva el `MetaDatos` de la ficha (se amplía el
  parseo en `PreciosGasolinaApi.detalle`); `FavoritosController` expone el meta de la
  última ficha cargada (la fecha global es la misma para todas). Si no hay ninguna, el
  pie usa el texto genérico de `textoFrescura`.
- **Widget compartido `PieFrescura`** en `lib/features/cercanas/ui/widgets/` (mismo
  criterio que `TarjetaGasolinera`, ya compartida con Favoritos). Reutiliza
  `textoFrescura`; si `meta.stale`, añade el aviso «pueden ser datos de la
  actualización anterior» con color de aviso del tema.
- **Ubicación**: `Column` con `Expanded(lista)` y el pie al final del cuerpo, fijo, en
  las cuatro pantallas; solo se pinta en estados con datos o vacío (nunca en error ni
  durante la carga).
- **Colores solo del tema**: el aviso `stale` usa un color de la paleta
  (`colorScheme.secondary`/`tertiary`); no se introducen literales en widgets.

## Risks / Trade-offs

- [Favoritos sin ninguna ficha cargada no tiene fecha] → texto genérico; coherente con
  `textoFrescura(null)`.
- [Duplicar el pie en cuatro pantallas] → widget único y cuatro puntos de integración
  de una línea.
- [La antigüedad «hace X h» no se refresca sola] → se recalcula al reconstruir la
  pantalla (cambio de estado o notificación); no se añade temporizador.
