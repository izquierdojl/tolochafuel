# Proposal

Tipo: infra

## Why

El change `feature-81a10845-avisos-de-precio-en-gasolineras-favoritas` deja la
comprobación al abrir o reanudar la app. Para que el aviso llegue con la app cerrada en
Android hace falta trabajo en segundo plano. WorkManager es la API del sistema para
trabajo diferible y permite alinearlo con `meta.next_update` sin polling.

## What Changes

- Añadir `workmanager` y un `callbackDispatcher` de nivel superior para ejecutar la
  comprobación en un isolate de fondo.
- Programar una tarea one-off después de `meta.next_update` (con un margen corto) y
  recalcular la siguiente a partir de la nueva fecha devuelta por la API. Si no hay
  fecha, usar un respaldo de 12 horas.
- Cancelar la tarea cuando no quede ninguna campana activa y reconciliar la
  programación al abrir o reanudar la app.
- Releer los favoritos y el estado de la campana justo antes de publicar, para no
  notificar si la estación se desmarcó o el aviso se apagó mientras se comprobaba.
- Evitar comprobaciones solapadas entre el isolate de fondo y la app en primer plano
  mediante un bloqueo local con caducidad.
- Manejar los fallos de la API por estación sin abortar el lote; si la comprobación
  falla, se reintenta en la siguiente programación.
- Verificar en el emulador Android con la app cerrada y con la app en segundo plano, y
  documentar que Doze y las capas de batería de algunos fabricantes pueden retrasar el
  aviso.

Plataformas afectadas: Android (segundo plano). Windows y Linux mantienen la
comprobación al abrir o reanudar; no hay segundo plano fiable en el escritorio.

## Capabilities

### New Capabilities

_(ninguna)_

### Modified Capabilities

- `avisos-precio`: se añade la comprobación con la app cerrada en Android, la
  programación y cancelación del trabajo de fondo y la reconciliación al abrir.

## Impact

- Dependencias: `workmanager`.
- Código: nuevo servicio de programación y de fondo, integración en `lib/main.dart` y
  reutilización del comprobador del change de características.
- Android: componentes y metadatos que añade WorkManager; sin alarmas exactas ni
  exención de batería.
- Tests: programación/cancelación con un programador falso, lógica de `next_update` y
  comprobador en segundo plano; verificación manual en Android.
- Depende de `feature-81a10845-avisos-de-precio-en-gasolineras-favoritas`; no se
  empieza hasta archivar ese change.
- Sin cambios en la API, en el contenido de las notificaciones ni en la UI.

## Fuera de alcance

- Comprobación en segundo plano en iOS, Windows o Linux.
- Alarmas exactas, `SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM` o exención de optimización
  de batería.
- Push, FCM o backend propio.
- Cambiar el contenido, la agrupación o la ficha de las notificaciones; se reutiliza lo
  definido en el change de características.
- Programar comprobaciones con intervalos periódicos fijos; la fuente manda con
  `meta.next_update`.
