import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tolochafuel/app/shell/seccion_app.dart';
import 'package:tolochafuel/app/shell/shell_controller.dart';
import 'package:tolochafuel/app/shell/shell_pantalla.dart';
import 'package:tolochafuel/core/api/precios_gasolina_api.dart';
import 'package:tolochafuel/core/models/detalle_estacion.dart';
import 'package:tolochafuel/core/models/gasolinera.dart';
import 'package:tolochafuel/core/models/historico_estacion.dart';
import 'package:tolochafuel/core/models/meta_datos.dart';
import 'package:tolochafuel/core/models/producto_precio.dart';
import 'package:tolochafuel/core/services/ubicacion.dart';
import 'package:tolochafuel/features/alias/ui/alias_controller.dart';
import 'package:tolochafuel/features/avisos/data/aviso_notificacion.dart';
import 'package:tolochafuel/features/avisos/services/navegacion_avisos.dart';
import 'package:tolochafuel/features/avisos/ui/ficha_estacion_sheet.dart';
import 'package:tolochafuel/features/cercanas/data/cercanas_repositorio.dart';
import 'package:tolochafuel/features/cercanas/ui/buscar_controller.dart';
import 'package:tolochafuel/features/cercanas/ui/cercanas_controller.dart';
import 'package:tolochafuel/features/cercanas/ui/historial_controller.dart';
import 'package:tolochafuel/features/cercanas/ui/mas_economicas_controller.dart';
import 'package:tolochafuel/features/cercanas/ui/mas_economicas_pantalla.dart';
import 'package:tolochafuel/features/configuracion/data/configuracion_repositorio.dart';
import 'package:tolochafuel/features/configuracion/ui/configuracion_controller.dart';
import 'package:tolochafuel/features/favoritos/data/favorito.dart';
import 'package:tolochafuel/features/favoritos/data/favoritos_repositorio.dart';
import 'package:tolochafuel/features/favoritos/ui/favoritos_controller.dart';
import 'package:geolocator/geolocator.dart';

class UbicacionFalsa extends Ubicacion {
  UbicacionFalsa(this.resultado, {this.posicion});

  final ResultadoUbicacion resultado;
  final Position? posicion;

  @override
  Future<ResultadoUbicacion> preparar() async => resultado;

  @override
  Future<Position?> actual() async => posicion;
}

class RepositorioCercanasFalso extends CercanasRepositorio {
  RepositorioCercanasFalso(this.resultado);

  final ResultadoGasolineras resultado;
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
    return resultado;
  }
}

class RepositorioConfigFalso extends ConfiguracionRepositorio {
  RepositorioConfigFalso({this.inicial = const Ajustes()});

  Ajustes inicial;
  Ajustes? guardados;

  @override
  Future<Ajustes> cargar() async => inicial;

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

ResultadoGasolineras _resultado() => ResultadoGasolineras(
  gasolineras: const [
    Gasolinera(
      id: 1,
      nombre: 'Ballenoil Segovia',
      lat: 40.4,
      lng: -3.7,
      urlWeb: '',
      distanciaKm: 1.37,
      productos: [
        ProductoPrecio(
          idApi: 'gasoline_95',
          etiqueta: 'Gasolina 95 E5',
          unidad: 'L',
          precio: 1.729,
        ),
      ],
    ),
  ],
  meta: MetaDatos(
    atribucion: MetaDatos.atribucionPorDefecto,
    ultimaActualizacion: DateTime.utc(2026, 10, 9, 18, 10),
    antiguedadSegundos: 300,
  ),
);

Widget _app({
  required ConfiguracionController configuracion,
  required CercanasController cercanas,
}) => MultiProvider(
  providers: [
    ChangeNotifierProvider.value(value: configuracion),
    ChangeNotifierProvider.value(value: cercanas),
    ChangeNotifierProvider(create: (_) => FavoritosController()),
    ChangeNotifierProvider(create: (_) => AliasController()),
    ChangeNotifierProvider(create: (_) => BuscarController()),
    ChangeNotifierProvider(
      create: (_) => MasEconomicasController(
        ubicacion: UbicacionFalsa(ResultadoUbicacion.noSoportada),
      ),
    ),
  ],
  child: const MaterialApp(home: ShellPantalla()),
);

CercanasController _cercanas(ConfiguracionController configuracion) =>
    CercanasController(
      configuracion: configuracion,
      repositorio: RepositorioCercanasFalso(_resultado()),
      ubicacion: UbicacionFalsa(
        ResultadoUbicacion.concedida,
        posicion: _posicion(),
      ),
    );

class RepositorioFavoritosFalso extends FavoritosRepositorio {
  @override
  Future<List<Favorito>> cargar() async => const [];

  @override
  Future<void> guardar(List<Favorito> favoritos) async {}
}

class ApiFichaFalsa extends PreciosGasolinaApi {
  @override
  Future<DetalleEstacion> detalle(int id) async => DetalleEstacion(
    productos: const [
      ProductoPrecio(
        idApi: 'gasoline_95',
        etiqueta: 'Gasolina 95',
        unidad: 'L',
        precio: 1.729,
      ),
    ],
    nombre: 'Ballenoil',
    direccion: 'Calle Mayor, 1',
    lat: 40.4,
    lng: -3.7,
    meta: MetaDatos(
      atribucion: MetaDatos.atribucionPorDefecto,
      ultimaActualizacion: DateTime.utc(2026, 11, 22, 20),
    ),
  );
}

class ApiHistoricoFalsa extends PreciosGasolinaApi {
  @override
  Future<HistoricoEstacion> historico(int id, {int days = 5}) async =>
      HistoricoEstacion(
        series: [
          SerieCarburante(
            idApi: 'gasoline_95',
            puntos: [
              PuntoPrecio(fecha: DateTime(2026, 11, 21), precio: 1.729),
              PuntoPrecio(fecha: DateTime(2026, 11, 22), precio: 1.729),
            ],
          ),
        ],
      );
}

Widget _appConFicha({
  required ConfiguracionController configuracion,
  required CercanasController cercanas,
  required FavoritosController favoritos,
  required HistorialController historial,
  required NavegacionAvisosController navegacion,
}) => MultiProvider(
  providers: [
    ChangeNotifierProvider.value(value: configuracion),
    ChangeNotifierProvider.value(value: cercanas),
    ChangeNotifierProvider.value(value: favoritos),
    ChangeNotifierProvider(create: (_) => AliasController()),
    ChangeNotifierProvider.value(value: historial),
    ChangeNotifierProvider.value(value: navegacion),
    ChangeNotifierProvider(create: (_) => BuscarController()),
    ChangeNotifierProvider(
      create: (_) => MasEconomicasController(
        ubicacion: UbicacionFalsa(ResultadoUbicacion.noSoportada),
      ),
    ),
  ],
  child: const MaterialApp(home: ShellPantalla()),
);

void main() {
  testWidgets('el menú abre, resalta la sección activa y navega', (
    tester,
  ) async {
    final configuracion = ConfiguracionController(
      repositorio: RepositorioConfigFalso(),
    );
    await configuracion.cargar();

    await tester.pumpWidget(
      _app(configuracion: configuracion, cercanas: _cercanas(configuracion)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    final drawer = tester.widget<NavigationDrawer>(
      find.byType(NavigationDrawer),
    );
    expect(drawer.selectedIndex, SeccionApp.cercanas.index);
    for (final seccion in SeccionApp.values) {
      expect(find.text(seccion.titulo), findsWidgets);
    }

    await tester.tap(find.text('Favoritas').last);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationDrawer), findsNothing);
    expect(find.text('Aún no tienes gasolineras favoritas'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Configuración').last);
    await tester.pumpAndSettle();
    expect(find.text('Tema'), findsOneWidget);
    expect(find.text('Sistema'), findsOneWidget);
  });

  testWidgets('arranca en la pantalla inicial y no salta al cambiarla', (
    tester,
  ) async {
    final configuracion = ConfiguracionController(
      repositorio: RepositorioConfigFalso(
        inicial: const Ajustes(pantallaInicial: SeccionApp.masEconomicas),
      ),
    );
    await configuracion.cargar();

    await tester.pumpWidget(
      _app(configuracion: configuracion, cercanas: _cercanas(configuracion)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MasEconomicasPantalla), findsOneWidget);

    await configuracion.cambiarPantallaInicial(SeccionApp.buscar);
    await tester.pumpAndSettle();

    expect(find.byType(MasEconomicasPantalla), findsOneWidget);
  });

  testWidgets('conserva el estado y no repite peticiones al volver', (
    tester,
  ) async {
    final configuracion = ConfiguracionController(
      repositorio: RepositorioConfigFalso(),
    );
    await configuracion.cargar();
    final repositorio = RepositorioCercanasFalso(_resultado());
    final cercanas = CercanasController(
      configuracion: configuracion,
      repositorio: repositorio,
      ubicacion: UbicacionFalsa(
        ResultadoUbicacion.concedida,
        posicion: _posicion(),
      ),
    );

    await tester.pumpWidget(
      _app(configuracion: configuracion, cercanas: cercanas),
    );
    await tester.pumpAndSettle();
    expect(repositorio.llamadas, 1);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buscar').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cercanas').last);
    await tester.pumpAndSettle();

    expect(repositorio.llamadas, 1);
    expect(find.text('Ballenoil Segovia'), findsOneWidget);
  });

  test('el controlador del shell conserva las secciones visitadas', () {
    final shell = ShellController(SeccionApp.cercanas);

    expect(shell.visitada(SeccionApp.buscar), isFalse);

    shell.irA(SeccionApp.buscar);

    expect(shell.seccion, SeccionApp.buscar);
    expect(shell.visitada(SeccionApp.buscar), isTrue);
    expect(shell.visitada(SeccionApp.cercanas), isTrue);
  });

  testWidgets('abre la ficha de una estación pendiente de notificación', (
    tester,
  ) async {
    final configuracion = ConfiguracionController(
      repositorio: RepositorioConfigFalso(),
    );
    await configuracion.cargar();
    final favoritos = FavoritosController(
      repositorio: RepositorioFavoritosFalso(),
      api: ApiFichaFalsa(),
    );
    await favoritos.cargar();
    final navegacion = NavegacionAvisosController()
      ..abrir(const EstacionAviso(id: 7, nombre: 'Ballenoil'));

    await tester.pumpWidget(
      _appConFicha(
        configuracion: configuracion,
        cercanas: _cercanas(configuracion),
        favoritos: favoritos,
        historial: HistorialController(api: ApiHistoricoFalsa()),
        navegacion: navegacion,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FichaEstacionSheet), findsOneWidget);
    expect(find.text('Gasolina 95'), findsWidgets);
    expect(find.text('Calle Mayor, 1'), findsOneWidget);
  });
}
