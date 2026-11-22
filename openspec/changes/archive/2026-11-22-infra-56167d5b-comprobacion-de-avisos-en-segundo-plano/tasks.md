# Tasks

> Requisito previo: `feature-81a10845-avisos-de-precio-en-gasolineras-favoritas`
> archivado y con su CI en verde. No empezar este change antes.
>
> Cada tarea se cierra con `flutter analyze` y `flutter test` en verde, además de la
> verificación indicada.

## 1. Dependencia y configuración

- [x] 1.1 Añadir `workmanager` a `pubspec.yaml` y comprobar que el proyecto resuelve dependencias; verificación: `flutter pub get`, `flutter analyze` y `flutter build apk --debug` en verde.
- [x] 1.2 Confirmar que el plugin registra sus componentes en Android y que Windows y Linux siguen compilando sin usar el segundo plano; verificación: `flutter analyze` local y el job de Windows de CI en verde.
- [x] 1.3 Aislar la decisión de plataforma en una función comprobable (solo Android registra trabajo de fondo) y usarla en el programador; verificación: test unitario de Android, Windows y Linux con la bandera simulada.

## 2. Programación del trabajo

- [x] 2.1 Implementar el cálculo de la demora a partir de `meta.next_update` (margen de 5 minutos, 1 hora si ya pasó, 12 horas si no hay fecha y mínimo de 15 minutos); verificación: tests de fecha futura, pasada, nula y mínimo.
- [x] 2.2 Implementar `ProgramadorWorkManager` con nombre único `comprobar_avisos_precio`, tarea `comprobarAvisosPrecio`, restricción de red y política `replace`; verificación: tests con un adaptador falso que comprueben registro, restricción, política y cancelación.
- [x] 2.3 Conectar `AvisosController` con el programador para programar al activar una campana y cancelar al apagar la última; verificación: tests con un programador falso de activación, desactivación y última campana.
- [x] 2.4 Reconciliar la programación al abrir o reanudar la app: cancelar sin avisos y reprogramar con avisos sin duplicar tareas; verificación: tests de reconciliación con y sin avisos y con una tarea ya existente.

## 3. Isolate de fondo

- [x] 3.1 Implementar el `callbackDispatcher` de nivel superior con `@pragma('vm:entry-point')`, `DartPluginRegistrant.ensureInitialized()` e inicialización de preferencias y notificaciones; verificación: `flutter analyze` y ejecución manual de una tarea de prueba en el emulador.
- [x] 3.2 Reutilizar `ComprobadorAvisos` dentro del isolate con las dependencias sin UI y el bloqueo compartido; verificación: tests unitarios del comprobador con dobles y prueba manual con la app cerrada.
- [x] 3.3 Manejar los fallos de la API, los límites y la reprogramación sin bucles de reintento agresivos; verificación: tests de error por estación, 429 y reprogramación tras fallo.
- [x] 3.4 Verificar en el emulador Android con la app cerrada, en segundo plano, tras force-stop, sin avisos (cancelación) y tras reiniciar el dispositivo; verificación: registrar los resultados en el change.
- [x] 3.5 Documentar en `docs/arquitectura.md` y `docs/uso.md` el segundo plano en Android, sus límites (Doze, batería, force-stop) y que Windows/Linux siguen comprobando al abrir; verificación: revisar que los comandos y enlaces citados existen.
- [x] 3.6 Ejecutar `dart format .`, `flutter analyze`, `flutter test` y `bash scripts/check_changes.sh`; verificación: todos en verde.

## Workflow follow-up

- Archivar el change después de la revisión y de que la CI esté en verde.
- Commit en `dev` con mensaje convencional y push.
- Verificar que el change de características ya está archivado y que la spec `avisos-precio` contiene los requisitos de fondo.
