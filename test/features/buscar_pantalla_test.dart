import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tolochafuel/core/api/api_client.dart';
import 'package:tolochafuel/core/api/precios_gasolina_api.dart';
import 'package:tolochafuel/core/models/gasolinera.dart';
import 'package:tolochafuel/core/models/lugar.dart';
import 'package:tolochafuel/core/models/meta_datos.dart';
import 'package:tolochafuel/core/models/producto_precio.dart';
import 'package:tolochafuel/features/cercanas/data/cercanas_repositorio.dart';
import 'package:tolochafuel/features/cercanas/ui/buscar_controller.dart';
import 'package:tolochafuel/features/cercanas/ui/buscar_pantalla.dart';
import 'package:tolochafuel/features/favoritos/ui/favoritos_controller.dart';

class RepositorioFalso extends CercanasRepositorio {
  List<Lugar> lugares = const [];
  ResultadoGasolineras? territorio;
  Object? errorBuscar;
  Object? errorTerritorio;
  int busquedas = 0;
  int territorios = 0;

  @override
  Future<List<Lugar>> buscarLugar(String consulta) async {
    busquedas++;
    final fallo = errorBuscar;
    if (fallo != null) throw fallo;
    return lugares;
  }

  @override
  Future<ResultadoGasolineras> masBaratas({required Lugar lugar}) async {
    territorios++;
    final fallo = errorTerritorio;
    if (fallo != null) throw fallo;
    return territorio!;
  }
}

const _madrid = Lugar(
  nombre: 'Madrid',
  nivel: 'municipality',
  codigo: '4354',
  detalle: 'Comunidad de Madrid',
);

ResultadoGasolineras _resultado() => ResultadoGasolineras(
  gasolineras: const [
    Gasolinera(
      id: 3194,
      nombre: 'Ballenoil Democracia',
      lat: 40.4,
      lng: -3.61,
      urlWeb: '',
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
  meta: MetaDatos(atribucion: MetaDatos.atribucionPorDefecto),
);

Widget _pantalla(BuscarController controller) => MultiProvider(
  providers: [
    ChangeNotifierProvider.value(value: controller),
    ChangeNotifierProvider(create: (_) => FavoritosController()),
  ],
  child: const MaterialApp(home: Scaffold(body: BuscarPantalla())),
);

void main() {
  test('buscarLugar guarda coincidencias y avisa si no hay ninguna', () async {
    final repositorio = RepositorioFalso()..lugares = const [_madrid];
    final controller = BuscarController(repositorio: repositorio);

    await controller.buscarLugar('madrid');
    expect(controller.resultadosBusqueda.single.nombre, 'Madrid');
    expect(controller.errorBusqueda, isNull);

    repositorio.lugares = const [];
    await controller.buscarLugar('inexistente');
    expect(controller.resultadosBusqueda, isEmpty);
    expect(controller.errorBusqueda, contains('No se han encontrado'));
  });

  test('buscarLugar traduce el error de la API', () async {
    final repositorio = RepositorioFalso()
      ..errorBuscar = const ApiException(mensaje: 'Sin conexión.');
    final controller = BuscarController(repositorio: repositorio);

    await controller.buscarLugar('madrid');

    expect(controller.errorBusqueda, 'Sin conexión.');
  });

  testWidgets('busca un municipio y carga sus gasolineras más baratas', (
    tester,
  ) async {
    final repositorio = RepositorioFalso()
      ..lugares = const [_madrid]
      ..territorio = _resultado();
    final controller = BuscarController(repositorio: repositorio);

    await tester.pumpWidget(_pantalla(controller));
    await tester.pumpAndSettle();

    expect(find.text('Municipio o provincia'), findsOneWidget);
    expect(find.text('Buscar'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'madrid');
    await tester.tap(find.text('Buscar'));
    await tester.pumpAndSettle();

    expect(find.text('Selecciona dónde buscar:'), findsOneWidget);
    await tester.tap(find.text('Madrid'));
    await tester.pumpAndSettle();

    expect(find.text('Más baratas en Madrid'), findsOneWidget);
    expect(find.text('Orden por Gasolina 95'), findsOneWidget);
    expect(find.text('Ballenoil Democracia'), findsOneWidget);
    expect(find.text('1,729 €/L'), findsOneWidget);
  });

  testWidgets('muestra el aviso cuando no hay coincidencias', (tester) async {
    final repositorio = RepositorioFalso();
    final controller = BuscarController(repositorio: repositorio);

    await tester.pumpWidget(_pantalla(controller));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'inexistente');
    await tester.tap(find.text('Buscar'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('No se han encontrado municipios'),
      findsOneWidget,
    );
  });

  testWidgets('error del territorio con reintento', (tester) async {
    final repositorio = RepositorioFalso()
      ..errorTerritorio = const ApiException(mensaje: 'Sin conexión.');

    final controller = BuscarController(repositorio: repositorio);

    await controller.elegirLugar(_madrid);
    await tester.pumpWidget(_pantalla(controller));
    await tester.pumpAndSettle();

    expect(find.text('Sin conexión.'), findsOneWidget);

    repositorio
      ..errorTerritorio = null
      ..territorio = _resultado();
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('Ballenoil Democracia'), findsOneWidget);
    expect(repositorio.territorios, 2);
  });
}
