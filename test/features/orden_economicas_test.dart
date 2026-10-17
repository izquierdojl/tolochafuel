import 'package:flutter_test/flutter_test.dart';
import 'package:tolochafuel/core/models/gasolinera.dart';
import 'package:tolochafuel/core/models/producto_precio.dart';
import 'package:tolochafuel/features/cercanas/data/orden_economicas.dart';

Gasolinera _estacion(int id, List<ProductoPrecio> productos) => Gasolinera(
  id: id,
  nombre: 'EESS $id',
  lat: 40,
  lng: -3,
  urlWeb: '',
  productos: productos,
);

ProductoPrecio _producto(String idApi, double? precio, [String unidad = 'L']) =>
    ProductoPrecio(
      idApi: idApi,
      etiqueta: idApi,
      unidad: unidad,
      precio: precio,
    );

void main() {
  test('calcula la media aritmética de los carburantes en €/L', () {
    final estacion = _estacion(1, [
      _producto('gasoline_95', 1.70),
      _producto('diesel', 1.80),
    ]);

    expect(mediaCarburantes(estacion), closeTo(1.75, 0.0001));
  });

  test('excluye los precios en €/kg y los productos no-carburante', () {
    final estacion = _estacion(1, [
      _producto('gasoline_95', 1.70),
      _producto('cng', 1.10, 'kg'),
      _producto('adblue', 0.85),
    ]);

    expect(mediaCarburantes(estacion), closeTo(1.70, 0.0001));
  });

  test('ignora los precios nulos y devuelve nulo sin precios en €/L', () {
    final conNulo = _estacion(1, [
      _producto('gasoline_95', null),
      _producto('diesel', 1.80),
    ]);
    expect(mediaCarburantes(conNulo), closeTo(1.80, 0.0001));

    final sinMedia = _estacion(2, [
      _producto('cng', 1.10, 'kg'),
      _producto('adblue', 0.85),
    ]);
    expect(mediaCarburantes(sinMedia), isNull);

    final vacia = _estacion(3, const []);
    expect(mediaCarburantes(vacia), isNull);
  });

  test('ordena de menor a mayor media y descarta sin media', () {
    final cara = _estacion(1, [_producto('gasoline_95', 1.80)]);
    final barata = _estacion(2, [_producto('diesel', 1.60)]);
    final sinMedia = _estacion(3, [_producto('adblue', 0.50)]);

    final ordenadas = ordenarPorMedia([cara, sinMedia, barata]);

    expect(ordenadas.map((estacion) => estacion.id), [2, 1]);
  });
}
