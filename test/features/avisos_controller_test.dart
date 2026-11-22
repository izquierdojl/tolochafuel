import 'package:flutter_test/flutter_test.dart';
import 'package:tolochafuel/core/api/precios_gasolina_api.dart';
import 'package:tolochafuel/core/models/detalle_estacion.dart';
import 'package:tolochafuel/core/models/gasolinera.dart';
import 'package:tolochafuel/core/models/producto_precio.dart';
import 'package:tolochafuel/features/avisos/data/aviso_notificacion.dart';
import 'package:tolochafuel/features/avisos/data/avisos_repositorio.dart';
import 'package:tolochafuel/features/avisos/data/estado_avisos.dart';
import 'package:tolochafuel/features/avisos/services/comprobador_avisos.dart';
import 'package:tolochafuel/features/avisos/services/notificaciones_servicio.dart';
import 'package:tolochafuel/features/avisos/services/programador_avisos.dart';
import 'package:tolochafuel/features/avisos/ui/avisos_controller.dart';
import 'package:tolochafuel/features/favoritos/data/favorito.dart';
import 'package:tolochafuel/features/favoritos/data/favoritos_repositorio.dart';
import 'package:tolochafuel/features/favoritos/ui/favoritos_controller.dart';

import '../support/almacen_memoria.dart';

class RepositorioFalso extends FavoritosRepositorio {
  List<Favorito> inicial = const [];
  List<Favorito>? guardados;

  @override
  Future<List<Favorito>> cargar() async => inicial;

  @override
  Future<List<Favorito>> cargarAsync() async => guardados ?? inicial;

  @override
  Future<void> guardar(List<Favorito> favoritos) async {
    guardados = favoritos;
  }
}

class ApiFalsa extends PreciosGasolinaApi {
  @override
  Future<DetalleEstacion> detalle(int id) async => const DetalleEstacion(
    productos: [
      ProductoPrecio(
        idApi: 'gasoline_95',
        etiqueta: 'Gasolina 95',
        unidad: 'L',
        precio: 1.459,
      ),
    ],
  );
}

class ComprobadorFalso implements ComprobadorAvisos {
  ResultadoBase base = ResultadoBase.creada;
  ResultadoComprobacion resultado = const ResultadoComprobacion();
  int comprobaciones = 0;
  int bases = 0;

  @override
  Future<ResultadoComprobacion> comprobar() async {
    comprobaciones++;
    return resultado;
  }

  @override
  Future<ResultadoBase> crearBase(int estacionId) async {
    bases++;
    return base;
  }
}

class NotificacionesFalsas implements NotificacionesServicio {
  bool permiso = true;
  bool habilitadas = true;
  final List<int> canceladas = [];
  int canceladasTodas = 0;
  final List<AvisoNotificacion> mostradas = [];

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
  }) async {}

  @override
  Future<String?> lanzamientoInicial() async => null;

  @override
  Future<bool> mostrar(AvisoNotificacion aviso) async {
    mostradas.add(aviso);
    return true;
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

Gasolinera _gasolinera({int id = 1}) => Gasolinera(
  id: id,
  nombre: 'Estación $id',
  lat: 40.4,
  lng: -3.7,
  urlWeb: '',
);

BasePrecios _base() => BasePrecios(
  precios: const {'gasoline_95': 1459},
  actualizadoEn: DateTime.utc(2026, 11, 22, 8),
  lastUpdated: DateTime.utc(2026, 11, 22, 8),
);

void main() {
  late RepositorioFalso repositorio;
  late FavoritosController favoritos;
  late AvisosRepositorio avisosRepo;
  late ComprobadorFalso comprobador;
  late NotificacionesFalsas notificaciones;
  late ProgramadorFalso programador;
  late AvisosController avisos;

  setUp(() async {
    repositorio = RepositorioFalso();
    favoritos = FavoritosController(repositorio: repositorio, api: ApiFalsa());
    await favoritos.cargar();
    avisosRepo = AvisosRepositorio(almacen: AlmacenMemoria());
    comprobador = ComprobadorFalso();
    notificaciones = NotificacionesFalsas();
    programador = ProgramadorFalso();
    avisos = AvisosController(
      favoritos: favoritos,
      comprobador: comprobador,
      repositorio: avisosRepo,
      notificaciones: notificaciones,
      programador: programador,
    );
  });

  tearDown(() {
    avisos.dispose();
  });

  test('activa el aviso con permiso y crea la base', () async {
    await favoritos.alternar(_gasolinera());

    final resultado = await avisos.alternarAviso(1);

    expect(resultado, ResultadoAviso.activado);
    expect(favoritos.avisosActivos(1), isTrue);
    expect(repositorio.guardados!.single.avisosPrecio, isTrue);
    expect(comprobador.bases, 1);
    expect(programador.programaciones, greaterThan(0));
  });

  test('no activa el aviso si se deniega el permiso', () async {
    await favoritos.alternar(_gasolinera());
    notificaciones.permiso = false;

    final resultado = await avisos.alternarAviso(1);

    expect(resultado, ResultadoAviso.permisoDenegado);
    expect(favoritos.avisosActivos(1), isFalse);
    expect(comprobador.bases, 0);
  });

  test('no activa el aviso si las notificaciones están desactivadas', () async {
    await favoritos.alternar(_gasolinera());
    notificaciones.habilitadas = false;

    final resultado = await avisos.alternarAviso(1);

    expect(resultado, ResultadoAviso.notificacionesDesactivadas);
    expect(favoritos.avisosActivos(1), isFalse);
    expect(comprobador.bases, 0);
  });

  test('desactiva el aviso, borra la base y cancela la notificación', () async {
    await favoritos.alternar(_gasolinera());
    await avisosRepo.guardarBase(1, _base());
    await avisos.alternarAviso(1);

    final resultado = await avisos.alternarAviso(1);
    await avisos.reconciliar();

    expect(resultado, ResultadoAviso.desactivado);
    expect(favoritos.avisosActivos(1), isFalse);
    expect((await avisosRepo.cargar()).estaciones, isEmpty);
    expect(notificaciones.canceladas, contains(1));
  });

  test('no activa un aviso de una estación que no es favorita', () async {
    final resultado = await avisos.alternarAviso(9);

    expect(resultado, ResultadoAviso.noFavorito);
    expect(comprobador.bases, 0);
  });

  test('mantiene el aviso activo si falla la creación de la base', () async {
    await favoritos.alternar(_gasolinera());
    comprobador.base = ResultadoBase.error;

    final resultado = await avisos.alternarAviso(1);

    expect(resultado, ResultadoAviso.activadoSinBase);
    expect(favoritos.avisosActivos(1), isTrue);
  });

  test(
    'desmarcar el favorito elimina su base y cancela la programación',
    () async {
      await favoritos.alternar(_gasolinera());
      await avisosRepo.guardarBase(1, _base());
      await avisos.alternarAviso(1);

      await favoritos.quitar(1);
      await avisos.reconciliar();

      expect((await avisosRepo.cargar()).estaciones, isEmpty);
      expect(programador.cancelaciones, greaterThan(0));
    },
  );

  test('volver a marcar tras desmarcar empieza sin aviso', () async {
    await favoritos.alternar(_gasolinera());
    await avisos.alternarAviso(1);

    await favoritos.quitar(1);
    await favoritos.alternar(_gasolinera());

    expect(favoritos.avisosActivos(1), isFalse);
  });

  test('guarda los avisos que no se pudieron mostrar en la app', () async {
    const notificacion = AvisoNotificacion(
      estacionId: 1,
      titulo: 'Estación 1',
      cuerpo: 'Gasolina 95: 1,459 €/L → 1,429 €/L',
      textoLargo: 'Gasolina 95: 1,459 €/L → 1,429 €/L',
      payload: '{"id":1,"nombre":"Estación 1"}',
    );
    comprobador.resultado = const ResultadoComprobacion(
      avisosEnApp: [notificacion],
    );

    await avisos.comprobarSiToca();

    expect(avisos.avisosEnApp, hasLength(1));

    avisos.olvidarAvisoEnApp(notificacion);

    expect(avisos.avisosEnApp, isEmpty);
  });

  test(
    'sin avisos activos cancela el programador y las notificaciones',
    () async {
      await avisos.reconciliar();

      expect(programador.cancelaciones, greaterThan(0));
      expect(notificaciones.canceladasTodas, greaterThan(0));
    },
  );

  test('con avisos activos programa la próxima comprobación', () async {
    await favoritos.alternar(_gasolinera());
    await avisos.alternarAviso(1);
    final proxima = DateTime.utc(2026, 11, 22, 20);
    await avisosRepo.guardar(
      EstadoAvisos(estaciones: {1: _base()}, proximaComprobacion: proxima),
    );

    await avisos.reconciliar();

    expect(programador.programada, proxima);
  });
}
