import '../models/carburante.dart';
import '../models/detalle_estacion.dart';
import '../models/gasolinera.dart';
import '../models/lugar.dart';
import '../models/meta_datos.dart';
import '../models/producto_precio.dart';
import '../utilidades/distancias.dart';
import '../utilidades/parseo.dart';
import 'api_client.dart';

class ResultadoGasolineras {
  const ResultadoGasolineras({
    required this.gasolineras,
    required this.meta,
    this.areaNombre,
  });

  final List<Gasolinera> gasolineras;
  final MetaDatos meta;
  final String? areaNombre;
}

class PreciosGasolinaApi {
  PreciosGasolinaApi({ApiClient? cliente}) : cliente = cliente ?? ApiClient();

  final ApiClient cliente;

  static const radioMaximoKm = 50.0;
  static const limiteMaximo = 50;

  Future<ResultadoGasolineras> cercanas({
    required double lat,
    required double lng,
    double radioKm = 5,
    int limite = limiteMaximo,
  }) async {
    final cuerpo = await cliente.getJson(
      '/v1/stations/nearby',
      parametros: {
        'lat': lat.toString(),
        'lng': lng.toString(),
        'radius_km': radioKm.clamp(0.1, radioMaximoKm).toString(),
        'sort': 'distance',
        'limit': limite.clamp(1, limiteMaximo).toString(),
      },
    );

    final data = _dataDe(cuerpo);
    final meta = MetaDatos.fromJson(_metaDe(cuerpo));
    final centro = data['center'];
    final centroLat = centro is Map<String, dynamic>
        ? aDouble(centro['lat'])
        : null;
    final centroLng = centro is Map<String, dynamic>
        ? aDouble(centro['lng'])
        : null;

    var gasolineras = _estacionesDe(data);
    if (centroLat != null && centroLng != null) {
      gasolineras = gasolineras
          .map(
            (gasolinera) => gasolinera.distanciaKm == null
                ? gasolinera.conDistancia(
                    distanciaKmEntre(
                      centroLat,
                      centroLng,
                      gasolinera.lat,
                      gasolinera.lng,
                    ),
                  )
                : gasolinera,
          )
          .toList();
    }
    gasolineras.sort(
      (a, b) => (a.distanciaKm ?? double.infinity).compareTo(
        b.distanciaKm ?? double.infinity,
      ),
    );

    return ResultadoGasolineras(gasolineras: gasolineras, meta: meta);
  }

  Future<ResultadoGasolineras> masBaratas({
    required String nivel,
    required String codigo,
    int limite = limiteMaximo,
  }) async {
    final cuerpo = await cliente.getJson(
      '/v1/stations/cheapest',
      parametros: {
        'level': nivel,
        'code': codigo,
        'fuel': Carburante.gasolina95.idApi,
        'limit': limite.clamp(1, limiteMaximo).toString(),
      },
    );

    final data = _dataDe(cuerpo);
    final meta = MetaDatos.fromJson(_metaDe(cuerpo));
    final area = data['area'];
    final areaNombre = area is Map<String, dynamic>
        ? area['name'] as String?
        : null;

    return ResultadoGasolineras(
      gasolineras: _estacionesDe(data),
      meta: meta,
      areaNombre: areaNombre,
    );
  }

  Future<ResultadoGasolineras> masBaratasCerca({
    required double lat,
    required double lng,
    double radioKm = 25,
    int limite = limiteMaximo,
  }) async {
    final cuerpo = await cliente.getJson(
      '/v1/stations/cheapest',
      parametros: {
        'lat': lat.toString(),
        'lng': lng.toString(),
        'radius_km': radioKm.clamp(0.1, radioMaximoKm).toString(),
        'fuel': Carburante.gasolina95.idApi,
        'limit': limite.clamp(1, limiteMaximo).toString(),
      },
    );

    final data = _dataDe(cuerpo);
    final meta = MetaDatos.fromJson(_metaDe(cuerpo));

    return ResultadoGasolineras(gasolineras: _estacionesDe(data), meta: meta);
  }

  Future<DetalleEstacion> detalle(int id) async {
    final cuerpo = await cliente.getJson('/v1/stations/$id');
    final data = _dataDe(cuerpo);
    final meta = MetaDatos.fromJson(_metaDe(cuerpo));

    final productos = <ProductoPrecio>[
      ..._productosDe(data['fuels']),
      ..._productosDe(data['products']),
    ];

    return DetalleEstacion(
      productos: productos,
      proximaActualizacion: meta.proximaActualizacion,
    );
  }

  Future<List<Lugar>> buscarLugar(String consulta) async {
    final cuerpo = await cliente.getJson(
      '/v1/search',
      parametros: {'q': consulta, 'limit': '10'},
    );

    final data = _dataDe(cuerpo);
    final resultados = data['results'];
    if (resultados is! List) return const [];
    return resultados
        .whereType<Map<String, dynamic>>()
        .where(
          (resultado) =>
              resultado['name'] is String &&
              resultado['level'] is String &&
              resultado['code'] is String,
        )
        .map(Lugar.fromJson)
        .toList();
  }

  Map<String, dynamic> _dataDe(Map<String, dynamic> cuerpo) {
    final data = cuerpo['data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException(
        mensaje: 'La respuesta del servicio no tiene el formato esperado.',
      );
    }
    return data;
  }

  Map<String, dynamic> _metaDe(Map<String, dynamic> cuerpo) {
    final meta = cuerpo['meta'];
    return meta is Map<String, dynamic> ? meta : const {};
  }

  List<Gasolinera> _estacionesDe(Map<String, dynamic> data) {
    final estaciones = data['stations'];
    if (estaciones is! List) return const [];
    return estaciones
        .whereType<Map<String, dynamic>>()
        .map(Gasolinera.fromJson)
        .toList();
  }

  List<ProductoPrecio> _productosDe(dynamic lista) {
    if (lista is! List) return const [];
    return lista
        .whereType<Map<String, dynamic>>()
        .map(ProductoPrecio.fromJson)
        .toList();
  }
}
