import 'package:flutter_test/flutter_test.dart';
import 'package:tolochafuel/core/utilidades/formato.dart';
import 'package:tolochafuel/features/avisos/data/aviso_precio.dart';
import 'package:tolochafuel/features/avisos/services/formato_aviso.dart';
import 'package:tolochafuel/features/avisos/services/navegacion_avisos.dart';

CambioPrecio cambio(
  String id,
  int anterior,
  int actual, {
  String etiqueta = 'Gasolina 95',
  String unidad = 'L',
}) => CambioPrecio(
  idApi: id,
  etiqueta: etiqueta,
  unidad: unidad,
  anterior: anterior,
  actual: actual,
);

AvisoPrecio aviso({
  List<CambioPrecio>? cambios,
  DateTime? lastUpdated,
  bool stale = false,
  String nombre = 'Ballenoil',
}) => AvisoPrecio(
  estacionId: 7,
  nombre: nombre,
  cambios: cambios ?? [cambio('gasoline_95', 1459, 1429)],
  lastUpdated: lastUpdated ?? DateTime.utc(2026, 11, 22, 20),
  stale: stale,
);

void main() {
  test('formatea un solo cambio con precio anterior y nuevo', () {
    final notificacion = formatearAviso(aviso: aviso());

    expect(notificacion.titulo, 'Ballenoil');
    expect(notificacion.cuerpo, 'Gasolina 95: 1,459 €/L → 1,429 €/L');
    expect(
      notificacion.textoLargo,
      contains(
        'Datos del ${formatearFechaHora(DateTime.utc(2026, 11, 22, 20))}',
      ),
    );
    expect(parsearEstacionAviso(notificacion.payload)?.id, 7);
  });

  test('resume varios cambios y los enumera en el texto largo', () {
    final notificacion = formatearAviso(
      aviso: aviso(
        cambios: [
          cambio('gasoline_95', 1459, 1429),
          cambio('diesel', 1399, 1419, etiqueta: 'Gasóleo A'),
        ],
      ),
    );

    expect(notificacion.cuerpo, '2 precios actualizados');
    expect(notificacion.textoLargo, contains('Gasolina 95'));
    expect(notificacion.textoLargo, contains('Gasóleo A'));
  });

  test('usa el alias si existe', () {
    final notificacion = formatearAviso(aviso: aviso(), alias: 'Mi gasolinera');

    expect(notificacion.titulo, 'Mi gasolinera');
  });

  test('usa el texto genérico si no hay fecha', () {
    final notificacion = formatearAviso(
      aviso: AvisoPrecio(
        estacionId: 1,
        nombre: 'Sin fecha',
        cambios: [cambio('gasoline_95', 1459, 1429)],
      ),
    );

    expect(
      notificacion.textoLargo,
      contains('Datos oficiales actualizados 2 veces al día'),
    );
  });

  test('añade el aviso de datos anteriores cuando stale es verdadero', () {
    final notificacion = formatearAviso(aviso: aviso(stale: true));

    expect(
      notificacion.textoLargo,
      contains('Pueden ser datos de la actualización anterior.'),
    );
  });
}
