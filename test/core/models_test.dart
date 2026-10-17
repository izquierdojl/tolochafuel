import 'package:flutter_test/flutter_test.dart';
import 'package:tolochafuel/core/models/carburante.dart';
import 'package:tolochafuel/core/models/criterio_economicas.dart';
import 'package:tolochafuel/core/models/gasolinera.dart';
import 'package:tolochafuel/core/models/meta_datos.dart';
import 'package:tolochafuel/core/models/producto_precio.dart';

void main() {
  group('Gasolinera.fromJson', () {
    test('parsea una estación de /v1/stations/nearby', () {
      final gasolinera = Gasolinera.fromJson(const {
        'id': 3213,
        'name': 'Ballenoil Segovia',
        'brand': {'slug': 'ballenoil', 'name': 'Ballenoil'},
        'address': 'Ronda Segovia, 37',
        'municipality': {'id': 4354, 'name': 'Madrid'},
        'lat': 40.41025,
        'lng': -3.717528,
        'is_24h': true,
        'hours': 'L-D: 24H',
        'web_url': 'https://preciosgasolina.es/gasolineras/ballenoil-3213/',
        'price': 1.729,
        'price_updated_at': '2026-10-05T18:10:00.254133+00:00',
        'distance_km': 1.37,
      });

      expect(gasolinera.id, 3213);
      expect(gasolinera.nombre, 'Ballenoil Segovia');
      expect(gasolinera.marca, 'Ballenoil');
      expect(gasolinera.direccion, 'Ronda Segovia, 37');
      expect(gasolinera.municipio, 'Madrid');
      expect(gasolinera.precio, 1.729);
      expect(gasolinera.distanciaKm, 1.37);
      expect(gasolinera.abierta24h, isTrue);
      expect(gasolinera.precioActualizadoEn?.isUtc, isTrue);
    });

    test('tolera precio como texto con coma decimal', () {
      final gasolinera = Gasolinera.fromJson(const {
        'id': 1,
        'name': 'Prueba',
        'lat': 40.0,
        'lng': -3.0,
        'web_url': '',
        'price': '1,459',
      });

      expect(gasolinera.precio, 1.459);
    });

    test('tolera campos ausentes y nulos', () {
      final gasolinera = Gasolinera.fromJson(const {
        'id': 2,
        'name': null,
        'brand': null,
        'lat': 40.0,
        'lng': -3.0,
        'price': null,
        'web_url': '',
      });

      expect(gasolinera.nombre, 'Sin rótulo');
      expect(gasolinera.marca, isNull);
      expect(gasolinera.precio, isNull);
      expect(gasolinera.distanciaKm, isNull);
      expect(gasolinera.municipio, isNull);
    });
  });

  group('MetaDatos.fromJson', () {
    test('parsea metadatos con stale', () {
      final meta = MetaDatos.fromJson(const {
        'api_version': 'v1',
        'last_updated': '2026-10-09T18:10:00.216Z',
        'next_update': '2026-10-10T06:10:00.000Z',
        'data_age_seconds': 18078,
        'stale': true,
        'attribution':
            'Gasolina hoy (preciosgasolina.es), con datos del Ministerio para '
            'la Transición Ecológica y el Reto Demográfico',
        'web_url': 'https://preciosgasolina.es',
      });

      expect(meta.stale, isTrue);
      expect(meta.antiguedadSegundos, 18078);
      expect(meta.ultimaActualizacion, isNotNull);
      expect(meta.proximaActualizacion, isNotNull);
      expect(meta.atribucion, contains('Gasolina hoy'));
    });

    test('usa la atribución por defecto si falta', () {
      final meta = MetaDatos.fromJson(const {});
      expect(meta.atribucion, MetaDatos.atribucionPorDefecto);
      expect(meta.stale, isFalse);
    });
  });

  group('ProductoPrecio.fromJson', () {
    test('parsea un combustible de la ficha', () {
      final producto = ProductoPrecio.fromJson(const {
        'fuel': 'gasoline_95',
        'label': 'Gasolina 95 E5',
        'unit': 'L',
        'price': 1.729,
      });

      expect(producto.idApi, 'gasoline_95');
      expect(producto.etiqueta, 'Gasolina 95 E5');
      expect(producto.unidad, 'L');
      expect(producto.precio, 1.729);
    });

    test('parsea un producto y tolera etiqueta ausente', () {
      final producto = ProductoPrecio.fromJson(const {
        'product': 'adblue',
        'unit': 'L',
        'price': '0,85',
      });

      expect(producto.idApi, 'adblue');
      expect(producto.etiqueta, 'adblue');
      expect(producto.precio, 0.85);
    });
  });

  group('Gasolinera.conProductos', () {
    test('fusiona los productos de la ficha conservando distancia', () {
      final gasolinera =
          Gasolinera.fromJson(const {
            'id': 1,
            'name': 'Prueba',
            'lat': 40.0,
            'lng': -3.0,
            'web_url': '',
            'distance_km': 1.2,
          }).conProductos(const [
            ProductoPrecio(
              idApi: 'gasoline_95',
              etiqueta: 'Gasolina 95 E5',
              unidad: 'L',
              precio: 1.729,
            ),
          ]);

      expect(gasolinera.distanciaKm, 1.2);
      expect(gasolinera.productos, hasLength(1));
      expect(gasolinera.productos.first.precio, 1.729);
    });
  });

  group('CriterioEconomicas', () {
    test('ofrece los seis carburantes de la API y la media', () {
      expect(CriterioEconomicas.values, hasLength(7));
      expect(
        CriterioEconomicas.values.map((criterio) => criterio.clave),
        containsAll([
          'gasoline_95',
          'gasoline_98',
          'diesel',
          'diesel_premium',
          'lpg',
          'cng',
          'media',
        ]),
      );
      expect(CriterioEconomicas.gasoleoA.etiqueta, 'Gasóleo A');
      expect(CriterioEconomicas.media.etiqueta, 'Media de carburantes');
      expect(CriterioEconomicas.media.esMedia, isTrue);
      expect(CriterioEconomicas.glp.esMedia, isFalse);
    });

    test('la clave identifica el carburante y viaja en ambos sentidos', () {
      for (final criterio in CriterioEconomicas.values) {
        expect(CriterioEconomicas.desdeClave(criterio.clave), criterio);
      }
      expect(
        CriterioEconomicas.desdeClave('diesel').carburante,
        Carburante.gasoleoA,
      );
    });

    test('la clave desconocida o nula cae a Gasolina 95', () {
      expect(
        CriterioEconomicas.desdeClave('queroseno'),
        CriterioEconomicas.gasolina95,
      );
      expect(
        CriterioEconomicas.desdeClave(null),
        CriterioEconomicas.gasolina95,
      );
    });
  });
}
