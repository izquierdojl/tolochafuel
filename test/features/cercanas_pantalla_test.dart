import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:tolochafuel/app/shell/seccion_app.dart';
import 'package:tolochafuel/app/shell/shell_controller.dart';
import 'package:tolochafuel/app/theme/app_theme.dart';
import 'package:tolochafuel/core/api/api_client.dart';
import 'package:tolochafuel/core/api/precios_gasolina_api.dart';
import 'package:tolochafuel/core/models/gasolinera.dart';
import 'package:tolochafuel/core/models/historico_estacion.dart';
import 'package:tolochafuel/core/models/meta_datos.dart';
import 'package:tolochafuel/core/models/producto_precio.dart';
import 'package:tolochafuel/core/services/ubicacion.dart';
import 'package:tolochafuel/features/alias/ui/alias_controller.dart';
import 'package:tolochafuel/features/cercanas/data/cercanas_repositorio.dart';
import 'package:tolochafuel/features/cercanas/ui/cercanas_controller.dart';
import 'package:tolochafuel/features/cercanas/ui/cercanas_pantalla.dart';
import 'package:tolochafuel/features/cercanas/ui/historial_controller.dart';
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
  RepositorioFalso({this.resultado, this.error});

  ResultadoGasolineras? resultado;
  Object? error;
  int llamadas = 0;

  @override
  Future<ResultadoGasolineras> cercanas({
    required double lat,
    required double lng,
    double radioKm = 5,
  }) async {
    llamadas++;
    final fallo = error;
    if (fallo != null) throw fallo;
    return resultado!;
  }
}

class ApiHistoricoFalsa extends PreciosGasolinaApi {
  @override
  Future<HistoricoEstacion> historico(int id, {int days = 5}) async =>
      HistoricoEstacion(
        series: [
          SerieCarburante(
            idApi: 'gasoline_95',
            puntos: [
              PuntoPrecio(fecha: DateTime(2026, 10, 9), precio: 1.739),
              PuntoPrecio(fecha: DateTime(2026, 10, 10), precio: 1.729),
            ],
          ),
        ],
      );
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

Gasolinera _gasolinera({
  required int id,
  required String nombre,
  double? distancia,
  List<ProductoPrecio> productos = const [],
}) => Gasolinera(
  id: id,
  nombre: nombre,
  lat: 40.4,
  lng: -3.7,
  urlWeb: 'https://preciosgasolina.es',
  distanciaKm: distancia,
  productos: productos,
);

const _gasolina95 = ProductoPrecio(
  idApi: 'gasoline_95',
  etiqueta: 'Gasolina 95 E5',
  unidad: 'L',
  precio: 1.729,
);
const _diesel = ProductoPrecio(
  idApi: 'diesel',
  etiqueta: 'Gasóleo A (diésel)',
  unidad: 'L',
  precio: 1.859,
);

ResultadoGasolineras _resultado(List<Gasolinera> estaciones) =>
    ResultadoGasolineras(
      gasolineras: estaciones,
      meta: MetaDatos(
        atribucion: MetaDatos.atribucionPorDefecto,
        ultimaActualizacion: DateTime.utc(2026, 10, 9, 18, 10),
        antiguedadSegundos: 300,
      ),
    );

Widget _app(
  CercanasController controller, {
  ShellController? shell,
  HistorialController? historial,
}) => MultiProvider(
  providers: [
    ChangeNotifierProvider.value(value: controller),
    ChangeNotifierProvider.value(
      value: shell ?? ShellController(SeccionApp.cercanas),
    ),
    ChangeNotifierProvider(create: (_) => FavoritosController()),
    ChangeNotifierProvider(create: (_) => AliasController()),
    if (historial != null) ChangeNotifierProvider.value(value: historial),
  ],
  child: MaterialApp(
    theme: AppTheme.oscuro,
    home: const Scaffold(body: CercanasPantalla()),
  ),
);

void main() {
  testWidgets(
    'muestra el indicador de carga mientras se obtiene la ubicación',
    (tester) async {
      final controller = CercanasController(
        ubicacion: UbicacionColgada(),
        repositorio: RepositorioFalso(),
      );

      await tester.pumpWidget(_app(controller));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );

  testWidgets('muestra el error y reintenta la carga', (tester) async {
    final repositorio = RepositorioFalso(
      error: const ApiException(mensaje: 'Sin conexión a internet.'),
    );
    final controller = CercanasController(
      ubicacion: UbicacionFalsa(
        ResultadoUbicacion.concedida,
        posicion: _posicion(),
      ),
      repositorio: repositorio,
    );

    await tester.pumpWidget(_app(controller));
    await tester.pumpAndSettle();
    expect(find.text('Sin conexión a internet.'), findsOneWidget);
    expect(find.textContaining('Datos del'), findsNothing);

    repositorio
      ..error = null
      ..resultado = _resultado([
        _gasolinera(
          id: 1,
          nombre: 'Ballenoil',
          distancia: 1.37,
          productos: const [_gasolina95],
        ),
      ]);
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('Ballenoil'), findsOneWidget);
    expect(find.text('Gasolina 95 E5'), findsOneWidget);
    expect(repositorio.llamadas, 2);
  });

  testWidgets('muestra el estado vacío cuando no hay gasolineras', (
    tester,
  ) async {
    final controller = CercanasController(
      ubicacion: UbicacionFalsa(
        ResultadoUbicacion.concedida,
        posicion: _posicion(),
      ),
      repositorio: RepositorioFalso(resultado: _resultado(const [])),
    );

    await tester.pumpWidget(_app(controller));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('No hay gasolineras en el radio'),
      findsOneWidget,
    );
    expect(find.textContaining('Datos del'), findsOneWidget);
  });

  testWidgets('muestra los productos de cada gasolinera', (tester) async {
    final controller = CercanasController(
      ubicacion: UbicacionFalsa(
        ResultadoUbicacion.concedida,
        posicion: _posicion(),
      ),
      repositorio: RepositorioFalso(
        resultado: _resultado([
          _gasolinera(
            id: 1,
            nombre: 'Ballenoil Segovia',
            distancia: 1.37,
            productos: const [_gasolina95, _diesel],
          ),
          _gasolinera(id: 2, nombre: 'Blanca'),
        ]),
      ),
    );

    await tester.pumpWidget(_app(controller));
    await tester.pumpAndSettle();

    expect(find.text('Ballenoil Segovia'), findsOneWidget);
    expect(find.text('a 1,4 km'), findsOneWidget);
    expect(find.text('Gasolina 95 E5'), findsOneWidget);
    expect(find.text('1,729 €/L'), findsOneWidget);
    expect(find.text('Gasóleo A (diésel)'), findsOneWidget);
    expect(find.text('1,859 €/L'), findsOneWidget);
    expect(find.text('Precios no disponibles'), findsOneWidget);
    expect(find.textContaining('Datos del'), findsOneWidget);
  });

  testWidgets('sin ubicación muestra el aviso con acceso a Buscar', (
    tester,
  ) async {
    final shell = ShellController(SeccionApp.cercanas);
    final controller = CercanasController(
      ubicacion: UbicacionFalsa(ResultadoUbicacion.denegada),
      repositorio: RepositorioFalso(),
    );

    await tester.pumpWidget(_app(controller, shell: shell));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Permiso de ubicación denegado'),
      findsOneWidget,
    );
    expect(find.text('Ir a Buscar'), findsOneWidget);

    await tester.tap(find.text('Ir a Buscar'));
    expect(shell.seccion, SeccionApp.buscar);
  });

  testWidgets('ofrece navegar por cada gasolinera de la lista', (tester) async {
    final controller = CercanasController(
      ubicacion: UbicacionFalsa(
        ResultadoUbicacion.concedida,
        posicion: _posicion(),
      ),
      repositorio: RepositorioFalso(
        resultado: _resultado([
          _gasolinera(id: 1, nombre: 'Ballenoil Segovia', distancia: 1.37),
          _gasolinera(id: 2, nombre: 'Blanca'),
        ]),
      ),
    );

    await tester.pumpWidget(_app(controller));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Navegar'), findsNWidgets(2));
  });

  testWidgets('integra la flecha de tendencia en la lista', (tester) async {
    final controller = CercanasController(
      ubicacion: UbicacionFalsa(
        ResultadoUbicacion.concedida,
        posicion: _posicion(),
      ),
      repositorio: RepositorioFalso(
        resultado: _resultado([
          _gasolinera(
            id: 1,
            nombre: 'Ballenoil Segovia',
            distancia: 1.37,
            productos: const [_gasolina95],
          ),
        ]),
      ),
    );
    final historial = HistorialController(api: ApiHistoricoFalsa());

    await tester.pumpWidget(_app(controller, historial: historial));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
  });
}
