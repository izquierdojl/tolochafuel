import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tolochafuel/features/avisos/services/plataforma_avisos.dart';
import 'package:tolochafuel/features/avisos/services/programador_workmanager.dart';

class GestorFalso implements GestorTrabajoFondo {
  int registros = 0;
  int cancelaciones = 0;
  String? nombreUnico;
  String? tarea;
  Duration? demora;
  bool? requiereRed;
  bool? reemplazar;
  String? cancelado;

  @override
  Future<void> cancelar(String nombreUnico) async {
    cancelaciones++;
    cancelado = nombreUnico;
  }

  @override
  Future<void> registrar({
    required String nombreUnico,
    required String tarea,
    required Duration demora,
    required bool requiereRed,
    required bool reemplazar,
  }) async {
    registros++;
    this.nombreUnico = nombreUnico;
    this.tarea = tarea;
    this.demora = demora;
    this.requiereRed = requiereRed;
    this.reemplazar = reemplazar;
  }
}

void main() {
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('solo Android programa trabajo de fondo', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(soportaSegundoPlanoAvisos(), isTrue);

    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    expect(soportaSegundoPlanoAvisos(), isFalse);

    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    expect(soportaSegundoPlanoAvisos(), isFalse);
  });

  test('no registra nada fuera de una plataforma soportada', () async {
    final gestor = GestorFalso();
    final programador = ProgramadorWorkManager(
      gestor: gestor,
      soportado: () => false,
      ahora: () => DateTime.utc(2026, 11, 22, 8),
    );

    await programador.programar(DateTime.utc(2026, 11, 22, 20));
    await programador.cancelar();

    expect(gestor.registros, 0);
    expect(gestor.cancelaciones, 0);
  });

  test('registra la tarea con red, reemplazo y la demora calculada', () async {
    final gestor = GestorFalso();
    final programador = ProgramadorWorkManager(
      gestor: gestor,
      soportado: () => true,
      ahora: () => DateTime.utc(2026, 11, 22, 8),
    );

    await programador.programar(DateTime.utc(2026, 11, 22, 20));

    expect(gestor.registros, 1);
    expect(gestor.nombreUnico, ProgramadorWorkManager.nombreUnico);
    expect(gestor.tarea, ProgramadorWorkManager.tarea);
    expect(gestor.demora, const Duration(hours: 12, minutes: 5));
    expect(gestor.requiereRed, isTrue);
    expect(gestor.reemplazar, isTrue);
  });

  test('usa el respaldo si no hay próxima fecha', () async {
    final gestor = GestorFalso();
    final programador = ProgramadorWorkManager(
      gestor: gestor,
      soportado: () => true,
      ahora: () => DateTime.utc(2026, 11, 22, 8),
    );

    await programador.programar(null);

    expect(gestor.demora, const Duration(hours: 12));
  });

  test('cancela por el nombre único de la tarea', () async {
    final gestor = GestorFalso();
    final programador = ProgramadorWorkManager(
      gestor: gestor,
      soportado: () => true,
    );

    await programador.cancelar();

    expect(gestor.cancelaciones, 1);
    expect(gestor.cancelado, ProgramadorWorkManager.nombreUnico);
  });
}
