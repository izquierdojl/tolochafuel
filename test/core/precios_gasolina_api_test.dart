import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tolochafuel/core/api/api_client.dart';
import 'package:tolochafuel/core/api/precios_gasolina_api.dart';
import 'package:tolochafuel/core/models/carburante.dart';
import 'package:tolochafuel/core/models/historico_estacion.dart';

String respuestaCercanas() => '''
{
  "data": {
    "fuel": "gasoline_95",
    "unit": "L",
    "currency": "EUR",
    "center": {"lat": 40.417, "lng": -3.704},
    "radius_km": 2,
    "sort": "distance",
    "stations": [
      {"id": 1, "name": "Lejana", "lat": 40.44, "lng": -3.72, "web_url": "",
       "price": 1.60, "distance_km": 3.0},
      {"id": 2, "name": "Cercana", "lat": 40.418, "lng": -3.704, "web_url": "",
       "price": 1.70}
    ]
  },
  "meta": {
    "last_updated": "2026-10-09T18:10:00.216Z",
    "next_update": "2026-10-10T06:10:00.000Z",
    "data_age_seconds": 10,
    "stale": false,
    "attribution": "Gasolina hoy (preciosgasolina.es), con datos del Ministerio"
  }
}
''';

String respuestaMasBaratas() => '''
{
  "data": {
    "fuel": "gasoline_95",
    "area": {"level": "municipality", "code": "4354", "name": "Madrid"},
    "stations": [
      {"id": 3194, "name": "Ballenoil Democracia", "lat": 40.4, "lng": -3.61,
       "web_url": "", "price": 1.749}
    ]
  },
  "meta": {"stale": false, "attribution": "Gasolina hoy"}
}
''';

String respuestaFicha() => '''
{
  "data": {
    "id": 3213,
    "name": "Ballenoil Segovia",
    "lat": 40.41025,
    "lng": -3.717528,
    "web_url": "https://preciosgasolina.es/gasolineras/ballenoil-3213/",
    "currency": "EUR",
    "prices_updated_at": "2026-10-05T18:10:00.254133+00:00",
    "fuels": [
      {"fuel": "gasoline_95", "label": "Gasolina 95 E5", "unit": "L", "price": 1.729},
      {"fuel": "diesel", "label": "Gasóleo A (diésel)", "unit": "L", "price": 1.859},
      {"fuel": "cng", "label": "GNC", "unit": "kg", "price": 1.21}
    ],
    "products": [
      {"product": "adblue", "label": "AdBlue", "unit": "L", "price": 0.85}
    ]
  },
  "meta": {
    "last_updated": "2026-10-09T18:10:00.216Z",
    "next_update": "2026-10-10T06:10:00.000Z",
    "stale": false,
    "attribution": "Gasolina hoy"
  }
}
''';

String respuestaBusqueda() => '''
{
  "data": {
    "query": "madrid",
    "results": [
      {"type": "municipality", "name": "Madrid", "detail": "Comunidad de Madrid",
       "level": "municipality", "code": "4354"},
      {"type": "province", "name": "Madrid", "detail": "Comunidad de Madrid",
       "level": "province", "code": "28"},
      {"type": "station", "name": "Repsol Madrid", "detail": "Colmenar",
       "station_id": 4540}
    ]
  },
  "meta": {}
}
''';

String respuestaHistorico() => '''
{
  "data": {
    "station": {"id": 3213, "name": "Ballenoil Segovia"},
    "days": 5,
    "series": [
      {"fuel": "gasoline_95", "unit": "L", "points": [
        {"date": "2026-10-06", "price": 1.739},
        {"date": "2026-10-10", "price": 1.719}
      ]}
    ]
  },
  "meta": {"next_update": "2026-10-10T18:10:00.000Z", "attribution": "Gasolina hoy"}
}
''';

PreciosGasolinaApi _apiMocada(String cuerpo, void Function(Uri)? alRecibir) {
  return PreciosGasolinaApi(
    cliente: ApiClient(
      cliente: MockClient((peticion) async {
        alRecibir?.call(peticion.url);
        return http.Response(
          cuerpo,
          200,
          headers: const {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    ),
  );
}

void main() {
  test(
    'cercanas pide orden por distancia y completa la distancia que falta',
    () async {
      Uri? uriRecibida;
      final api = _apiMocada(respuestaCercanas(), (uri) => uriRecibida = uri);

      final resultado = await api.cercanas(lat: 40.417, lng: -3.704);

      expect(uriRecibida?.queryParameters['sort'], 'distance');
      expect(uriRecibida?.queryParameters.containsKey('fuel'), isFalse);
      expect(uriRecibida?.queryParameters['limit'], '50');
      expect(resultado.gasolineras, hasLength(2));
      expect(resultado.gasolineras.first.nombre, 'Cercana');
      expect(
        resultado.gasolineras.first.distanciaKm,
        lessThan(resultado.gasolineras.last.distanciaKm!),
      );
      expect(resultado.meta.stale, isFalse);
    },
  );

  test(
    'cercanas limita el radio y el número de resultados al máximo',
    () async {
      Uri? uriRecibida;
      final api = _apiMocada(respuestaCercanas(), (uri) => uriRecibida = uri);

      await api.cercanas(lat: 40.417, lng: -3.704, radioKm: 120, limite: 999);

      expect(uriRecibida?.queryParameters['radius_km'], '50.0');
      expect(uriRecibida?.queryParameters['limit'], '50');
    },
  );

  test('masBaratas devuelve el área y sus estaciones', () async {
    final api = _apiMocada(respuestaMasBaratas(), (_) {});

    final resultado = await api.masBaratas(
      nivel: 'municipality',
      codigo: '4354',
    );

    expect(resultado.areaNombre, 'Madrid');
    expect(resultado.gasolineras, hasLength(1));
    expect(resultado.gasolineras.first.precio, 1.749);
  });

  test('masBaratasCerca pide Gasolina 95 por defecto', () async {
    Uri? uriRecibida;
    final api = _apiMocada(respuestaMasBaratas(), (uri) => uriRecibida = uri);

    await api.masBaratasCerca(lat: 40.417, lng: -3.704, radioKm: 25);

    expect(uriRecibida?.path, '/v1/stations/cheapest');
    expect(uriRecibida?.queryParameters['fuel'], 'gasoline_95');
    expect(uriRecibida?.queryParameters['radius_km'], '25.0');
  });

  test('masBaratasCerca envía el carburante elegido', () async {
    Uri? uriRecibida;
    final api = _apiMocada(respuestaMasBaratas(), (uri) => uriRecibida = uri);

    await api.masBaratasCerca(
      lat: 40.417,
      lng: -3.704,
      radioKm: 25,
      fuel: Carburante.gasoleoA,
    );

    expect(uriRecibida?.queryParameters['fuel'], 'diesel');
  });

  test(
    'detalle devuelve los productos de la ficha (fuels y products)',
    () async {
      Uri? uriRecibida;
      final api = _apiMocada(respuestaFicha(), (uri) => uriRecibida = uri);

      final detalle = await api.detalle(3213);

      expect(uriRecibida?.path, '/v1/stations/3213');
      expect(detalle.productos, hasLength(4));
      expect(detalle.productos.first.etiqueta, 'Gasolina 95 E5');
      expect(detalle.productos.first.unidad, 'L');
      expect(detalle.productos[2].unidad, 'kg');
      expect(detalle.productos.last.etiqueta, 'AdBlue');
      expect(detalle.proximaActualizacion, isNotNull);
      expect(detalle.meta, isNotNull);
      expect(detalle.meta!.ultimaActualizacion, isNotNull);
    },
  );

  test('buscarLugar descarta resultados sin level ni code', () async {
    final api = _apiMocada(respuestaBusqueda(), (_) {});

    final lugares = await api.buscarLugar('madrid');

    expect(lugares, hasLength(2));
    expect(lugares.first.nombre, 'Madrid');
    expect(lugares.first.nivel, 'municipality');
    expect(lugares.last.nivel, 'province');
  });

  test('historico pide los días y parsea las series', () async {
    Uri? uriRecibida;
    final api = _apiMocada(respuestaHistorico(), (uri) => uriRecibida = uri);

    final historico = await api.historico(3213);

    expect(uriRecibida?.path, '/v1/stations/3213/history');
    expect(uriRecibida?.queryParameters['days'], '90');
    expect(historico.series, hasLength(1));
    expect(historico.serie('gasoline_95')!.puntos, hasLength(2));
    expect(historico.serie('gasoline_95')!.tendencia, Tendencia.baja);
    expect(historico.proximaActualizacion, isNotNull);
  });
}
