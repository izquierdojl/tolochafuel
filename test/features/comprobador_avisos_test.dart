import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tolochafuel/core/api/api_client.dart';
import 'package:tolochafuel/core/api/precios_gasolina_api.dart';
import 'package:tolochafuel/core/models/detalle_estacion.dart';
import 'package:tolochafuel/core/models/meta_datos.dart';
import 'package:tolochafuel/core/models/producto_precio.dart';
import 'package:tolochafuel/features/alias/data/alias_repositorio.dart';
import 'package:tolochafuel/features/avisos/data/aviso_notificacion.dart';
import 'package:tolochafuel/features/avisos/data/avisos_repositorio.dart';
import 'package:tolochafuel/features/avisos/data/estado_avisos.dart';
import 'package:tolochafuel/features/avisos/services/comprobador_avisos.dart';
import 'package:tolochafuel/features/avisos/services/notificaciones_servicio.dart';
import 'package:tolochafuel/features/avisos/services/programador_avisos.dart';
import 'package:tolochafuel/features/favoritos/data/favorito.dart';
import 'package:tolochafuel/features/favoritos/data/favoritos_repositorio.dart';

import '../support/almacen_memoria.dart';

class FavoritosFalso extends FavoritosRepositorio {
  FavoritosFalso(this.inicial);

  final List<Favorito> inicial;
  List<Favorito> Function()? alCargar;
  int llamadas = 0;

  @override
  Future<List<Favorito>> cargarAsync() async {
    llamadas++;
    return alCargar?.call() ?? List.of(inicial);
  }
}

class AliasFalso extends AliasRepositorio {
  AliasFalso([this.valores = const {}]);

  final Map<int, String> valores;

  @override
  Future<Map<int, String>> cargarAsync() async => valores;
}

class ApiFalsa extends PreciosGasolinaApi {
  ApiFalsa({this.detalles = const {}, this.errores = const {}});

  final Map<int, DetalleEstacion> detalles;
  final Map<int, Object> errores;
  int consultas = 0;
  int activas = 0;
  int maxActivas = 0;

  @override
  Future<DetalleEstacion> detalle(int id) async {
    consultas++;
    activas++;
    maxActivas = max(maxActivas, activas);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 1));
      final error = errores[id];
      if (error != null) throw error;
      final detalle = detalles[id];
      if (detalle == null) {
        throw const ApiException(mensaje: 'Sin datos para la estación.');
      }
      return detalle;
    } finally {
      activas--;
    }
  }
}

class NotificacionesFalsas implements NotificacionesServicio {
  bool permiso = true;
  bool habilitadas = true;
  bool mostrarResultado = true;
  final List<AvisoNotificacion> mostradas = [];
  final List<int> canceladas = [];
  int canceladasTodas = 0;
  void Function(String?)? alTocar;

  @override
  Future<void> cancelar(int id) async {
    canceladas.add(id);
  }

  @override
  Future<void> cancelarTodas() async {
    canceladasTodas++;
  }

  @override
  Future<bool> estanHabilitadas() async => habilitadas;

  @override
  Future<void> inicializar({
    required void Function(String? payload) alTocar,
  }) async {
    this.alTocar = alTocar;
  }

  @override
  Future<String?> lanzamientoInicial() async => null;

  @override
  Future<bool> mostrar(AvisoNotificacion aviso) async {
    mostradas.add(aviso);
    return mostrarResultado;
  }

  @override
  Future<bool> solicitarPermiso() async => permiso;
}

class ProgramadorFalso implements ProgramadorAvisos {
  DateTime? programada;
  int programaciones = 0;
  int cancelaciones = 0;

  @override
  Future<void> programar(DateTime? proxima) async {
    programada = proxima;
    programaciones++;
  }

  @override
  Future<void> cancelar() async {
    programada = null;
    cancelaciones++;
  }
}

const _producto = ProductoPrecio(
  idApi: 'gasoline_95',
  etiqueta: 'Gasolina 95',
  unidad: 'L',
  precio: 1.459,
);

DetalleEstacion _detalle({
  double precio = 1.459,
  DateTime? lastUpdated,
  DateTime? nextUpdate,
  bool stale = false,
}) {
  final meta = MetaDatos(
    atribucion: MetaDatos.atribucionPorDefecto,
    ultimaActualizacion: lastUpdated ?? DateTime.utc(2026, 11, 22, 8),
    proximaActualizacion: nextUpdate ?? DateTime.utc(2026, 11, 22, 20),
    stale: stale,
  );
  return DetalleEstacion(
    productos: [
      ProductoPrecio(
        idApi: _producto.idApi,
        etiqueta: _producto.etiqueta,
        unidad: _producto.unidad,
        precio: precio,
      ),
    ],
    meta: meta,
    proximaActualizacion: meta.proximaActualizacion,
  );
}

Favorito _favorito(int id, {bool avisos = true}) => Favorito(
  id: id,
  nombre: 'Estación $id',
  lat: 40.4,
  lng: -3.7,
  avisosPrecio: avisos,
);

BasePrecios _base({int precio = 1459}) => BasePrecios(
  precios: {'gasoline_95': precio},
  actualizadoEn: DateTime.utc(2026, 11, 22, 8),
  lastUpdated: DateTime.utc(2026, 11, 22, 8),
);

void main() {
  late AlmacenMemoria almacen;
  late AvisosRepositorio avisos;
  late NotificacionesFalsas notificaciones;
  late ProgramadorFalso programador;
  late DateTime ahora;

  setUp(() {
    almacen = AlmacenMemoria();
    avisos = AvisosRepositorio(almacen: almacen);
    notificaciones = NotificacionesFalsas();
    programador = ProgramadorFalso();
    ahora = DateTime.utc(2026, 11, 22, 8, 5);
  });

  ComprobadorAvisosApi crear({
    required ApiFalsa api,
    required FavoritosFalso favoritos,
  }) => ComprobadorAvisosApi(
    api: api,
    favoritos: favoritos,
    avisos: avisos,
    alias: AliasFalso(),
    notificaciones: notificaciones,
    programador: programador,
    ahora: () => ahora,
  );

  test('sin avisos activos no consulta, cancela y no notifica', () async {
    final api = ApiFalsa();
    final favoritos = FavoritosFalso([_favorito(1, avisos: false)]);

    final resultado = await crear(api: api, favoritos: favoritos).comprobar();

    expect(resultado.omitida, isTrue);
    expect(api.consultas, 0);
    expect(notificaciones.mostradas, isEmpty);
    expect(programador.cancelaciones, 1);
  });

  test('crea la base en la primera comprobación sin notificar', () async {
    final api = ApiFalsa(detalles: {1: _detalle()});

    final resultado = await crear(
      api: api,
      favoritos: FavoritosFalso([_favorito(1)]),
    ).comprobar();

    expect(resultado.peticiones, 1);
    expect(notificaciones.mostradas, isEmpty);
    expect(api.consultas, 1);
    final estado = await avisos.cargar();
    expect(estado.estaciones[1]!.precios, {'gasoline_95': 1459});
    expect(programador.programada, DateTime.utc(2026, 11, 22, 20));
  });

  test('notifica una bajada y actualiza la base', () async {
    await avisos.guardar(
      EstadoAvisos(
        estaciones: {1: _base()},
        ultimoLastUpdated: DateTime.utc(2026, 11, 22, 8),
        proximaComprobacion: DateTime.utc(2026, 11, 22, 20),
      ),
    );
    ahora = DateTime.utc(2026, 11, 22, 20, 5);
    final api = ApiFalsa(
      detalles: {
        1: _detalle(
          precio: 1.429,
          lastUpdated: DateTime.utc(2026, 11, 22, 20),
          nextUpdate: DateTime.utc(2026, 11, 23, 8),
        ),
      },
    );

    final resultado = await crear(
      api: api,
      favoritos: FavoritosFalso([_favorito(1)]),
    ).comprobar();

    expect(resultado.avisos, hasLength(1));
    expect(notificaciones.mostradas, hasLength(1));
    expect(
      notificaciones.mostradas.single.cuerpo,
      'Gasolina 95: 1,459 €/L → 1,429 €/L',
    );
    expect(notificaciones.mostradas.single.payload, contains('"id":1'));
    final estado = await avisos.cargar();
    expect(estado.estaciones[1]!.precios, {'gasoline_95': 1429});
    expect(programador.programada, DateTime.utc(2026, 11, 23, 8));
  });

  test('corta tras una petición si last_updated no cambió', () async {
    await avisos.guardar(
      EstadoAvisos(
        estaciones: {1: _base()},
        ultimoLastUpdated: DateTime.utc(2026, 11, 22, 8),
        proximaComprobacion: DateTime.utc(2026, 11, 22, 20),
      ),
    );
    ahora = DateTime.utc(2026, 11, 22, 20, 5);
    final api = ApiFalsa(
      detalles: {
        1: _detalle(
          precio: 1.429,
          lastUpdated: DateTime.utc(2026, 11, 22, 8),
          nextUpdate: DateTime.utc(2026, 11, 23, 8),
        ),
      },
    );

    final resultado = await crear(
      api: api,
      favoritos: FavoritosFalso([_favorito(1)]),
    ).comprobar();

    expect(resultado.peticiones, 1);
    expect(api.consultas, 1);
    expect(notificaciones.mostradas, isEmpty);
    expect(programador.programada, DateTime.utc(2026, 11, 23, 8));
  });

  test('no consulta antes de next_update', () async {
    await avisos.guardar(
      EstadoAvisos(
        estaciones: {1: _base()},
        ultimoLastUpdated: DateTime.utc(2026, 11, 22, 8),
        proximaComprobacion: DateTime.utc(2026, 11, 22, 20),
      ),
    );
    final api = ApiFalsa();

    final resultado = await crear(
      api: api,
      favoritos: FavoritosFalso([_favorito(1)]),
    ).comprobar();

    expect(resultado.omitida, isTrue);
    expect(api.consultas, 0);
    expect(programador.programaciones, 0);
  });

  test('establece la base que falta aunque los datos no cambiaran', () async {
    await avisos.guardar(
      EstadoAvisos(
        estaciones: {1: _base()},
        ultimoLastUpdated: DateTime.utc(2026, 11, 22, 8),
        proximaComprobacion: DateTime.utc(2026, 11, 22, 20),
      ),
    );
    ahora = DateTime.utc(2026, 11, 22, 20, 5);
    final api = ApiFalsa(
      detalles: {
        1: _detalle(
          lastUpdated: DateTime.utc(2026, 11, 22, 8),
          nextUpdate: DateTime.utc(2026, 11, 23, 8),
        ),
        2: _detalle(
          precio: 1.399,
          lastUpdated: DateTime.utc(2026, 11, 22, 8),
          nextUpdate: DateTime.utc(2026, 11, 23, 8),
        ),
      },
    );

    final resultado = await crear(
      api: api,
      favoritos: FavoritosFalso([_favorito(1), _favorito(2)]),
    ).comprobar();

    expect(resultado.peticiones, 2);
    expect(notificaciones.mostradas, isEmpty);
    final estado = await avisos.cargar();
    expect(estado.estaciones[2]!.precios, {'gasoline_95': 1399});
  });

  test('continúa si una ficha falla y avisa de las que cambiaron', () async {
    await avisos.guardar(
      EstadoAvisos(
        estaciones: {1: _base(), 2: _base(), 3: _base()},
        ultimoLastUpdated: DateTime.utc(2026, 11, 22, 8),
        proximaComprobacion: DateTime.utc(2026, 11, 22, 20),
      ),
    );
    ahora = DateTime.utc(2026, 11, 22, 20, 5);
    final api = ApiFalsa(
      detalles: {
        1: _detalle(
          precio: 1.429,
          lastUpdated: DateTime.utc(2026, 11, 22, 20),
          nextUpdate: DateTime.utc(2026, 11, 23, 8),
        ),
        3: _detalle(
          lastUpdated: DateTime.utc(2026, 11, 22, 20),
          nextUpdate: DateTime.utc(2026, 11, 23, 8),
        ),
      },
      errores: {2: const ApiException(mensaje: 'Sin conexión.')},
    );

    final resultado = await crear(
      api: api,
      favoritos: FavoritosFalso([_favorito(1), _favorito(2), _favorito(3)]),
    ).comprobar();

    expect(resultado.error, isNull);
    expect(resultado.avisos, hasLength(1));
    expect(notificaciones.mostradas, hasLength(1));
    final estado = await avisos.cargar();
    expect(estado.estaciones[2]!.precios, {'gasoline_95': 1459});
  });

  test(
    'no notifica si el favorito se desmarca durante la comprobación',
    () async {
      await avisos.guardar(
        EstadoAvisos(
          estaciones: {1: _base()},
          ultimoLastUpdated: DateTime.utc(2026, 11, 22, 8),
          proximaComprobacion: DateTime.utc(2026, 11, 22, 20),
        ),
      );
      ahora = DateTime.utc(2026, 11, 22, 20, 5);
      final favoritos = FavoritosFalso([_favorito(1)]);
      favoritos.alCargar = () =>
          favoritos.llamadas == 1 ? [_favorito(1)] : <Favorito>[];
      final api = ApiFalsa(
        detalles: {
          1: _detalle(
            precio: 1.429,
            lastUpdated: DateTime.utc(2026, 11, 22, 20),
            nextUpdate: DateTime.utc(2026, 11, 23, 8),
          ),
        },
      );

      final resultado = await crear(api: api, favoritos: favoritos).comprobar();

      expect(resultado.avisos, isEmpty);
      expect(notificaciones.mostradas, isEmpty);
    },
  );

  test('no notifica si la campana se apaga durante la comprobación', () async {
    await avisos.guardar(
      EstadoAvisos(
        estaciones: {1: _base()},
        ultimoLastUpdated: DateTime.utc(2026, 11, 22, 8),
        proximaComprobacion: DateTime.utc(2026, 11, 22, 20),
      ),
    );
    ahora = DateTime.utc(2026, 11, 22, 20, 5);
    final favoritos = FavoritosFalso([_favorito(1)]);
    favoritos.alCargar = () => favoritos.llamadas == 1
        ? [_favorito(1)]
        : [_favorito(1, avisos: false)];
    final api = ApiFalsa(
      detalles: {
        1: _detalle(
          precio: 1.429,
          lastUpdated: DateTime.utc(2026, 11, 22, 20),
          nextUpdate: DateTime.utc(2026, 11, 23, 8),
        ),
      },
    );

    await crear(api: api, favoritos: favoritos).comprobar();

    expect(notificaciones.mostradas, isEmpty);
  });

  test(
    'si todas las fichas fallan programa un reintento sin notificar',
    () async {
      final api = ApiFalsa(
        errores: {1: const ApiException(mensaje: 'Sin conexión.')},
      );

      final resultado = await crear(
        api: api,
        favoritos: FavoritosFalso([_favorito(1)]),
      ).comprobar();

      expect(resultado.error, isNotNull);
      expect(resultado.avisos, isEmpty);
      expect(notificaciones.mostradas, isEmpty);
      expect(programador.programada, ahora.add(const Duration(hours: 1)));
    },
  );

  test('limita la concurrencia de las fichas', () async {
    final api = ApiFalsa(
      detalles: {for (var id = 1; id <= 6; id++) id: _detalle()},
    );

    final resultado = await crear(
      api: api,
      favoritos: FavoritosFalso([
        for (var id = 1; id <= 6; id++) _favorito(id),
      ]),
    ).comprobar();

    expect(resultado.peticiones, 6);
    expect(api.consultas, 6);
    expect(api.maxActivas, lessThanOrEqualTo(4));
    expect(notificaciones.mostradas, isEmpty);
  });

  test('crearBase guarda la base sin notificar', () async {
    final api = ApiFalsa(detalles: {1: _detalle()});
    final checker = crear(api: api, favoritos: FavoritosFalso([]));

    final resultado = await checker.crearBase(1);

    expect(resultado, ResultadoBase.creada);
    final estado = await avisos.cargar();
    expect(estado.estaciones[1]!.precios, {'gasoline_95': 1459});
    expect(notificaciones.mostradas, isEmpty);
    expect(programador.programada, DateTime.utc(2026, 11, 22, 20));
  });

  test('crearBase distingue sin precios y error', () async {
    final sinPrecios = ApiFalsa(
      detalles: {1: const DetalleEstacion(productos: [])},
    );
    expect(
      await crear(api: sinPrecios, favoritos: FavoritosFalso([])).crearBase(1),
      ResultadoBase.sinPrecios,
    );

    final error = ApiFalsa(
      errores: {1: const ApiException(mensaje: 'Sin conexión.')},
    );
    expect(
      await crear(api: error, favoritos: FavoritosFalso([])).crearBase(1),
      ResultadoBase.error,
    );
  });

  test('respeta un bloqueo vigente', () async {
    ahora = DateTime.utc(2026, 11, 22, 20, 5);
    await avisos.guardar(
      EstadoAvisos(
        estaciones: {1: _base()},
        ultimoLastUpdated: DateTime.utc(2026, 11, 22, 8),
        proximaComprobacion: DateTime.utc(2026, 11, 22, 20),
        lockHasta: ahora.add(const Duration(minutes: 5)),
      ),
    );
    final api = ApiFalsa();

    final resultado = await crear(
      api: api,
      favoritos: FavoritosFalso([_favorito(1)]),
    ).comprobar();

    expect(resultado.omitida, isTrue);
    expect(api.consultas, 0);
  });
}
