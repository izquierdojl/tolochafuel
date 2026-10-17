# Proposal

## Why

La sección Más económicas ordena siempre por Gasolina 95: quien reposta otro carburante
no puede usarla con el suyo y quien quiere una referencia de conjunto no tiene ninguna
opción de media. La API ya permite pedir el ranking por cualquiera de sus seis
carburantes (`fuel` en `/v1/stations/cheapest`) y la app ya descarga la ficha de cada
estación, así que el criterio de orden configurable es un cambio acotado.

## What Changes

- Selector «Ordenar por» en la cabecera de Más económicas con seis carburantes —Gasolina
  95, Gasolina 98, Gasóleo A, Gasóleo premium, GLP y GNC— y «Media de carburantes». Por
  defecto sigue Gasolina 95 (comportamiento actual).
- Con un carburante como criterio se consulta `/v1/stations/cheapest` con `fuel=<id>`
  (como hoy con `gasoline_95`), respetando `lat`, `lng`, `radius_km` y `limit` ≤ 50.
- Con «Media de carburantes» la app calcula con las fichas (`/v1/stations/{id}`) de las
  estaciones más cercanas del radio (hasta 50, límite de la API) el precio medio en €/L
  de los carburantes de cada estación, descarta los precios en €/kg y los productos
  no-carburante (p. ej. AdBlue), y ordena de menor a mayor.
- La elección se guarda en los ajustes locales (`shared_preferences`), se conserva entre
  ejecuciones y la cabecera indica el criterio activo.
- El estado vacío se adapta: si el carburante elegido no tiene estaciones en el radio,
  sugiere probar otro criterio o ampliar el radio.
- Se mantienen los límites de la API y la caché en memoria por criterio (y de fichas por
  estación, con su TTL, como hoy).

## Capabilities

### New Capabilities

_(ninguna)_

### Modified Capabilities

- `gasolineras-cercanas`: el requisito «Listado Más económicas» pasa a ser configurable
  por carburante y se añade el criterio de media de carburantes, con su persistencia y
  sus estados.

## Impact

- Código: `lib/core/models/carburante.dart` (seis carburantes) y nuevo criterio en
  `lib/core/models/`; `lib/core/api/precios_gasolina_api.dart` (parámetro `fuel`);
  `lib/features/cercanas/data/` (media y orden por criterio, claves de caché);
  `lib/features/cercanas/ui/mas_economicas_controller.dart` y
  `mas_economicas_pantalla.dart` (selector y estados);
  `lib/features/configuracion/` (ajuste persistido y `cambiarCriterioEconomicas`).
- Tests: modelos, API, repositorio, ajustes, controlador y widget de Más económicas.
- Sin dependencias nuevas y sin cambios de endpoint: solo `fuel` (ya documentado). Todas
  las plataformas (Android, Windows y Linux).

## Fuera de alcance

- Cercanas: conserva el orden por distancia (decisión del usuario).
- Criterio de orden configurable en Buscar, Favoritos o Cercanas.
- Orden por media en la API (no existe endpoint); nada de backend ni caché propia.
- Ponderar la media por distancia u otros factores, o configurar qué carburantes entran
  en ella.
- Mostrar estaciones sin ningún precio computable en el ranking por media.
- Cambios en Configuración → Acerca de, atribución o frescura de los datos.
