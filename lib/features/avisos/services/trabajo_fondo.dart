import 'dart:ui';

import 'package:workmanager/workmanager.dart';

import 'comprobador_avisos.dart';
import 'notificaciones_locales.dart';
import 'plataforma_avisos.dart';
import 'programador_workmanager.dart';

Future<void> inicializarTrabajoFondo() async {
  if (!soportaSegundoPlanoAvisos()) return;
  await Workmanager().initialize(callbackDispatcher);
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    DartPluginRegistrant.ensureInitialized();
    if (taskName != ProgramadorWorkManager.tarea) return true;
    try {
      final notificaciones = NotificacionesLocales();
      await notificaciones.inicializar(alTocar: (_) {});
      final checker = ComprobadorAvisosApi(
        notificaciones: notificaciones,
        programador: ProgramadorWorkManager(),
      );
      return await ejecutarTareaAvisos(taskName, checker);
    } catch (_) {
      return true;
    }
  });
}

Future<bool> ejecutarTareaAvisos(
  String taskName,
  ComprobadorAvisos checker,
) async {
  if (taskName != ProgramadorWorkManager.tarea) return true;
  try {
    await checker.comprobar();
  } catch (_) {
    return true;
  }
  return true;
}
