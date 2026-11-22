# Design

## Context

Ver `proposal.md` para la motivación. El estado actual que condiciona el diseño:

- `Favorito` es inmutable y se serializa como JSON en una única clave de
  `shared_preferences`; `FavoritosController` es global y comparte el estado con todas
  las listas. La tarjeta ya tiene corazón, navegar, alias y reordenación.
- No hay pantalla de ficha: el detalle de una estación es la tarjeta y el histórico se
  abre en el bottom sheet `DetalleHistorico`.
- La API es la única fuente: `GET /v1/stations/{id}` devuelve precios por carburante y
  `meta.last_updated`, `meta.next_update` y `meta.stale`. Los datos se actualizan dos
  veces al día y no hay backend ni push.
- No hay infraestructura de notificaciones. Este change añade
  `flutter_local_notifications`; el trabajo de fondo con WorkManager queda para el
  change de infraestructura.

## Goals / Non-Goals

**Goals:**

- Avisos por favorito con una base local de precios y detección de cambios.
- Notificación local con los precios nuevos y apertura de una ficha en bottom sheet.
- Comprobación al abrir o reanudar, alineada con `meta.next_update` y sin polling.
- Dejar una interfaz de programación y un comprobador reutilizables por el change de
  segundo plano.

**Non-Goals:**

- Comprobar con la app cerrada (WorkManager), push, iOS o web.
- Elegir carburantes por favorito, silencio nocturno o alertas de disponibilidad.
- Cambiar la API, el modelo de datos remoto o la atribución.

## Decisions

### Estructura y propiedad del estado

- Nueva feature `lib/features/avisos/`:
  - `data/`: `AvisoPrecio`, `AvisosRepositorio` y el formato de la base local.
  - `services/`: `ComprobadorAvisos`, diferencia de precios, formateo del aviso,
    `NotificacionesServicio`, `ProgramadorAvisos` y enrutado del toque.
  - `ui/`: fila de campana, ficha y diálogos de permiso/error.
- `FavoritosController` sigue siendo el dueño de la lista y del orden. El estado de la
  campana vive en `Favorito.avisosPrecio` (booleano, por defecto `false`), de modo que
  desmarcar un favorito elimina el aviso por construcción. `AvisosController` orquesta
  permiso, base, comprobación y programación, y actualiza el booleano a través de
  `FavoritosController`.
- La ficha se abre desde la notificación y no cambia el patrón de navegación: un
  `showModalBottomSheet` sobre la sección actual. No se añade una ruta ni una pantalla
  nueva.

### Persistencia

- `Favorito.fromJson` tolera la ausencia de `avisosPrecio` y lo escribe en `toJson`; los
  favoritos ya guardados siguen cargando y empiezan con la campana apagada.
- La base de precios va en una clave nueva `avisos_precios_v1`, separada de
  `favoritos`, para que la escritura del estado de aviso no compita con el orden de la
  lista. Formato:
  ```
  {
    "estaciones": {
      "123": {
        "precios": {"gasoline_95": 1459, "diesel": 1399},
        "last_updated": "2026-11-22T08:00:00Z",
        "actualizado_en": "2026-11-22T08:12:00Z"
      }
    },
    "ultima_comprobacion": "2026-11-22T08:12:00Z",
    "ultimo_last_updated": "2026-11-22T08:00:00Z",
    "lock_hasta": null
  }
  ```
- Los precios se guardan en milésimas enteras (`precio * 1000`) para comparar sin
  errores de coma flotante. Solo se guardan carburantes reconocidos por `Carburante`.
- `AvisosRepositorio` usa `SharedPreferencesAsync` para no depender de la caché de
  `SharedPreferences` y dejar preparado el isolate de fondo. `FavoritosRepositorio`
  añade una lectura asíncrona para el comprobador; la UI conserva la lectura actual.

### Comprobador y detección

`ComprobadorAvisos` recibe por constructor `PreciosGasolinaApi`, repositorios, reloj,
notificador y programador, para poder probarlo sin red ni plugins. El flujo es:

1. Leer favoritos y quedarse con los que tienen `avisosPrecio`.
2. Si no hay ninguno, cancelar la programación y terminar.
3. Adquirir un bloqueo local con caducidad (5 minutos) para evitar solapamientos entre
   comprobaciones.
4. Si hay base y `meta.next_update` aún no pasó, no consultar.
5. Consultar una ficha para leer `meta.last_updated`. Si no cambió y todas las avisadas
   tienen base, terminar tras esa petición.
6. Consultar el resto de fichas con concurrencia limitada (4), respetando los límites
   de la API.
7. Para cada estación: si no hay base, guardarla sin notificar; si hay base, calcular
   los carburantes cuyo precio en milésimas cambió. Ignorar carburantes nuevos,
   desaparecidos, AdBlue y productos que no son carburante.
8. Releer el favorito y la campana; si la estación ya no es favorita o el aviso se
   apagó, descartar el aviso.
9. Publicar una notificación por estación y actualizar la base y los metadatos de la
   comprobación.
10. Programar la siguiente comprobación con `meta.next_update` o, si no existe, 12 horas.

La comprobación al activar la campana es forzada: crea la base de esa estación y no
notifica. Si la consulta falla, la base queda pendiente y la siguiente comprobación
correcta la establece sin avisar.

### Notificaciones

- `NotificacionesServicio` envuelve `FlutterLocalNotificationsPlugin` para poder usar
  un doble en tests. Se inicializa en `main` con el icono de notificación, el canal
  `avisos_precio` («Avisos de precio») y la devolución de llamada del toque.
- En Android 13+ se solicita `POST_NOTIFICATIONS` solo al activar la primera campana.
  Si se deniega, no se cambia el estado del favorito y se muestra una explicación en
  español. En el resto de plataformas no se pide permiso.
- Una notificación por estación, con identificador estable (el id de la estación) y
  `groupKey` común. Si cambian varios carburantes, el cuerpo muestra el resumen y el
  texto expandido enumera todos los cambios con precio anterior y nuevo, la fecha de
  `meta.last_updated` o el texto genérico, y el aviso de `meta.stale`.
- El alias se lee de `AliasRepositorio`; si no existe, se usa el nombre del favorito.
  La atribución completa sigue en Configuración → Acerca de.
- El payload es un JSON pequeño con `id` y `nombre` de la estación, para poder abrir la
  ficha aunque la estación ya no sea favorita o la consulta falle.

### Toque en la notificación y ficha

- `main` llama a `getNotificationAppLaunchDetails` antes de `runApp` y pasa la estación
  pendiente a la app. El callback de la notificación hace lo mismo cuando la app ya
  está en marcha.
- Un `NavegacionAvisosController` expone la estación pendiente; `ShellPantalla` la
  consume tras el primer frame y abre `FichaEstacionSheet` con un
  `GlobalKey<NavigatorState>` o el contexto del shell.
- `FichaEstacionSheet` muestra:
  - Nombre/alias, dirección si se conoce y estado 24h.
  - Precios actuales obtenidos de una ficha fresca, con los carburantes cambiados
    resaltados cuando el payload los identifica.
  - Acciones: navegar, favorito y campana (solo si es favorita).
  - Histórico reutilizando la sección de `DetalleHistorico`, extraída a un widget
    compartido para no duplicar la UI.
  - Estados de carga, error con reintento y sin precios. Si la estación ya no es
    favorita, no se muestra la campana; si se vuelve a marcar, aparece apagada.

### Campana en Favoritos

- `_FavoritoReordenable` añade una fila `SwitchListTile` al pie de la tarjeta, fuera de
  `ReorderableDelayedDragStartListener` para que el gesto de arrastre no interfiera.
- La fila tiene un icono de campana (`notifications_active_outlined` /
  `notifications_none`), el texto «Avisarme de cambios de precio» y la nota «Los datos
  se actualizan 2 veces al día».
- Al activar, `AvisosController` pide permiso, actualiza el booleano, persiste, crea la
  base y programa la siguiente comprobación. Si el permiso se deniega o la base falla,
  la interfaz explica el resultado y el interruptor refleja el estado real.
- Al desactivar, se borra el booleano y la base, y se reprograma o cancela el trabajo.
  Al desmarcar el favorito, el booleano desaparece con el objeto; la base huérfana se
  ignora y se limpia en la reconciliación de arranque.

### Comprobación al abrir o reanudar

- `AvisosController` se suscribe a `WidgetsBindingObserver` o se invoca desde el shell
  en `resumed`; tras cargar favoritos y ajustes, llama a `ComprobadorAvisos` si hay
  avisos y la comprobación está vencida.
- No hay temporizador ni polling mientras la app permanece abierta. La siguiente
  comprobación la marca `meta.next_update`; el change de infraestructura la ejecutará
  con WorkManager.
- `ProgramadorAvisos` es una interfaz con `programar(DateTime?)` y `cancelar()`. En este
  change se implementa una versión de primer plano (registra la próxima fecha y no
  programa trabajo del sistema); el change de infraestructura aporta la implementación
  con WorkManager sin tocar el comprobador.

### Plataformas

- Android: notificaciones locales y comprobación al abrir o reanudar. La app cerrada
  queda para el change de infraestructura.
- Windows y Linux: misma comprobación al abrir o reanudar. Se intenta la notificación
  local; si el entorno no la admite, se muestra un aviso dentro de la app. No se
  promete funcionamiento con la app cerrada.
- El código de notificaciones se inicializa solo en las plataformas soportadas; el
  resto de la app debe seguir compilando y funcionando sin plugins disponibles.

## Risks / Trade-offs

- **Permiso o canal desactivado** → la campana no se activa si el permiso se deniega;
  si se revoca después, la app avisa y no promete avisos. No se fuerza la exención de
  batería.
- **Falsos positivos por coma flotante** → comparación en milésimas enteras y base
  creada al activar.
- **Notificaciones duplicadas** → bloqueo local con caducidad, base actualizada tras
  publicar e identidad estable por estación. El change de fondo reutiliza el bloqueo.
- **Volumen de peticiones** → corte con una sola ficha cuando `meta.last_updated` no
  cambió, concurrencia 4 y cancelación cuando no hay avisos.
- **Notificación obsoleta tras desmarcar** → el payload conserva id y nombre; la ficha
  se abre sin campana y el comprobador vuelve a leer el favorito antes de notificar.
- **Windows/Linux** → la notificación local puede no estar disponible; fallback dentro
  de la app y sin promesa de segundo plano.
- **Nueva dependencia** → `flutter_local_notifications` se fija en `pubspec.yaml` y se
  verifican los builds de Android, Windows y Linux.
- **SharedPreferences entre isolates** → la base usa `SharedPreferencesAsync`; la
  lectura de favoritos para el comprobador también es asíncrona. La UI no comparte la
  caché con el futuro isolate de fondo.

## Migration Plan

- No hay migración de datos: `avisosPrecio` es opcional y por defecto `false`; la clave
  `avisos_precios_v1` se crea al activar la primera campana.
- Los favoritos existentes conservan orden e identidad. Un rollback de la app ignora
  los campos y claves nuevos.
- El release sigue el flujo habitual: archivar el change, commit en `dev`, PR a `main`
  y bump automático.

## Verificación manual

- Emulador `Medium_Phone_API_37.0` (Android 37) con APK debug.
- Flujo probado: favorito desde Buscar (Madrid, «Alcampo Jose Paulete»), campana en
  Favoritas, permiso de notificaciones, base guardada con los cuatro carburantes de la
  estación, simulación de una bajada editando la base local con la misma longitud en el
  almacén de preferencias, relanzamiento de la app y notificación con los cuatro cambios
  y la fecha de los datos. Al tocar la notificación se abrió la ficha con precios,
  histórico y campana.
- Incidencia encontrada: al desmarcar el favorito desde la ficha, `FavoritosController`
  borraba el detalle cacheado y la ficha pasaba a «Precios no disponibles». Se corrigió
  conservando ese detalle al quitar el favorito; queda cubierto por un widget test.
- La comprobación con la app cerrada no forma parte de este change; se aborda en
  `infra-56167d5b-comprobacion-de-avisos-en-segundo-plano`.

## Open Questions

_(ninguna: el horario de silencio y la selección de carburantes quedan fuera de alcance
y pueden abordarse en changes posteriores sin cambiar este diseño.)_
