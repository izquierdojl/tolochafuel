# Tasks

> Cada tarea se cierra con `flutter analyze` y `flutter test` en verde, además de la
> verificación indicada.

## 1. Modelo y persistencia

- [x] 1.1 Añadir `avisosPrecio` (booleano, por defecto `false`) a `Favorito`, con parseo tolerante y serialización; verificación: tests de ida y vuelta y de JSON antiguo sin el campo en `test/features/favoritos_repositorio_test.dart` y `flutter analyze` en verde.
- [x] 1.2 Añadir `marcarAviso(id, bool)` a `FavoritosController` y al repositorio, conservando el orden y la cola de persistencia; verificación: tests de activar, desactivar, fallo de guardado y desmarcar en `test/features/favoritos_controller_test.dart`.
- [x] 1.3 Crear `AvisosRepositorio` con la clave `avisos_precios_v1` (estaciones, precios en milésimas, `last_updated`, `actualizado_en`, `ultima_comprobacion`, `ultimo_last_updated`, `lock_hasta`) usando `SharedPreferencesAsync`; verificación: tests de ida y vuelta, JSON corrupto, ausencia de clave y comparación en milésimas.
- [x] 1.4 Añadir lectura asíncrona de favoritos y alias para el comprobador con `SharedPreferencesAsync`, sin cambiar la lectura de la UI; verificación: tests de ambos repositorios y `flutter analyze` en verde.
- [x] 1.5 Reconciliar bases huérfanas al arrancar (estaciones que ya no son favoritas o no tienen campana) sin notificar; verificación: test con una base de una estación desmarcada y con `flutter analyze` en verde.

## 2. Notificaciones locales

- [x] 2.1 Añadir `flutter_local_notifications` a `pubspec.yaml`, inicializar el plugin en `main` con el canal `avisos_precio`, el icono y los callbacks de toque; verificación: `flutter pub get`, `flutter analyze` y arranque en el emulador.
- [x] 2.2 Declarar `POST_NOTIFICATIONS` en el manifiesto Android y añadir el icono monocromo de notificación; verificación: `flutter test test/android_manifest_test.dart` y revisión del recurso.
- [x] 2.3 Implementar `NotificacionesServicio` (permiso, `areNotificationsEnabled`, mostrar, cancelar, `getNotificationAppLaunchDetails` y payload JSON id/nombre) con una interfaz falsa para tests; verificación: tests unitarios de permiso concedido y denegado, payload válido e inválido y cancelación.
- [x] 2.4 Implementar el formateo del aviso (alias o nombre, uno o varios carburantes, precio anterior y nuevo, fecha o texto genérico, `stale` y agrupación); verificación: tests de uno, varios, alias, sin fecha y stale.
- [x] 2.5 Añadir la comprobación de notificaciones desactivadas en el sistema y el mensaje en español; verificación: test del servicio/controlador con el estado desactivado.

## 3. Comprobador y base

- [x] 3.1 Implementar la diferencia de precios en milésimas y el filtro de carburantes (`Carburante`), ignorando AdBlue, productos no carburante y carburantes nuevos o desaparecidos; verificación: tests de bajada, subida, sin cambio, nuevo, desaparecido y AdBlue.
- [x] 3.2 Implementar `ComprobadorAvisos` con lectura de favoritos con aviso, bloqueo local con caducidad, corte por `meta.last_updated` y creación de base sin notificación; verificación: tests con API, repositorios y reloj falsos.
- [x] 3.3 Completar `ComprobadorAvisos` con consulta de fichas, concurrencia 4, errores por estación, verificación de favorito y campana antes de publicar y actualización de base y metadatos; verificación: tests de lote, error parcial, desmarcar durante la comprobación y no duplicar avisos.
- [x] 3.4 Definir la interfaz `ProgramadorAvisos` (`programar(DateTime?)`, `cancelar()`) y una implementación de primer plano; verificación: tests de que el comprobador programa la siguiente fecha o cancela sin avisos.
- [x] 3.5 Implementar la comprobación forzada al activar una campana para crear la base sin notificar; verificación: test de activación con y sin conexión.

## 4. Campana y activación

- [x] 4.1 Implementar `AvisosController` (provider en `main`) con activar/desactivar, permiso, base, persistencia, programación y reconciliación; verificación: tests de activación, desactivación, permiso denegado, fallo de base y cancelación.
- [x] 4.2 Añadir la fila `SwitchListTile` de campana en `_FavoritoReordenable`, fuera del gesto de arrastre y solo en Favoritas; verificación: widget tests de estado on/off, texto y ausencia en una tarjeta no favorita.
- [x] 4.3 Conectar la campana con `AvisosController` y mostrar los mensajes de permiso denegado, notificaciones desactivadas y base pendiente; verificación: widget tests y prueba manual en el emulador.
- [x] 4.4 Verificar que desmarcar el favorito elimina la campana y la base, y que volver a marcarlo empieza apagado; verificación: tests de controlador, repositorio y widget.

## 5. Ficha y toque en la notificación

- [x] 5.1 Extraer la sección de histórico reutilizable de `DetalleHistorico` sin cambiar el modal actual; verificación: tests existentes de histórico y widget del modal en verde.
- [x] 5.2 Crear `FichaEstacionSheet` con precios actuales, histórico, navegar, favorito y campana; verificación: widget tests de carga, datos, error, sin precios, favorita y no favorita.
- [x] 5.3 Implementar el parser del payload y `NavegacionAvisosController` (pendiente, cold start y app en marcha); verificación: tests unitarios de payload válido e inválido y de la cola de navegación.
- [x] 5.4 Integrar `getNotificationAppLaunchDetails` y el callback de toque en `main` y `ShellPantalla` para abrir la ficha tras el primer frame; verificación: widget test de estación pendiente y prueba manual con la app cerrada.
- [x] 5.5 Manejar estación que ya no es favorita, estación inexistente y error de consulta en la ficha; verificación: widget tests de esos tres estados.

## 6. Comprobación al abrir y cierre

- [x] 6.1 Enganchar `ComprobadorAvisos` al ciclo de vida (`resumed`) y al arranque, respetando `next_update`, el bloqueo y la ausencia de polling; verificación: tests con reloj fijo y un comprobador falso.
- [x] 6.2 Actualizar `docs/uso.md`, `docs/arquitectura.md` y `docs/datos.md` con la campana, la ficha, las plataformas y los límites; verificación: revisar que los comandos y enlaces citados existen.
- [x] 6.3 Prueba manual en Android: activar campana, crear base, simular un cambio, recibir la notificación, tocar y abrir la ficha, desmarcar y comprobar que no queda aviso; verificación: registrar el resultado en el change.
- [x] 6.4 Ejecutar `dart format .`, `flutter analyze`, `flutter test` y `bash scripts/check_changes.sh`; verificación: todos en verde.

## Workflow follow-up

- Archivar el change después de la revisión y de que la CI esté en verde.
- Commit en `dev` con mensaje convencional y push.
- No empezar el change de infraestructura hasta archivar este.
