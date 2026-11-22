import 'package:flutter_test/flutter_test.dart';
import 'package:tolochafuel/features/avisos/data/aviso_notificacion.dart';
import 'package:tolochafuel/features/avisos/services/navegacion_avisos.dart';

void main() {
  test('parsea un payload válido', () {
    final estacion = parsearEstacionAviso('{"id": 7, "nombre": "Repsol"}');

    expect(estacion?.id, 7);
    expect(estacion?.nombre, 'Repsol');
  });

  test('tolera un payload inválido o vacío', () {
    expect(parsearEstacionAviso(null), isNull);
    expect(parsearEstacionAviso(''), isNull);
    expect(parsearEstacionAviso('no es json'), isNull);
    expect(parsearEstacionAviso('{"nombre": "Sin id"}'), isNull);
    expect(parsearEstacionAviso('{"id": "7"}'), isNull);
  });

  test('serializa y vuelve a parsear la estación', () {
    const estacion = EstacionAviso(id: 7, nombre: 'Repsol');

    final recargada = parsearEstacionAviso(payloadEstacionAviso(estacion));

    expect(recargada?.id, 7);
    expect(recargada?.nombre, 'Repsol');
  });

  test('el controlador entrega la estación una sola vez', () {
    final navegacion = NavegacionAvisosController();
    var notificaciones = 0;
    navegacion.addListener(() => notificaciones++);

    navegacion.abrir(const EstacionAviso(id: 7, nombre: 'Repsol'));

    expect(navegacion.pendiente?.id, 7);
    expect(notificaciones, 1);
    expect(navegacion.consumir()?.id, 7);
    expect(navegacion.pendiente, isNull);
    expect(navegacion.consumir(), isNull);
  });
}
