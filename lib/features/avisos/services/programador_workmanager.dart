import 'package:workmanager/workmanager.dart';

import 'demora_avisos.dart';
import 'plataforma_avisos.dart';
import 'programador_avisos.dart';

abstract class GestorTrabajoFondo {
  Future<void> registrar({
    required String nombreUnico,
    required String tarea,
    required Duration demora,
    required bool requiereRed,
    required bool reemplazar,
  });

  Future<void> cancelar(String nombreUnico);
}

class GestorWorkmanager implements GestorTrabajoFondo {
  @override
  Future<void> registrar({
    required String nombreUnico,
    required String tarea,
    required Duration demora,
    required bool requiereRed,
    required bool reemplazar,
  }) {
    return Workmanager().registerOneOffTask(
      nombreUnico,
      tarea,
      initialDelay: demora,
      constraints: requiereRed
          ? Constraints(networkType: NetworkType.connected)
          : null,
      existingWorkPolicy: reemplazar
          ? ExistingWorkPolicy.replace
          : ExistingWorkPolicy.keep,
    );
  }

  @override
  Future<void> cancelar(String nombreUnico) =>
      Workmanager().cancelByUniqueName(nombreUnico);
}

class ProgramadorWorkManager implements ProgramadorAvisos {
  ProgramadorWorkManager({
    GestorTrabajoFondo? gestor,
    bool Function()? soportado,
    DateTime Function()? ahora,
  }) : _gestor = gestor ?? GestorWorkmanager(),
       _soportado = soportado ?? soportaSegundoPlanoAvisos,
       _ahora = ahora ?? (() => DateTime.now().toUtc());

  static const nombreUnico = 'comprobar_avisos_precio';
  static const tarea = 'comprobarAvisosPrecio';

  final GestorTrabajoFondo _gestor;
  final bool Function() _soportado;
  final DateTime Function() _ahora;

  @override
  Future<void> programar(DateTime? proxima) async {
    if (!_soportado()) return;
    final demora = calcularDemoraAvisos(proxima: proxima, ahora: _ahora());
    await _gestor.registrar(
      nombreUnico: nombreUnico,
      tarea: tarea,
      demora: demora,
      requiereRed: true,
      reemplazar: true,
    );
  }

  @override
  Future<void> cancelar() async {
    if (!_soportado()) return;
    await _gestor.cancelar(nombreUnico);
  }
}
