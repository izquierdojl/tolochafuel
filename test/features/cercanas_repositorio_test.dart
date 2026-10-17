import 'package:flutter_test/flutter_test.dart';
import 'package:tolochafuel/core/api/api_client.dart';
import 'package:tolochafuel/core/api/precios_gasolina_api.dart';
import 'package:tolochafuel/core/models/carburante.dart';
import 'package:tolochafuel/core/models/criterio_economicas.dart';
import 'package:tolochafuel/core/models/detalle_estacion.dart';
import 'package:tolochafuel/core/models/gasolinera.dart';
import 'package:tolochafuel/core/models/lugar.dart';
import 'package:tolochafuel/core/models/meta_datos.dart';
import 'package:tolochafuel/core/models/producto_precio.dart';
import 'package:tolochafuel/features/cercanas/data/cercanas_repositorio.dart';

Gasolinera _estacion(int id, {double? distancia}) => Gasolinera(
  id: id,
  nombre: 'EESS $id',
  lat: 40,
  lng: -3,
  urlWeb: '',
  distanciaKm: distancia,
);

MetaDatos _meta() => MetaDatos(
  atribucion: MetaDatos.atribucionPorDefecto,
  proximaActualizacion: DateTime.now().add(const Duration(hours: 6)),
);

class ApiFalsa extends PreciosGasolinaApi {
  int llamadasCercanas = 0;
  int llamadasMasBaratas = 0;
  int llamadasMasBaratasCerca = 0;
  Carburante ultimoFuel = Carburante.gasolina95;
  int llamadasFichas = 0;
  List<int> idsConFallo = const [];
  Map<int, double> preciosPorId = const {};

  @override
  Future<ResultadoGasolineras> cercanas({
    required double lat,
    required double lng,
    double radioKm = 5,
    int limite = PreciosGasolinaApi.limiteMaximo,
  }) async {
    llamadasCercanas++;
    return ResultadoGasolineras(
      gasolineras: [_estacion(1, distancia: 1), _estacion(2, distancia: 2)],
      meta: _meta(),
    );
  }

  @override
  Future<ResultadoGasolineras> masBaratas({
    required String nivel,
    required String codigo,
    int limite = PreciosGasolinaApi.limiteMaximo,
  }) async {
    llamadasMasBaratas++;
    return ResultadoGasolineras(
      gasolineras: [_estacion(1), _estacion(2)],
      meta: _meta(),
      areaNombre: 'Madrid',
    );
  }

  @override
  Future<ResultadoGasolineras> masBaratasCerca({
    required double lat,
    required double lng,
    double radioKm = 25,
    int limite = PreciosGasolinaApi.limiteMaximo,
    Carburante fuel = Carburante.gasolina95,
  }) async {
    llamadasMasBaratasCerca++;
    ultimoFuel = fuel;
    return ResultadoGasolineras(
      gasolineras: [_estacion(1, distancia: 3), _estacion(2, distancia: 5)],
      meta: _meta(),
    );
  }

  @override
  Future<DetalleEstacion> detalle(int id) async {
    llamadasFichas++;
    if (idsConFallo.contains(id)) {
      throw const ApiException(mensaje: 'Ficha no disponible');
    }
    return DetalleEstacion(
      productos: [
        ProductoPrecio(
          idApi: 'gasoline_95',
          etiqueta: 'Gasolina 95 E5',
          unidad: 'L',
          precio: preciosPorId[id] ?? 1.7,
        ),
      ],
      proximaActualizacion: DateTime.now().add(const Duration(hours: 6)),
    );
  }
}

void main() {
  test('cercanas fusiona la ficha de cada estación', () async {
    final api = ApiFalsa();
    final repositorio = CercanasRepositorio(api: api);

    final resultado = await repositorio.cercanas(lat: 40, lng: -3);

    expect(resultado.gasolineras, hasLength(2));
    expect(resultado.gasolineras.first.productos, hasLength(1));
    expect(
      resultado.gasolineras.first.productos.first.etiqueta,
      'Gasolina 95 E5',
    );
    expect(api.llamadasCercanas, 1);
    expect(api.llamadasFichas, 2);
  });

  test('la segunda llamada usa la caché y no repite peticiones', () async {
    final api = ApiFalsa();
    final repositorio = CercanasRepositorio(api: api);

    await repositorio.cercanas(lat: 40, lng: -3);
    await repositorio.cercanas(lat: 40, lng: -3);

    expect(api.llamadasCercanas, 1);
    expect(api.llamadasFichas, 2);
  });

  test('un fallo de ficha no rompe la lista', () async {
    final api = ApiFalsa()..idsConFallo = [2];
    final repositorio = CercanasRepositorio(api: api);

    final resultado = await repositorio.cercanas(lat: 40, lng: -3);

    expect(resultado.gasolineras, hasLength(2));
    expect(resultado.gasolineras[0].productos, hasLength(1));
    expect(resultado.gasolineras[1].productos, isEmpty);
    expect(api.llamadasFichas, 2);
  });

  test('masBaratas fusiona también las fichas del territorio', () async {
    final api = ApiFalsa();
    final repositorio = CercanasRepositorio(api: api);

    final resultado = await repositorio.masBaratas(
      lugar: const Lugar(
        nombre: 'Madrid',
        nivel: 'municipality',
        codigo: '4354',
      ),
    );

    expect(resultado.gasolineras.first.productos, isNotEmpty);
    expect(api.llamadasMasBaratas, 1);
    expect(api.llamadasFichas, 2);
  });

  test('masEconomicas fusiona fichas y cachea por radio', () async {
    final api = ApiFalsa();
    final repositorio = CercanasRepositorio(api: api);

    final resultado = await repositorio.masEconomicas(
      lat: 40.417,
      lng: -3.704,
      radioKm: 25,
    );
    expect(resultado.gasolineras.first.productos, isNotEmpty);
    expect(resultado.gasolineras.first.distanciaKm, 3);
    expect(api.llamadasMasBaratasCerca, 1);

    await repositorio.masEconomicas(lat: 40.417, lng: -3.704, radioKm: 25);
    expect(api.llamadasMasBaratasCerca, 1);

    await repositorio.masEconomicas(lat: 40.417, lng: -3.704, radioKm: 40);
    expect(api.llamadasMasBaratasCerca, 2);
  });

  test(
    'masEconomicas pide el carburante del criterio y cachea por criterio',
    () async {
      final api = ApiFalsa();
      final repositorio = CercanasRepositorio(api: api);

      await repositorio.masEconomicas(
        lat: 40.417,
        lng: -3.704,
        radioKm: 25,
        criterio: CriterioEconomicas.gasoleoA,
      );
      expect(api.ultimoFuel, Carburante.gasoleoA);
      expect(api.llamadasMasBaratasCerca, 1);

      await repositorio.masEconomicas(
        lat: 40.417,
        lng: -3.704,
        radioKm: 25,
        criterio: CriterioEconomicas.gasoleoA,
      );
      expect(api.llamadasMasBaratasCerca, 1);

      await repositorio.masEconomicas(
        lat: 40.417,
        lng: -3.704,
        radioKm: 25,
        criterio: CriterioEconomicas.glp,
      );
      expect(api.ultimoFuel, Carburante.glp);
      expect(api.llamadasMasBaratasCerca, 2);
    },
  );

  test('masEconomicas con media ordena por la media de la ficha', () async {
    final api = ApiFalsa()..preciosPorId = {1: 1.8, 2: 1.6};
    final repositorio = CercanasRepositorio(api: api);

    final resultado = await repositorio.masEconomicas(
      lat: 40.417,
      lng: -3.704,
      radioKm: 25,
      criterio: CriterioEconomicas.media,
    );

    expect(resultado.gasolineras.map((estacion) => estacion.id), [2, 1]);
    expect(api.llamadasCercanas, 1);

    await repositorio.masEconomicas(
      lat: 40.417,
      lng: -3.704,
      radioKm: 25,
      criterio: CriterioEconomicas.media,
    );
    expect(api.llamadasCercanas, 1);
  });
}
