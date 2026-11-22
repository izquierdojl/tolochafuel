import 'package:flutter_test/flutter_test.dart';
import 'package:tolochafuel/core/models/producto_precio.dart';
import 'package:tolochafuel/features/avisos/services/diferencia_precios.dart';

ProductoPrecio producto(
  String id,
  double? precio, {
  String etiqueta = 'Carburante',
  String unidad = 'L',
}) => ProductoPrecio(
  idApi: id,
  etiqueta: etiqueta,
  unidad: unidad,
  precio: precio,
);

void main() {
  test('detecta una bajada y conserva el precio anterior y el nuevo', () {
    final cambios = calcularCambios(
      base: const {'gasoline_95': 1459, 'diesel': 1399},
      productos: [
        producto('gasoline_95', 1.429, etiqueta: 'Gasolina 95'),
        producto('diesel', 1.399, etiqueta: 'Gasóleo A'),
      ],
    );

    expect(cambios, hasLength(1));
    expect(cambios.single.idApi, 'gasoline_95');
    expect(cambios.single.anterior, 1459);
    expect(cambios.single.actual, 1429);
    expect(cambios.single.sube, isFalse);
    expect(cambios.single.etiqueta, 'Gasolina 95');
  });

  test('detecta una subida', () {
    final cambios = calcularCambios(
      base: const {'diesel': 1399},
      productos: [producto('diesel', 1.419)],
    );

    expect(cambios.single.sube, isTrue);
    expect(cambios.single.actual, 1419);
  });

  test('sin cambios no devuelve nada', () {
    final cambios = calcularCambios(
      base: const {'gasoline_95': 1459},
      productos: [producto('gasoline_95', 1.459)],
    );

    expect(cambios, isEmpty);
  });

  test('ignora carburantes nuevos y desaparecidos', () {
    final cambios = calcularCambios(
      base: const {'gasoline_95': 1459, 'gasoline_98': 1550},
      productos: [producto('gasoline_95', 1.459), producto('diesel', 1.399)],
    );

    expect(cambios, isEmpty);
  });

  test('ignora AdBlue, productos no carburante y precios vacíos', () {
    final cambios = calcularCambios(
      base: const {'gasoline_95': 1459},
      productos: [
        producto('adblue', 0.85, etiqueta: 'AdBlue'),
        producto('gasoline_95', null),
        producto('gasoline_95', 0),
      ],
    );

    expect(cambios, isEmpty);
  });

  test('preciosDesdeProductos filtra y guarda en milésimas', () {
    final precios = preciosDesdeProductos([
      producto('gasoline_95', 1.459, etiqueta: 'Gasolina 95'),
      producto('diesel', 1.399),
      producto('adblue', 0.85),
      producto('lpg', null),
      producto('cng', 0),
    ]);

    expect(precios, {'gasoline_95': 1459, 'diesel': 1399});
  });

  test('ordena los cambios según el orden de Carburante', () {
    final cambios = calcularCambios(
      base: const {'diesel': 1399, 'gasoline_95': 1459},
      productos: [producto('diesel', 1.409), producto('gasoline_95', 1.449)],
    );

    expect(cambios.map((cambio) => cambio.idApi), ['gasoline_95', 'diesel']);
  });
}
