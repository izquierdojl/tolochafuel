# Design

## Context

Ver `proposal.md` para la motivación. El change de características deja:

- Un `ComprobadorAvisos` inyectable que ya sabe leer favoritos, comparar precios,
  publicar notificaciones y actualizar la base.
- Una interfaz `ProgramadorAvisos` con una implementación de primer plano.
- La comprobación al abrir o reanudar, alineada con `meta.next_update`, y un bloqueo
  local para evitar solapamientos.
- Android como plataforma principal; Windows y Linux solo con comprobación al abrir.

Este change añade la ejecución con la app cerrada en Android mediante `workmanager`.
No cambia la UI, el contenido de las notificaciones ni la API.

## Goals / Non-Goals

**Goals:**

- Ejecutar la comprobación de avisos con la app cerrada en Android.
- Programarla después de las actualizaciones que anuncia `meta.next_update`, sin polling
  y sin alarmas exactas.
- Cancelar el trabajo cuando no haya campanas activas y reconciliar la programación al
  abrir o reanudar.
- Reutilizar el comprobador, el bloqueo y el notificador del change de características.

**Non-Goals:**

- Segundo plano en iOS, Windows o Linux.
- Alarmas exactas, exención de batería o un servicio en primer plano permanente.
- Push, FCM o backend.
- Cambiar el contenido o la agrupación de las notificaciones.

## Decisions

### Dependencia y aislamiento

- Se añade `workmanager` como dependencia de Android. El código se guarda con
  comprobaciones de plataforma para que Windows y Linux sigan compilando y usando la
  comprobación de primer plano.
- El punto de entrada de fondo es una función de nivel superior con
  `@pragma('vm:entry-point')` y `DartPluginRegistrant.ensureInitialized()`. Dentro del
  isolate se inicializan `shared_preferences` y
  `flutter_local_notifications`; no se usan controladores de UI ni `BuildContext`.
- El `callbackDispatcher` reutiliza `ComprobadorAvisos` con las mismas dependencias que
  la app, envueltas en implementaciones sin UI. Si el plugin no está disponible en la
  plataforma, la tarea no se registra.

### Programación

- Una única tarea one-off con nombre estable `comprobar_avisos_precio` y tarea
  `comprobarAvisosPrecio`, con `ExistingWorkPolicy.replace` para no duplicar trabajos.
- La demora se calcula desde `meta.next_update`:
  - Si hay fecha futura: `next_update + 5 min`.
  - Si la fecha ya pasó: `ahora + 1 h`, para no crear un bucle si la API aún no publicó.
  - Si no hay fecha: `ahora + 12 h`.
  - Nunca menos de 15 minutos desde ahora.
- Restricción de red `NetworkType.connected`. No se exige carga ni batería suficiente:
  un aviso de precio no debe esperar a estar enchufado.
- Después de cada comprobación se vuelve a programar con la nueva `meta.next_update` o
  con el respaldo. Si la comprobación no obtuvo metadatos, se mantiene el respaldo.
- No se usan `SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM` ni `setExact`. WorkManager puede
  retrasar la tarea por Doze o por la gestión de batería del fabricante; el aviso no es
  tiempo real y la UI ya lo explica.

### Cancelación y reconciliación

- `AvisosController` usa un `ProgramadorAvisos` con implementación WorkManager. Al
  activar una campana programa la siguiente comprobación; al apagarla, si no quedan
  avisos, cancela por nombre único.
- Al abrir o reanudar la app, `reconciliar()` lee los favoritos con aviso:
  - Sin avisos: cancela la tarea.
  - Con avisos: reprograma con la fecha absoluta de `meta.next_update` o con el
    respaldo. La política `replace` evita duplicados aunque se llame varias veces.
- Si el usuario fuerza la detención, Android cancela el trabajo hasta que vuelva a abrir
  la app; la reconciliación del arranque lo recupera.
- Un reinicio del dispositivo conserva la tarea de WorkManager; no hace falta un
  receptor de arranque propio.

### Coordinación con la comprobación de primer plano

- El bloqueo local `lock_hasta` del change de características se comparte entre el
  isolate de fondo y la app. El comprobador lo adquiere antes de consultar y lo libera al
  terminar; si está vigente, la otra comprobación no hace nada.
- Si la comprobación de fondo se salta por el bloqueo, no publica nada y deja que la
  comprobación de primer plano programe la siguiente. Si ambas intentan programar, la
  política `replace` deja una sola tarea con la misma fecha absoluta.
- La base de precios se actualiza después de publicar cada aviso. Si una escritura
  falla, el siguiente intento puede volver a comparar; la identidad estable de la
  notificación evita acumular avisos duplicados y el bloqueo limita la ventana.

### Fallos y límites

- Los errores de una estación no abortan el lote; se continúa con las demás. Si falla la
  primera ficha usada para leer metadatos, se prueba la siguiente.
- Un 429 o un fallo general detiene el lote, conserva las bases y programa el siguiente
  intento; no se reintenta en bucle cerrado.
- El `callbackDispatcher` captura las excepciones y devuelve éxito después de programar
  el siguiente intento, para no dejar que WorkManager reintente con una política
  agresiva. Si no se pudo programar, la reconciliación al abrir la app lo corrige.
- La concurrencia sigue limitada a 4 y el corte por `meta.last_updated` evita pedir
  todas las fichas cuando no hay datos nuevos.

### Plataformas y pruebas

- En Android se registra la tarea. En Windows y Linux el programador es el de primer
  plano del change de características; no se registra nada y la app sigue compilando.
- Tests unitarios del cálculo de demora, la cancelación y la reconciliación con un
  programador falso; tests del comprobador reutilizados del change de características.
- Verificación manual en el emulador Android:
  - Activar una campana y comprobar que se programa la tarea.
  - Cerrar la app, forzar una actualización de la base y comprobar la notificación con la
    app cerrada.
  - Apagar la última campana y comprobar que la tarea se cancela.
  - Force-stop y reapertura para verificar la reconciliación.
  - Revisar la cola con `adb shell dumpsys jobscheduler` o el inspector de WorkManager.

## Risks / Trade-offs

- **Doze y capas OEM** → el aviso puede llegar tarde; se documenta y no se promete
  puntualidad. No se pide exención de batería.
- **Force-stop** → no hay comprobaciones hasta reabrir; la reconciliación del arranque
  recupera la programación.
- **Consumo de batería y datos** → una sola tarea, restricción de red, corte por
  `meta.last_updated` y cancelación cuando no hay avisos.
- **Tareas duplicadas** → nombre único y `ExistingWorkPolicy.replace`.
- **Plugin en el isolate de fondo** → `DartPluginRegistrant.ensureInitialized()` y
  inicialización explícita de preferencias y notificaciones; prueba manual en Android.
- **Windows/Linux** → `workmanager` no se usa; no se altera su comprobación de primer
  plano ni el build.
- **Actualización o downgrade de la app** → la tarea usa nombres estables; una versión
  anterior que no conozca el callback puede dejar la tarea sin efecto, sin afectar a la
  app. La reconciliación de la versión nueva la recupera.
- **Permiso de notificaciones revocado** → la tarea puede ejecutarse pero el sistema no
  muestra el aviso; la app mantiene el estado y avisa en la UI.
- **Aviso de Kotlin Gradle Plugin de `workmanager_android`** → Flutter 3.50.1 compila y el
  job funciona, pero el build avisa de que futuras versiones de Flutter exigirán Built-in
  Kotlin. Se revisará al actualizar Flutter; no bloquea este change.

## Migration Plan

- Añadir `workmanager` y registrar el programador en `main` solo en Android.
- No hay migración de datos: las campanas y bases existentes se leen igual. En el
  primer arranque tras actualizar, `reconciliar()` programa la tarea si hay avisos.
- Rollback: la app anterior ignora la tarea; WorkManager puede ejecutarla sin efecto. No
  se modifica la API ni los datos del usuario.

## Verificación manual

- Emulador `TolochaFuel_Capturas` (Android 37, `emulator-5556`) con APK debug. Se usó un
  segundo emulador porque el primero estaba compartido con otro agente.
- Favorito con campana y base de precios preparados en el dispositivo; la app programó la
  tarea de WorkManager a +2 h 3 min con restricción de red.
- Se mató el proceso de la app, se puso la próxima comprobación en el pasado y se forzó el
  job. Para saltar el retardo inicial de WorkManager se ajustó `last_enqueue_time` en su
  base de datos local del emulador (técnica de prueba, no código de la app). La tarea de
  fondo publicó la notificación con los cuatro cambios y la fecha de los datos, actualizó
  la base y programó la siguiente tarea a +9 h.
- Force-stop: la tarea desaparece y se vuelve a programar al abrir la app.
- Reinicio del dispositivo: la tarea sigue programada.
- Sin favoritas con campana: la tarea se cancela y la base se vacía.
- El toque en la notificación y la ficha se verificaron en el change de características y
  en el widget test del shell; la notificación de fondo usa el mismo payload.
- Build Linux debug verificado con el clang del NDK (el entorno no tiene clang de
  sistema). Windows no se puede compilar en Linux; `workmanager` no añade código nativo
  para Windows y la CI lo validará en el push.

## Open Questions

_(ninguna: el horario de silencio y la selección de carburantes quedan fuera de alcance;
la cadencia se decide con `meta.next_update`, no con una preferencia del usuario.)_
