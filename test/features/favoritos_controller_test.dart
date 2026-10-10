import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tolochafuel/core/api/api_client.dart';
import 'package:tolochafuel/core/api/precios_gasolina_api.dart';
import 'package:tolochafuel/core/models/detalle_estacion.dart';
import 'package:tolochafuel/core/models/gasolinera.dart';
import 'package:tolochafuel/core/models/meta_datos.dart';
import 'package:tolochafuel/core/models/producto_precio.dart';
import 'package:tolochafuel/features/favoritos/data/favorito.dart';
import 'package:tolochafuel/features/favoritos/data/favoritos_repositorio.dart';
import 'package:tolochafuel/features/favoritos/ui/favoritos_controller.dart';

class RepositorioFalso extends FavoritosRepositorio {
  RepositorioFalso({this.inicial = const []});

  List<Favorito> inicial;
  List<Favorito>? guardados;
  final List<int> borrados = [];
  bool fallarCarga = false;
  bool fallarGuardado = false;

  @override
  Future<List<Favorito>> cargar() async {
    if (fallarCarga) throw Exception('fallo de carga');
    return inicial;
  }

  @override
  Future<void> guardar(List<Favorito> favoritos) async {
    if (fallarGuardado) throw Exception('fallo de guardado');
    guardados = favoritos;
  }

  @override
  Future<void> borrar(int id) async {
    if (fallarGuardado) throw Exception('fallo de borrado');
    borrados.add(id);
  }
}

class ApiFalsa extends PreciosGasolinaApi {
  ApiFalsa({Map<int, DetalleEstacion>? detalles, Map<int, Object>? errores})
    : detalles = detalles ?? {},
      errores = errores ?? {};

  final Map<int, DetalleEstacion> detalles;
  final Map<int, Object> errores;
  final List<int> consultas = [];

  @override
  Future<DetalleEstacion> detalle(int id) async {
    consultas.add(id);
    final error = errores[id];
    if (error != null) throw error;
    return detalles[id] ?? const DetalleEstacion(productos: []);
  }
}

class ApiLenta extends PreciosGasolinaApi {
  ApiLenta(this.completer);

  final Completer<DetalleEstacion> completer;
  int consultas = 0;

  @override
  Future<DetalleEstacion> detalle(int id) {
    consultas++;
    return completer.future;
  }
}

Gasolinera _gasolinera({int id = 1, String nombre = 'Ballenoil'}) => Gasolinera(
  id: id,
  nombre: nombre,
  lat: 40.4,
  lng: -3.7,
  urlWeb: '',
  direccion: 'Calle Mayor, 1',
);

void main() {
  test('carga los favoritos guardados al iniciar', () async {
    final controller = FavoritosController(
      repositorio: RepositorioFalso(
        inicial: const [
          Favorito(id: 7, nombre: 'Repsol', lat: 40.4, lng: -3.7),
        ],
      ),
      api: ApiFalsa(),
    );

    await controller.cargar();

    expect(controller.cargado, isTrue);
    expect(controller.esFavorito(7), isTrue);
    expect(controller.esFavorito(8), isFalse);
  });

  test('carga tolerante: si falla la lectura, sigue con lista vacía', () async {
    final controller = FavoritosController(
      repositorio: RepositorioFalso()..fallarCarga = true,
      api: ApiFalsa(),
    );

    await controller.cargar();

    expect(controller.favoritos, isEmpty);
    expect(controller.aviso, isNotNull);
  });

  test('alternar marca y desmarca persistiendo cada cambio', () async {
    final repositorio = RepositorioFalso();
    final controller = FavoritosController(
      repositorio: repositorio,
      api: ApiFalsa(),
    );
    await controller.cargar();

    await controller.alternar(_gasolinera());
    expect(controller.esFavorito(1), isTrue);
    expect(repositorio.guardados, hasLength(1));
    expect(repositorio.guardados!.single.nombre, 'Ballenoil');

    await controller.alternar(_gasolinera());
    expect(controller.esFavorito(1), isFalse);
    expect(repositorio.borrados, [1]);
  });

  test('si falla el guardado avisa sin perder el cambio en memoria', () async {
    final controller = FavoritosController(
      repositorio: RepositorioFalso()..fallarGuardado = true,
      api: ApiFalsa(),
    );
    await controller.cargar();

    await controller.alternar(_gasolinera());

    expect(controller.esFavorito(1), isTrue);
    expect(controller.aviso, isNotNull);
  });

  test('carga el detalle de cada favorito y reintenta tras un error', () async {
    const producto = ProductoPrecio(
      idApi: 'gasoline_95',
      etiqueta: 'Gasolina 95 E5',
      unidad: 'L',
      precio: 1.729,
    );
    final api = ApiFalsa(
      errores: {1: const ApiException(mensaje: 'Sin conexión.')},
      detalles: {
        1: const DetalleEstacion(productos: [producto]),
      },
    );
    final controller = FavoritosController(
      repositorio: RepositorioFalso(
        inicial: const [Favorito(id: 1, nombre: 'Una', lat: 40.4, lng: -3.7)],
      ),
      api: api,
    );
    await controller.cargar();

    await controller.cargarDetalle(1);
    expect(controller.errorDetalle(1), 'Sin conexión.');
    expect(controller.detalle(1), isNull);

    api.errores.clear();
    await controller.cargarDetalle(1);
    expect(controller.errorDetalle(1), isNull);
    expect(controller.detalle(1)!.productos.single.etiqueta, 'Gasolina 95 E5');
  });

  test('al marcar consulta el detalle de la estación', () async {
    final api = ApiFalsa();
    final controller = FavoritosController(
      repositorio: RepositorioFalso(),
      api: api,
    );
    await controller.cargar();

    await controller.alternar(_gasolinera());

    expect(api.consultas, [1]);
    expect(controller.detalle(1), isNotNull);
  });

  test('no repite la consulta si el detalle ya está en caché', () async {
    final api = ApiFalsa();
    final controller = FavoritosController(
      repositorio: RepositorioFalso(),
      api: api,
    );
    await controller.cargar();

    await controller.alternar(_gasolinera());
    await controller.cargarDetalle(1);

    expect(api.consultas, [1]);
  });

  test('no duplica la consulta mientras está en curso', () async {
    final completer = Completer<DetalleEstacion>();
    final api = ApiLenta(completer);
    final controller = FavoritosController(
      repositorio: RepositorioFalso(),
      api: api,
    );
    await controller.cargar();

    final primera = controller.cargarDetalle(1);
    final segunda = controller.cargarDetalle(1);
    expect(api.consultas, 1);

    completer.complete(const DetalleEstacion(productos: []));
    await Future.wait([primera, segunda]);

    expect(api.consultas, 1);
  });

  test('la marca persiste aunque falle la consulta del precio', () async {
    final repositorio = RepositorioFalso();
    final api = ApiFalsa(
      errores: {1: const ApiException(mensaje: 'Sin conexión.')},
    );
    final controller = FavoritosController(repositorio: repositorio, api: api);
    await controller.cargar();

    await controller.alternar(_gasolinera());

    expect(controller.esFavorito(1), isTrue);
    expect(repositorio.guardados, hasLength(1));
    expect(controller.errorDetalle(1), 'Sin conexión.');
  });

  test('expone el meta de la ficha consultada', () async {
    final api = ApiFalsa(
      detalles: {
        1: DetalleEstacion(
          productos: const [],
          meta: MetaDatos(
            atribucion: MetaDatos.atribucionPorDefecto,
            ultimaActualizacion: DateTime.utc(2026, 10, 9, 18, 10),
          ),
        ),
      },
    );
    final controller = FavoritosController(
      repositorio: RepositorioFalso(),
      api: api,
    );
    await controller.cargar();

    await controller.alternar(_gasolinera());

    expect(controller.meta, isNotNull);
    expect(controller.meta!.ultimaActualizacion, isNotNull);
  });
}
