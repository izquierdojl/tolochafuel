import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tolochafuel/core/api/precios_gasolina_api.dart';
import 'package:tolochafuel/core/models/gasolinera.dart';
import 'package:tolochafuel/core/models/meta_datos.dart';
import 'package:tolochafuel/core/services/ubicacion.dart';
import 'package:tolochafuel/features/cercanas/data/cercanas_repositorio.dart';
import 'package:tolochafuel/features/cercanas/ui/cercanas_controller.dart';
import 'package:tolochafuel/features/configuracion/data/configuracion_repositorio.dart';
import 'package:tolochafuel/features/configuracion/ui/configuracion_controller.dart';

class UbicacionFalsa extends Ubicacion {
  UbicacionFalsa(this.posicion);

  final Position posicion;

  @override
  Future<ResultadoUbicacion> preparar() async => ResultadoUbicacion.concedida;

  @override
  Future<Position?> actual() async => posicion;
}

class RepositorioCercanasFalso extends CercanasRepositorio {
  RepositorioCercanasFalso({this.vaciar = false});

  bool vaciar;
  int llamadas = 0;
  final List<double> radios = [];

  @override
  Future<ResultadoGasolineras> cercanas({
    required double lat,
    required double lng,
    double radioKm = 5,
  }) async {
    llamadas++;
    radios.add(radioKm);
    return ResultadoGasolineras(
      gasolineras: vaciar
          ? const []
          : const [
              Gasolinera(
                id: 1,
                nombre: 'Una',
                lat: 40.4,
                lng: -3.7,
                urlWeb: '',
              ),
            ],
      meta: const MetaDatos(atribucion: MetaDatos.atribucionPorDefecto),
    );
  }
}

class RepositorioConfigFalso extends ConfiguracionRepositorio {
  Ajustes? guardados;

  @override
  Future<Ajustes> cargar() async => const Ajustes();

  @override
  Future<void> guardar(Ajustes ajustes) async {
    guardados = ajustes;
  }
}

Position _posicion() => Position(
  longitude: -3.704,
  latitude: 40.417,
  timestamp: DateTime.utc(2026, 10, 10),
  accuracy: 10,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

void main() {
  Future<
    (CercanasController, RepositorioCercanasFalso, ConfiguracionController)
  >
  preparar() async {
    final configuracion = ConfiguracionController(
      repositorio: RepositorioConfigFalso(),
    );
    await configuracion.cargar();
    final repositorio = RepositorioCercanasFalso();
    final controller = CercanasController(
      configuracion: configuracion,
      repositorio: repositorio,
      ubicacion: UbicacionFalsa(_posicion()),
    );
    await controller.inicializar();
    return (controller, repositorio, configuracion);
  }

  test('usa el radio configurado en la consulta', () async {
    final (controller, repositorio, _) = await preparar();

    expect(controller.radioKm, Ajustes.radioPorDefectoKm);
    expect(repositorio.radios, [Ajustes.radioPorDefectoKm]);
  });

  test('recarga al cambiar el radio en configuración', () async {
    final (_, repositorio, configuracion) = await preparar();

    await configuracion.cambiarRadio(40);
    await pumpEventQueue();

    expect(repositorio.llamadas, 2);
    expect(repositorio.radios, [Ajustes.radioPorDefectoKm, 40]);
  });

  test('no recarga si el radio no cambia ni al cambiar el tema', () async {
    final (_, repositorio, configuracion) = await preparar();

    await configuracion.cambiarRadio(Ajustes.radioPorDefectoKm);
    await configuracion.cambiarTema(oscuro: false);
    await pumpEventQueue();

    expect(repositorio.llamadas, 1);
  });

  test('expone el meta de la respuesta', () async {
    final (controller, _, _) = await preparar();

    expect(controller.meta, isNotNull);
  });

  test('conserva el meta cuando el listado llega vacío', () async {
    final configuracion = ConfiguracionController(
      repositorio: RepositorioConfigFalso(),
    );
    await configuracion.cargar();
    final controller = CercanasController(
      configuracion: configuracion,
      repositorio: RepositorioCercanasFalso(vaciar: true),
      ubicacion: UbicacionFalsa(_posicion()),
    );

    await controller.inicializar();

    expect(controller.estado, EstadoCercanas.vacio);
    expect(controller.meta, isNotNull);
  });
}
