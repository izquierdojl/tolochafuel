import 'package:flutter_test/flutter_test.dart';
import 'package:tolochafuel/features/avisos/data/aviso_notificacion.dart';
import 'package:tolochafuel/features/avisos/services/comprobador_avisos.dart';
import 'package:tolochafuel/features/avisos/services/programador_workmanager.dart';
import 'package:tolochafuel/features/avisos/services/trabajo_fondo.dart';

class ComprobadorFalso implements ComprobadorAvisos {
  int comprobaciones = 0;
  Object? error;

  @override
  Future<ResultadoComprobacion> comprobar() async {
    comprobaciones++;
    final fallo = error;
    if (fallo != null) throw fallo;
    return const ResultadoComprobacion();
  }

  @override
  Future<ResultadoBase> crearBase(int estacionId) async => ResultadoBase.creada;
}

void main() {
  test('ejecuta la comprobación con el nombre de tarea esperado', () async {
    final comprobador = ComprobadorFalso();

    final resultado = await ejecutarTareaAvisos(
      ProgramadorWorkManager.tarea,
      comprobador,
    );

    expect(resultado, isTrue);
    expect(comprobador.comprobaciones, 1);
  });

  test('ignora una tarea desconocida', () async {
    final comprobador = ComprobadorFalso();

    final resultado = await ejecutarTareaAvisos('otra_tarea', comprobador);

    expect(resultado, isTrue);
    expect(comprobador.comprobaciones, 0);
  });

  test('devuelve éxito aunque la comprobación falle', () async {
    final comprobador = ComprobadorFalso()..error = Exception('fallo');

    final resultado = await ejecutarTareaAvisos(
      ProgramadorWorkManager.tarea,
      comprobador,
    );

    expect(resultado, isTrue);
    expect(comprobador.comprobaciones, 1);
  });
}
