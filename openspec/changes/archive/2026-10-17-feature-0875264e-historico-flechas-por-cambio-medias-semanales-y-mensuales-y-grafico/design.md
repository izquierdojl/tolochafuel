# Design

## Context

El modal de histórico (`lib/features/cercanas/ui/widgets/detalle_historico.dart`) pinta
por producto la lista de `SerieCarburante.cambios()` (fecha + precio, sin dirección) y
debajo `_ResumenVariacion`, el texto confuso que este change retira. La tarjeta
(`tarjeta_gasolinera.dart`) ya tiene una `_FlechaTendencia` privada que usa
`ColoresTendencia` (bajada/subida/neutra) para la tendencia de la última variación.

El histórico se pide una vez por estación con `/v1/stations/{id}/history?days=90`
(consulta pesada, cacheada en `HistorialController` hasta `meta.next_update`); la
respuesta es diaria (`resolution: "day"`) con un punto por día aunque no cambie el
precio. No hay que tocar `precios_gasolina_api.dart` ni la caché: medias y gráfico son
cálculos derivados de `SerieCarburante`. Ver `proposal.md` - Why y el delta de specs
para los requisitos.

## Goals / Non-Goals

**Goals:**

- Dirección de cada cambio visible en la lista (flecha por fila, mismos colores y
  semántica que la tarjeta).
- Resumen pulsable por producto con media de 7 y 30 registros y flecha contra la
  ventana anterior, sustituyendo el texto actual.
- Gráfico de línea expandible con los 90 días y tooltip al tocar; `fl_chart` como
  dependencia (decisión explícita del usuario).
- Cómputos derivados en el modelo (`core`) para no meter lógica en widgets y poder
  testearlos sin pintar.

**Non-Goals:**

- Cambios en la tarjeta, en la API, en la caché o en los límites.
- Ranges seleccionables, zoom, exportación, persistir el estado expandido.
- Medias ponderadas por tiempo o más ventanas que semana/mes.

## Decisions

- **`fl_chart` (`^1.2.0`)**: elegida por decisión explícita del usuario sobre
  CustomPainter; MIT, Dart puro (Android, Windows y Linux) y con tooltips y ejes
  resueltos. Arrastra `equatable`. La gobernanza del stack se actualiza en el mismo
  change: `AGENTS.md` (§2) y el contexto de `openspec/config.yaml` añaden la librería;
  si no, la próxima consulta al stack daría una foto falsa.

- **Cálculos en `lib/core/models/historico_estacion.dart`** (el modelo ya deriva
  `cambios()` y `variacion`; las medias viven ahí y se testean sin widgets):
  - `cambios()` pasa a devolver `CambioPrecio` (`punto`, `tendencia`, `delta`) en vez
    de `PuntoPrecio`: la tendencia sale de comparar con el punto anterior del histórico
    (la fila es un cambio, así que solo puede ser `baja` o `sube`).
  - `media(int registros)` → media aritmética de los últimos `n` puntos, o `null` si
    no hay al menos `n` (la fila no se pinta).
  - `tendenciaMedia(int registros)` → compara la media de los últimos `n` con la de
    los `n` anteriores a tres decimales (misma granularidad que `variacion`); devuelve
    `desconocida` si no hay 2×n puntos (sin flecha). Alternativa descartada: comparar
    primer y último precio de la ventana (más ruidoso y elegido en contra por el
    usuario); y comparar el precio actual con la media (posición, no tendencia).

- **Widget `FlechaTendencia` compartido**: se extrae la `_FlechaTendencia` privada de
  la tarjeta a `lib/features/cercanas/ui/widgets/flecha_tendencia.dart` para usarla en
  tarjeta, filas del modal y filas de medias. Conserva `semanticLabel` en español
  («Precio al alza», «Precio a la baja»). Sin colores literales: `ColoresTendencia`.

- **Bloque de resumen y gráfico**:
  - `_SeccionProducto` (hoy `StatelessWidget`) pasa a mantener el estado de expansión
    de su bloque de medias; el modal ya está dentro de un `SingleChildScrollView`, así
    que expandir no requiere diálogo ni pantalla nueva. Alternativa descartada: los
    `ExpansionTile` (estética material más pesada y sin el patrón de flecha propio).
  - El bloque muestra las filas «Última semana»/«Último mes» con `formatearPrecio(...,
    unidad: producto.unidad)` (cubre GNC en €/kg) y su flecha, y un icono de gráfico
    como pista de que es pulsable; `Semantics` con etiqueta «Ver gráfico de precios».
  - Gráfico en `lib/features/cercanas/ui/widgets/grafico_historico.dart` con
    `LineChart`: eje X por índice (con etiquetas dd/mm en extremos y centro), eje Y con
    mínimo/máximo y margen cuando la serie es plana (línea centrada, no pegada al
    borde), línea y punto final con `colorScheme`, área con degradado suave, líneas
    discontinuas de las medias de semana y mes cuando existan, y `LineTouchData` con
    tooltip que usa `formatearFecha`/`formatearPrecio`. El texto del tooltip se arma en
    una función pura para poder testearlo sin gestos.

- **Estados**: sin carga ni peticiones nuevas — el bloque y el gráfico solo se pintan
  con `historico` disponible, de modo que los estados del modal (carga, error con
  reintentar, sin histórico) quedan como hoy. Con menos de 7 registros no hay filas de
  medias; con menos de 2 no hay gráfico (ver escenarios del delta de specs).

## Risks / Trade-offs

- [La flecha del mes puede apuntar contra el movimiento reciente (arrastra el mes
  anterior)] → es la semántica acordada («media vs. media»); lista de cambios y gráfico
  dan el detalle fino, y la spec fija la interpretación.
- [Comparaciones a tres decimales pueden marcar flecha con diferencias mínimas] →
  coherente con la granularidad de precios de la API (3 decimales) y con `variacion`;
  el «=» aparece cuando redondean igual.
- [`fl_chart` añade mantenimiento y una dependencia de UI] → versión fijada en
  `pubspec.yaml`, licencia MIT y puro Dart; queda documentada en `AGENTS.md`, donde
  consta como decisión del usuario.
- [Series planas o muy cortas en el gráfico] → margen simétrico de eje Y, mínimo de 2
  puntos y escenarios de serie plana e histórico corto en las specs.
- [El modal crece al expandir en pantallas pequeñas] → ya es desplazable; el gráfico
  tiene altura acotada y el bloque se contrae al pulsar de nuevo.
- [Los textos de los tests actuales fijan el resumen antiguo] → se reescriben en
  `historico_tarjeta_test.dart` junto con los nuevos casos (flechas, medias, gráfico),
  sin tocar `variacion`, que la tarjeta sigue usando.
