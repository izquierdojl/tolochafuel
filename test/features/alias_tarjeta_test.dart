import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tolochafuel/app/theme/app_theme.dart';
import 'package:tolochafuel/core/models/gasolinera.dart';
import 'package:tolochafuel/core/models/producto_precio.dart';
import 'package:tolochafuel/features/alias/data/alias_repositorio.dart';
import 'package:tolochafuel/features/alias/ui/alias_controller.dart';
import 'package:tolochafuel/features/cercanas/ui/widgets/tarjeta_gasolinera.dart';
import 'package:tolochafuel/features/favoritos/ui/favoritos_controller.dart';

class RepositorioFalso extends AliasRepositorio {
  RepositorioFalso({this.inicial = const {}, this.fallarGuardado = false});

  Map<int, String> inicial;
  bool fallarGuardado;
  Map<int, String>? guardados;

  @override
  Future<Map<int, String>> cargar() async => inicial;

  @override
  Future<void> guardar(Map<int, String> alias) async {
    if (fallarGuardado) throw Exception('fallo de guardado');
    guardados = {...alias};
  }

  @override
  Future<void> quitar(int id) async {
    if (fallarGuardado) throw Exception('fallo de borrado');
  }
}

const _gasolina95 = ProductoPrecio(
  idApi: 'gasoline_95',
  etiqueta: 'Gasolina 95 E5',
  unidad: 'L',
  precio: 1.719,
);

Gasolinera _gasolinera({String nombre = 'REPSOL'}) => Gasolinera(
  id: 3194,
  nombre: nombre,
  lat: 40.41,
  lng: -3.71,
  urlWeb: '',
  direccion: 'Calle Mayor, 1',
  municipio: 'Segovia',
  productos: const [_gasolina95],
);

Widget _app(AliasController alias, Gasolinera gasolinera) => MultiProvider(
  providers: [
    ChangeNotifierProvider.value(value: alias),
    ChangeNotifierProvider(create: (_) => FavoritosController()),
  ],
  child: MaterialApp(
    theme: AppTheme.oscuro,
    home: Scaffold(body: TarjetaGasolinera(gasolinera: gasolinera)),
  ),
);

Future<AliasController> _controller({
  Map<int, String> inicial = const {},
  bool fallarGuardado = false,
}) async {
  final controller = AliasController(
    repositorio: RepositorioFalso(
      inicial: inicial,
      fallarGuardado: fallarGuardado,
    ),
  );
  await controller.cargar();
  return controller;
}

void main() {
  testWidgets('sin alias muestra el rótulo de la API', (tester) async {
    final controller = await _controller();

    await tester.pumpWidget(_app(controller, _gasolinera()));
    await tester.pumpAndSettle();

    expect(find.text('REPSOL'), findsOneWidget);
    expect(find.text('Calle Mayor, 1 · Segovia'), findsOneWidget);
  });

  testWidgets('con alias el título es el alias y el rótulo sigue visible', (
    tester,
  ) async {
    final controller = await _controller(
      inicial: const {3194: 'La de la rotonda'},
    );

    await tester.pumpWidget(_app(controller, _gasolinera()));
    await tester.pumpAndSettle();

    expect(find.text('La de la rotonda'), findsOneWidget);
    expect(find.text('REPSOL · Calle Mayor, 1 · Segovia'), findsOneWidget);
  });

  testWidgets('si el alias coincide con el rótulo no se duplica', (
    tester,
  ) async {
    final controller = await _controller(inicial: const {3194: 'REPSOL'});

    await tester.pumpWidget(_app(controller, _gasolinera()));
    await tester.pumpAndSettle();

    expect(find.text('REPSOL'), findsOneWidget);
    expect(find.text('Calle Mayor, 1 · Segovia'), findsOneWidget);
  });

  testWidgets('una estación sin rótulo con alias no muestra «Sin rótulo»', (
    tester,
  ) async {
    final controller = await _controller(
      inicial: const {3194: 'La del polígono'},
    );

    await tester.pumpWidget(
      _app(controller, _gasolinera(nombre: 'Sin rótulo')),
    );
    await tester.pumpAndSettle();

    expect(find.text('La del polígono'), findsOneWidget);
    expect(find.text('Sin rótulo'), findsNothing);
    expect(find.text('Calle Mayor, 1 · Segovia'), findsOneWidget);
  });

  testWidgets('el menú permite poner un alias', (tester) async {
    final controller = await _controller();

    await tester.pumpWidget(_app(controller, _gasolinera()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    expect(find.text('Poner alias…'), findsOneWidget);

    await tester.tap(find.text('Poner alias…'));
    await tester.pumpAndSettle();
    expect(find.text('Sustituye a: REPSOL'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'La de la rotonda');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('La de la rotonda'), findsOneWidget);
    expect(find.text('REPSOL · Calle Mayor, 1 · Segovia'), findsOneWidget);
  });

  testWidgets('con alias el menú permite editarlo o quitarlo', (tester) async {
    final controller = await _controller(
      inicial: const {3194: 'La de la rotonda'},
    );

    await tester.pumpWidget(_app(controller, _gasolinera()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    expect(find.text('Editar alias…'), findsOneWidget);

    await tester.tap(find.text('Editar alias…'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quitar alias'));
    await tester.pumpAndSettle();

    expect(find.text('REPSOL'), findsOneWidget);
    expect(find.text('Calle Mayor, 1 · Segovia'), findsOneWidget);
  });

  testWidgets('si falla el guardado avisa y mantiene el alias en la sesión', (
    tester,
  ) async {
    final controller = await _controller(fallarGuardado: true);

    await tester.pumpWidget(_app(controller, _gasolinera()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Poner alias…'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'La de la rotonda');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(
      find.text('No se pudo guardar el alias en este dispositivo.'),
      findsOneWidget,
    );
    expect(find.text('La de la rotonda'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });
}
