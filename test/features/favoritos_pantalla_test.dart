import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tolochafuel/app/theme/app_theme.dart';
import 'package:tolochafuel/core/api/api_client.dart';
import 'package:tolochafuel/core/api/precios_gasolina_api.dart';
import 'package:tolochafuel/core/models/detalle_estacion.dart';
import 'package:tolochafuel/core/models/gasolinera.dart';
import 'package:tolochafuel/core/models/historico_estacion.dart';
import 'package:tolochafuel/core/models/meta_datos.dart';
import 'package:tolochafuel/core/models/producto_precio.dart';
import 'package:tolochafuel/features/alias/ui/alias_controller.dart';
import 'package:tolochafuel/features/cercanas/ui/historial_controller.dart';
import 'package:tolochafuel/features/cercanas/ui/widgets/tarjeta_gasolinera.dart';
import 'package:tolochafuel/features/favoritos/data/favorito.dart';
import 'package:tolochafuel/features/favoritos/data/favoritos_repositorio.dart';
import 'package:tolochafuel/features/favoritos/ui/favoritos_controller.dart';
import 'package:tolochafuel/features/favoritos/ui/favoritos_pantalla.dart';

class ApiFalsa extends PreciosGasolinaApi {
  ApiFalsa({Map<int, DetalleEstacion>? detalles, Map<int, Object>? errores})
    : detalles = detalles ?? {},
      errores = errores ?? {};

  final Map<int, DetalleEstacion> detalles;
  final Map<int, Object> errores;

  @override
  Future<DetalleEstacion> detalle(int id) async {
    final error = errores[id];
    if (error != null) throw error;
    return detalles[id] ?? const DetalleEstacion(productos: []);
  }
}

class ApiLenta extends PreciosGasolinaApi {
  ApiLenta(this.completer);

  final Completer<DetalleEstacion> completer;

  @override
  Future<DetalleEstacion> detalle(int id) => completer.future;
}

class RepositorioFalso extends FavoritosRepositorio {
  RepositorioFalso({this.inicial = const []});

  final List<Favorito> inicial;
  bool fallarGuardado = false;

  @override
  Future<List<Favorito>> cargar() async => inicial;

  @override
  Future<void> guardar(List<Favorito> favoritos) async {
    if (fallarGuardado) throw Exception('fallo de guardado');
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

const _producto = ProductoPrecio(
  idApi: 'gasoline_95',
  etiqueta: 'Gasolina 95 E5',
  unidad: 'L',
  precio: 1.729,
);

Gasolinera _gasolinera({
  int id = 3194,
  String nombre = 'Ballenoil Democracia',
}) => Gasolinera(
  id: id,
  nombre: nombre,
  lat: 40.4,
  lng: -3.61,
  urlWeb: '',
  direccion: 'Calle Democracia, 12',
);

Widget _pantalla(
  FavoritosController controller, {
  HistorialController? historial,
}) => MultiProvider(
  providers: [
    ChangeNotifierProvider.value(value: controller),
    ChangeNotifierProvider(create: (_) => AliasController()),
    if (historial != null) ChangeNotifierProvider.value(value: historial),
  ],
  child: MaterialApp(
    theme: AppTheme.oscuro,
    home: const Scaffold(body: FavoritosPantalla()),
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('muestra el estado vacío y cómo añadir favoritas', (
    tester,
  ) async {
    final controller = FavoritosController(api: ApiFalsa());
    await controller.cargar();

    await tester.pumpWidget(_pantalla(controller));
    await tester.pumpAndSettle();

    expect(find.text('Aún no tienes gasolineras favoritas'), findsOneWidget);
    expect(find.textContaining('corazón'), findsOneWidget);
  });

  testWidgets('muestra el precio vigente y la atribución', (tester) async {
    final controller = FavoritosController(
      api: ApiFalsa(
        detalles: {
          3194: const DetalleEstacion(productos: [_producto]),
        },
      ),
    );
    await controller.cargar();
    await controller.alternar(_gasolinera());

    await tester.pumpWidget(_pantalla(controller));
    await tester.pumpAndSettle();

    expect(find.text('Ballenoil Democracia'), findsOneWidget);
    expect(find.text('Gasolina 95 E5'), findsOneWidget);
    expect(find.text('1,729 €/L'), findsOneWidget);
    expect(
      find.text('Datos oficiales actualizados 2 veces al día'),
      findsOneWidget,
    );
  });

  testWidgets('muestra el pie con la fecha cuando la ficha trae meta', (
    tester,
  ) async {
    final controller = FavoritosController(
      api: ApiFalsa(
        detalles: {
          3194: DetalleEstacion(
            productos: const [_producto],
            meta: MetaDatos(
              atribucion: MetaDatos.atribucionPorDefecto,
              ultimaActualizacion: DateTime.utc(2026, 10, 9, 18, 10),
            ),
          ),
        },
      ),
    );
    await controller.cargar();
    await controller.alternar(_gasolinera());

    await tester.pumpWidget(_pantalla(controller));
    await tester.pumpAndSettle();

    expect(find.textContaining('Datos del'), findsOneWidget);
  });

  testWidgets('error de precio por favorito con reintento', (tester) async {
    final api = ApiFalsa(
      errores: {3194: const ApiException(mensaje: 'Sin conexión a internet.')},
    );
    final controller = FavoritosController(api: api);
    await controller.cargar();
    await controller.alternar(_gasolinera());

    await tester.pumpWidget(_pantalla(controller));
    await tester.pumpAndSettle();

    expect(find.text('Sin conexión a internet.'), findsOneWidget);
    expect(find.text('Ballenoil Democracia'), findsOneWidget);

    api
      ..errores.clear()
      ..detalles[3194] = const DetalleEstacion(productos: [_producto]);
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('1,729 €/L'), findsOneWidget);
    expect(find.text('Reintentar'), findsNothing);
  });

  testWidgets('marcar y desmarcar desde la tarjeta persiste entre cargas', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    final controller = FavoritosController(api: ApiFalsa());
    await controller.cargar();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: controller),
          ChangeNotifierProvider(create: (_) => AliasController()),
        ],
        child: MaterialApp(
          home: Scaffold(body: TarjetaGasolinera(gasolinera: _gasolinera())),
        ),
      ),
    );

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite), findsOneWidget);

    final recargado = FavoritosController();
    await recargado.cargar();
    expect(recargado.esFavorito(3194), isTrue);

    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    final vacio = FavoritosController();
    await vacio.cargar();
    expect(vacio.esFavorito(3194), isFalse);
  });

  testWidgets(
    'al marcar con la pantalla abierta aparece el precio sin recrearla',
    (tester) async {
      final controller = FavoritosController(
        api: ApiFalsa(
          detalles: {
            3194: const DetalleEstacion(productos: [_producto]),
          },
        ),
      );
      await controller.cargar();

      await tester.pumpWidget(_pantalla(controller));
      await tester.pumpAndSettle();
      expect(find.text('Aún no tienes gasolineras favoritas'), findsOneWidget);

      await controller.alternar(_gasolinera());
      await tester.pumpAndSettle();

      expect(find.text('Ballenoil Democracia'), findsOneWidget);
      expect(find.text('1,729 €/L'), findsOneWidget);
    },
  );

  testWidgets('si la consulta al marcar falla, avisa y permite reintentar', (
    tester,
  ) async {
    final api = ApiFalsa(
      errores: {3194: const ApiException(mensaje: 'Sin conexión a internet.')},
    );
    final controller = FavoritosController(api: api);
    await controller.cargar();

    await tester.pumpWidget(_pantalla(controller));
    await tester.pumpAndSettle();

    await controller.alternar(_gasolinera());
    await tester.pumpAndSettle();

    expect(find.text('Ballenoil Democracia'), findsOneWidget);
    expect(find.text('Sin conexión a internet.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);

    api
      ..errores.clear()
      ..detalles[3194] = const DetalleEstacion(productos: [_producto]);
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('1,729 €/L'), findsOneWidget);
    expect(find.text('Reintentar'), findsNothing);
  });

  testWidgets('muestra la flecha de tendencia en un favorito', (tester) async {
    final historial = HistorialController(api: ApiHistoricoFalsa());
    final controller = FavoritosController(
      api: ApiFalsa(
        detalles: {
          3194: const DetalleEstacion(productos: [_producto]),
        },
      ),
    );
    await controller.cargar();
    await controller.alternar(_gasolinera());

    await tester.pumpWidget(_pantalla(controller, historial: historial));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
  });

  testWidgets('arrastra el asa y persiste el nuevo orden', (tester) async {
    final controller = FavoritosController(api: ApiFalsa());
    await controller.cargar();
    await controller.alternar(_gasolinera(id: 1, nombre: 'Primera'));
    await controller.alternar(_gasolinera(id: 2, nombre: 'Segunda'));
    await controller.alternar(_gasolinera(id: 3, nombre: 'Tercera'));

    await tester.pumpWidget(_pantalla(controller));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.drag_handle), findsNWidgets(3));

    await tester.drag(
      find.byIcon(Icons.drag_handle).first,
      const Offset(0, 700),
    );
    await tester.pumpAndSettle();

    expect(controller.favoritos.map((favorito) => favorito.id), [2, 3, 1]);

    final recargado = FavoritosController(api: ApiFalsa());
    await recargado.cargar();
    expect(recargado.favoritos.map((favorito) => favorito.id), [2, 3, 1]);
  });

  testWidgets('con un solo favorito no muestra asa', (tester) async {
    final controller = FavoritosController(api: ApiFalsa());
    await controller.cargar();
    await controller.alternar(_gasolinera());

    await tester.pumpWidget(_pantalla(controller));
    await tester.pumpAndSettle();

    expect(find.text('Ballenoil Democracia'), findsOneWidget);
    expect(find.byIcon(Icons.drag_handle), findsNothing);
  });

  testWidgets('reordena con pulsación larga en la tarjeta', (tester) async {
    final controller = FavoritosController(api: ApiFalsa());
    await controller.cargar();
    await controller.alternar(_gasolinera(id: 1, nombre: 'Primera'));
    await controller.alternar(_gasolinera(id: 2, nombre: 'Segunda'));
    await controller.alternar(_gasolinera(id: 3, nombre: 'Tercera'));

    await tester.pumpWidget(_pantalla(controller));
    await tester.pumpAndSettle();

    final gesto = await tester.startGesture(
      tester.getCenter(find.text('Primera')),
    );
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
    await gesto.moveBy(const Offset(0, 700));
    await tester.pump();
    await gesto.up();
    await tester.pumpAndSettle();

    expect(controller.favoritos.map((favorito) => favorito.id), [2, 3, 1]);
  });

  testWidgets('muestra el aviso si falla el guardado del orden', (
    tester,
  ) async {
    final repositorio = RepositorioFalso(
      inicial: const [
        Favorito(id: 1, nombre: 'Primera', lat: 40.4, lng: -3.7),
        Favorito(id: 2, nombre: 'Segunda', lat: 40.5, lng: -3.8),
      ],
    )..fallarGuardado = true;
    final controller = FavoritosController(
      repositorio: repositorio,
      api: ApiFalsa(),
    );
    await controller.cargar();

    await tester.pumpWidget(_pantalla(controller));
    await tester.pumpAndSettle();

    await controller.mover(0, 1);
    await tester.pumpAndSettle();

    expect(
      find.text('No se pudieron guardar los favoritos en este dispositivo.'),
      findsOneWidget,
    );

    repositorio.fallarGuardado = false;
    await controller.mover(1, 0);
    await tester.pumpAndSettle();

    expect(
      find.text('No se pudieron guardar los favoritos en este dispositivo.'),
      findsNothing,
    );
  });

  testWidgets('muestra la progresión mientras carga el precio', (tester) async {
    final completer = Completer<DetalleEstacion>();
    final controller = FavoritosController(
      repositorio: RepositorioFalso(
        inicial: const [
          Favorito(id: 1, nombre: 'Primera', lat: 40.4, lng: -3.7),
        ],
      ),
      api: ApiLenta(completer),
    );
    await controller.cargar();

    await tester.pumpWidget(_pantalla(controller));
    await tester.pump();
    await tester.pump();

    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    completer.complete(const DetalleEstacion(productos: []));
    await tester.pumpAndSettle();

    expect(find.byType(LinearProgressIndicator), findsNothing);
  });
}
