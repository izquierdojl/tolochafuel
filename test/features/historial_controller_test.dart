import 'package:flutter_test/flutter_test.dart';
import 'package:tolochafuel/core/api/api_client.dart';
import 'package:tolochafuel/core/api/precios_gasolina_api.dart';
import 'package:tolochafuel/core/models/historico_estacion.dart';
import 'package:tolochafuel/features/cercanas/ui/historial_controller.dart';

class ApiFalsa extends PreciosGasolinaApi {
  ApiFalsa({this.resultado, this.error, this.retardo});

  HistoricoEstacion? resultado;
  Object? error;
  Duration? retardo;
  final List<int> consultas = [];

  @override
  Future<HistoricoEstacion> historico(int id, {int days = 5}) async {
    consultas.add(id);
    final espera = retardo;
    if (espera != null) await Future<void>.delayed(espera);
    final fallo = error;
    if (fallo != null) throw fallo;
    return resultado ?? const HistoricoEstacion(series: []);
  }
}

void main() {
  test('carga el histórico y no repite la petición desde caché', () async {
    final api = ApiFalsa();
    final controller = HistorialController(api: api);

    await controller.cargar(1);
    await controller.cargar(1);

    expect(api.consultas, [1]);
    expect(controller.historico(1), isNotNull);
    expect(controller.cargando(1), isFalse);
  });

  test('vuelve a pedirlo cuando el histórico ha caducado', () async {
    final api = ApiFalsa(
      resultado: HistoricoEstacion(
        series: const [],
        proximaActualizacion: DateTime.now().toUtc().subtract(
          const Duration(hours: 1),
        ),
      ),
    );
    final controller = HistorialController(api: api);

    await controller.cargar(1);
    await controller.cargar(1);

    expect(api.consultas, [1, 1]);
  });

  test('registra el error sin romper', () async {
    final api = ApiFalsa(error: const ApiException(mensaje: 'Sin conexión.'));
    final controller = HistorialController(api: api);

    await controller.cargar(1);

    expect(controller.error(1), 'Sin conexión.');
    expect(controller.historico(1), isNull);
  });

  test('no duplica peticiones del mismo id en curso', () async {
    final api = ApiFalsa(retardo: const Duration(milliseconds: 10));
    final controller = HistorialController(api: api);

    await Future.wait([controller.cargar(1), controller.cargar(1)]);

    expect(api.consultas, [1]);
  });

  test('limita la concurrencia a cuatro peticiones a la vez', () async {
    final api = ApiFalsa(retardo: const Duration(milliseconds: 20));
    final controller = HistorialController(api: api);

    final futuros = [for (var id = 1; id <= 6; id++) controller.cargar(id)];
    expect(api.consultas, hasLength(HistorialController.maxConcurrentes));

    await Future.wait(futuros);

    expect(api.consultas, hasLength(6));
  });
}
