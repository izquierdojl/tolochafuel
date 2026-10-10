import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:tolochafuel/app/shell/seccion_app.dart';
import 'package:tolochafuel/app/shell/shell_controller.dart';
import 'package:tolochafuel/core/api/api_client.dart';
import 'package:tolochafuel/core/api/precios_gasolina_api.dart';
import 'package:tolochafuel/core/models/gasolinera.dart';
import 'package:tolochafuel/core/models/meta_datos.dart';
import 'package:tolochafuel/core/models/producto_precio.dart';
import 'package:tolochafuel/core/services/ubicacion.dart';
import 'package:tolochafuel/features/cercanas/data/cercanas_repositorio.dart';
import 'package:tolochafuel/features/cercanas/ui/cercanas_controller.dart';
import 'package:tolochafuel/features/cercanas/ui/mas_economicas_controller.dart';
import 'package:tolochafuel/features/cercanas/ui/mas_economicas_pantalla.dart';
import 'package:tolochafuel/features/configuracion/data/configuracion_repositorio.dart';
import 'package:tolochafuel/features/configuracion/ui/configuracion_controller.dart';
import 'package:tolochafuel/features/favoritos/ui/favoritos_controller.dart';

class UbicacionFalsa extends Ubicacion {
  UbicacionFalsa(this.resultado, {this.posicion});

  final ResultadoUbicacion resultado;
  final Position? posicion;

  @override
  Future<ResultadoUbicacion> preparar() async => resultado;

  @override
  Future<Position?> actual() async => posicion;
}

class UbicacionColgada extends Ubicacion {
  @override
  Future<ResultadoUbicacion> preparar() =>
      Completer<ResultadoUbicacion>().future;

  @override
  Future<Position?> actual() async => null;
}

class RepositorioFalso extends CercanasRepositorio {
  ResultadoGasolineras? resultado;
  Object? error;
  int llamadas = 0;
  final List<double> radios = [];

  @override
  Future<ResultadoGasolineras> masEconomicas({
    required double lat,
    required double lng,
    required double radioKm,
  }) async {
    llamadas++;
    radios.add(radioKm);
    final fallo = error;
    if (fallo != null) throw fallo;
    return resultado!;
  }
}

class RepositorioConfigFalso extends ConfiguracionRepositorio {
  RepositorioConfigFalso({this.inicial = const Ajustes()});

  Ajustes inicial;

  @override
  Future<Ajustes> cargar() async => inicial;

  @override
  Future<void> guardar(Ajustes ajustes) async {}
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

const _gasolina95 = ProductoPrecio(
  idApi: 'gasoline_95',
  etiqueta: 'Gasolina 95 E5',
  unidad: 'L',
  precio: 1.729,
);

ResultadoGasolineras _resultado({bool vacio = false}) => ResultadoGasolineras(
  gasolineras: vacio
      ? const []
      : const [
          Gasolinera(
            id: 3213,
            nombre: 'Ballenoil Segovia',
            lat: 40.41,
            lng: -3.71,
            urlWeb: '',
            distanciaKm: 3,
            productos: [_gasolina95],
          ),
        ],
  meta: MetaDatos(
    atribucion: MetaDatos.atribucionPorDefecto,
    ultimaActualizacion: DateTime.utc(2026, 10, 9, 18, 10),
    antiguedadSegundos: 300,
  ),
);

Widget _pantalla(
  MasEconomicasController controller, {
  ShellController? shell,
}) => MultiProvider(
  providers: [
    ChangeNotifierProvider.value(value: controller),
    ChangeNotifierProvider.value(
      value: shell ?? ShellController(SeccionApp.cercanas),
    ),
    ChangeNotifierProvider(create: (_) => FavoritosController()),
  ],
  child: const MaterialApp(home: Scaffold(body: MasEconomicasPantalla())),
);

void main() {
  test('carga las más baratas con el radio configurado', () async {
    final configuracion = ConfiguracionController(
      repositorio: RepositorioConfigFalso(inicial: const Ajustes(radioKm: 40)),
    );
    await configuracion.cargar();
    final repositorio = RepositorioFalso()..resultado = _resultado();
    final controller = MasEconomicasController(
      configuracion: configuracion,
      repositorio: repositorio,
      ubicacion: UbicacionFalsa(
        ResultadoUbicacion.concedida,
        posicion: _posicion(),
      ),
    );

    await controller.inicializar();

    expect(controller.estado, EstadoCercanas.datos);
    expect(controller.gasolineras.single.nombre, 'Ballenoil Segovia');
    expect(repositorio.radios, [40]);
  });

  test('expone el meta de la respuesta y lo conserva en vacío', () async {
    final controller = MasEconomicasController(
      repositorio: RepositorioFalso()..resultado = _resultado(),
      ubicacion: UbicacionFalsa(
        ResultadoUbicacion.concedida,
        posicion: _posicion(),
      ),
    );
    await controller.inicializar();
    expect(controller.meta, isNotNull);

    final vacio = MasEconomicasController(
      repositorio: RepositorioFalso()..resultado = _resultado(vacio: true),
      ubicacion: UbicacionFalsa(
        ResultadoUbicacion.concedida,
        posicion: _posicion(),
      ),
    );
    await vacio.inicializar();
    expect(vacio.estado, EstadoCercanas.vacio);
    expect(vacio.meta, isNotNull);
  });

  test('sin ubicación avisa y queda en estado vacío', () async {
    final controller = MasEconomicasController(
      repositorio: RepositorioFalso()..resultado = _resultado(),
      ubicacion: UbicacionFalsa(ResultadoUbicacion.noSoportada),
    );

    await controller.inicializar();

    expect(controller.estado, EstadoCercanas.vacio);
    expect(controller.avisoUbicacion, isNotNull);
  });

  test('error de la API con mensaje en español', () async {
    final controller = MasEconomicasController(
      repositorio: RepositorioFalso()
        ..error = const ApiException(mensaje: 'Sin conexión.'),
      ubicacion: UbicacionFalsa(
        ResultadoUbicacion.concedida,
        posicion: _posicion(),
      ),
    );

    await controller.inicializar();

    expect(controller.estado, EstadoCercanas.error);
    expect(controller.mensajeError, 'Sin conexión.');
  });

  testWidgets('muestra el indicador de carga', (tester) async {
    final controller = MasEconomicasController(
      repositorio: RepositorioFalso()..resultado = _resultado(),
      ubicacion: UbicacionColgada(),
    );

    await tester.pumpWidget(_pantalla(controller));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('lista las más baratas con distancia y atribución', (
    tester,
  ) async {
    final controller = MasEconomicasController(
      repositorio: RepositorioFalso()..resultado = _resultado(),
      ubicacion: UbicacionFalsa(
        ResultadoUbicacion.concedida,
        posicion: _posicion(),
      ),
    );

    await tester.pumpWidget(_pantalla(controller));
    await tester.pumpAndSettle();

    expect(find.text('Más económicas en 25 km'), findsOneWidget);
    expect(find.text('Orden por Gasolina 95'), findsOneWidget);
    expect(find.text('Ballenoil Segovia'), findsOneWidget);
    expect(find.text('a 3,0 km'), findsOneWidget);
    expect(find.text('1,729 €/L'), findsOneWidget);
    expect(find.textContaining('Datos del'), findsOneWidget);
  });

  testWidgets('estado vacío si no hay estaciones en el radio', (tester) async {
    final controller = MasEconomicasController(
      repositorio: RepositorioFalso()..resultado = _resultado(vacio: true),
      ubicacion: UbicacionFalsa(
        ResultadoUbicacion.concedida,
        posicion: _posicion(),
      ),
    );

    await tester.pumpWidget(_pantalla(controller));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('No hay estaciones en el radio'),
      findsOneWidget,
    );
  });

  testWidgets('error con reintento', (tester) async {
    final repositorio = RepositorioFalso()
      ..error = const ApiException(mensaje: 'Sin conexión.');
    final controller = MasEconomicasController(
      repositorio: repositorio,
      ubicacion: UbicacionFalsa(
        ResultadoUbicacion.concedida,
        posicion: _posicion(),
      ),
    );

    await tester.pumpWidget(_pantalla(controller));
    await tester.pumpAndSettle();
    expect(find.text('Sin conexión.'), findsOneWidget);
    expect(find.textContaining('Datos del'), findsNothing);

    repositorio
      ..error = null
      ..resultado = _resultado();
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('Ballenoil Segovia'), findsOneWidget);
    expect(repositorio.llamadas, 2);
  });

  testWidgets('sin ubicación ofrece ir a Buscar', (tester) async {
    final shell = ShellController(SeccionApp.masEconomicas);
    final controller = MasEconomicasController(
      repositorio: RepositorioFalso()..resultado = _resultado(),
      ubicacion: UbicacionFalsa(ResultadoUbicacion.denegada),
    );

    await tester.pumpWidget(_pantalla(controller, shell: shell));
    await tester.pumpAndSettle();

    expect(find.text('Ir a Buscar'), findsOneWidget);
    await tester.tap(find.text('Ir a Buscar'));
    expect(shell.seccion, SeccionApp.buscar);
  });
}
