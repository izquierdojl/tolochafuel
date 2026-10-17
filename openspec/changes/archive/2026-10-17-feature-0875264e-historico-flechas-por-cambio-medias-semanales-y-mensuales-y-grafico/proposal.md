# Proposal

## Why

El modal de histórico muestra, bajo la lista de últimos cambios, un texto —«Baja
0,019 €/L desde el 05/10/2026»— que resume solo el último escalón y se lee como un
cambio acumulado desde esa fecha: no significa lo que parece y confunde. Además, los
cambios no tienen indicación gráfica de dirección y no hay forma de ver la evolución
del precio. El histórico diario (90 días) ya se descarga y cachea para la tarjeta, así
que se puede aprovechar para mostrar la dirección de cada cambio, medias de la última
semana y del último mes y un gráfico, sin peticiones nuevas.

## What Changes

- Flecha de subida o bajada (colores de tendencia del tema) a la derecha de cada fila
  de «últimos cambios de precio», indicando la dirección de ese cambio concreto.
- Se retira el texto «Baja/Sube X desde el Y» y su caso neutro heredado («Sin cambios
  en los últimos 5 días»), que no aportan y confunden.
- Nuevo bloque pulsable bajo los cambios de cada producto: media de los últimos 7
  registros diarios («Última semana») y de los últimos 30 («Último mes») en la unidad
  del producto, cada una con flecha de tendencia que compara su media con la del
  periodo anterior de igual duración (7 y 30 registros previos). «=» si coinciden a
  tres decimales; sin flecha si no hay ventana anterior completa (14 y 60 registros).
- Al pulsar el bloque se expande un gráfico de línea con los últimos 90 días del
  producto, punto final resaltado y tooltip con fecha y precio al tocar un punto, con
  los colores del tema (nueva dependencia `fl_chart`, decisión explícita del usuario).
- Todo sale del histórico ya cacheado (`/v1/stations/{id}/history?days=90`): sin
  peticiones nuevas, sin cambios de caché ni de límites, y sin cambios en la API.
- La gobernanza del stack se actualiza: `AGENTS.md` (§2) y `openspec/config.yaml` añaden
  `fl_chart` a la lista de librerías.

## Capabilities

### New Capabilities

_(ninguna)_

### Modified Capabilities

- `historico-precios`: el requisito «Detalle de los últimos cambios de precio» añade la
  flecha de dirección por fila y pierde el escenario de resumen en texto; se añade el
  requisito «Medias por ventana y gráfico del precio» con sus estados.

## Impact

- Código: `lib/core/models/historico_estacion.dart` (media por ventana y dirección por
  cambio), `lib/features/cercanas/ui/widgets/detalle_historico.dart` (flechas por fila,
  bloque de medias y gráfico expandible, posible widget nuevo del gráfico),
  `pubspec.yaml` (`fl_chart`).
- Tests: `historico_estacion_test.dart` (medias y flechas), `historico_tarjeta_test.dart`
  (se actualizan los textos retirados; flechas por fila, bloque de medias y gráfico) y
  un widget test del gráfico.
- Documentación de gobernanza: `AGENTS.md` (§2, stack) y `openspec/config.yaml`
  (contexto).
- Plataformas: todas (Android, Windows y Linux); `fl_chart` es Dart puro.
- API, caché y límites: sin cambios; no hay endpoints ni campos nuevos.

## Fuera de alcance

- La tarjeta de gasolinera: conserva su flecha de última variación como hasta ahora.
- Selector de rango (7/30/90 días), zoom, exportación o más interactividad que el
  tooltip al tocar.
- Conservar el estado expandido/colapsado del gráfico entre aperturas del modal.
- Cambios en la lista de cambios: sigue agrupada por producto y limitada a cinco.
- Históricos de más de 90 días (límite de la API).
- Atribución y frescura de los datos: siguen en Configuración → Acerca de.
