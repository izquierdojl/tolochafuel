import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tolochafuel/core/api/api_client.dart';
import 'package:tolochafuel/core/api/precios_gasolina_api.dart';
import 'package:tolochafuel/core/models/detalle_estacion.dart';
import 'package:tolochafuel/core/models/gasolinera.dart';
import 'package:tolochafuel/core/models/producto_precio.dart';
import 'package:tolochafuel/features/cercanas/ui/widgets/tarjeta_gasolinera.dart';
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

const _producto = ProductoPrecio(
  idApi: 'gasoline_95',
  etiqueta: 'Gasolina 95 E5',
  unidad: 'L',
  precio: 1.729,
);

Gasolinera _gasolinera() => const Gasolinera(
  id: 3194,
  nombre: 'Ballenoil Democracia',
  lat: 40.4,
  lng: -3.61,
  urlWeb: '',
  direccion: 'Calle Democracia, 12',
);

Widget _pantalla(FavoritosController controller) =>
    ChangeNotifierProvider.value(
      value: controller,
      child: const MaterialApp(home: Scaffold(body: FavoritosPantalla())),
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
    expect(find.textContaining('Gasolina hoy'), findsOneWidget);
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
    expect(find.textContaining('Gasolina hoy'), findsOneWidget);
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

    final controller = FavoritosController();
    await controller.cargar();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
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
}
