import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tolochafuel/app/theme/app_theme.dart';
import 'package:tolochafuel/core/api/api_client.dart';
import 'package:tolochafuel/core/api/precios_gasolina_api.dart';
import 'package:tolochafuel/core/models/gasolinera.dart';
import 'package:tolochafuel/core/models/historico_estacion.dart';
import 'package:tolochafuel/core/models/producto_precio.dart';
import 'package:tolochafuel/features/cercanas/ui/historial_controller.dart';
import 'package:tolochafuel/features/cercanas/ui/widgets/tarjeta_gasolinera.dart';
import 'package:tolochafuel/features/favoritos/ui/favoritos_controller.dart';

class ApiHistoricoFalsa extends PreciosGasolinaApi {
  ApiHistoricoFalsa({this.resultado, this.error, this.completer});

  HistoricoEstacion? resultado;
  Object? error;
  Completer<HistoricoEstacion>? completer;

  @override
  Future<HistoricoEstacion> historico(int id, {int days = 5}) {
    final pendiente = completer;
    if (pendiente != null) return pendiente.future;
    final fallo = error;
    if (fallo != null) return Future.error(fallo);
    return Future.value(resultado ?? const HistoricoEstacion(series: []));
  }
}

const _gasolina95 = ProductoPrecio(
  idApi: 'gasoline_95',
  etiqueta: 'Gasolina 95 E5',
  unidad: 'L',
  precio: 1.719,
);
const _diesel = ProductoPrecio(
  idApi: 'diesel',
  etiqueta: 'Gasóleo A (diésel)',
  unidad: 'L',
  precio: 1.869,
);
const _premium = ProductoPrecio(
  idApi: 'diesel_premium',
  etiqueta: 'Gasóleo premium',
  unidad: 'L',
  precio: 1.879,
);

Gasolinera _gasolinera() => const Gasolinera(
  id: 3213,
  nombre: 'Ballenoil Segovia',
  lat: 40.41,
  lng: -3.71,
  urlWeb: '',
  productos: [_gasolina95, _diesel, _premium],
);

HistoricoEstacion _historico() => HistoricoEstacion(
  series: [
    SerieCarburante(
      idApi: 'gasoline_95',
      puntos: [
        PuntoPrecio(fecha: DateTime(2026, 10, 9), precio: 1.729),
        PuntoPrecio(fecha: DateTime(2026, 10, 10), precio: 1.719),
      ],
    ),
    SerieCarburante(
      idApi: 'diesel',
      puntos: [
        PuntoPrecio(fecha: DateTime(2026, 10, 9), precio: 1.859),
        PuntoPrecio(fecha: DateTime(2026, 10, 10), precio: 1.869),
      ],
    ),
    SerieCarburante(
      idApi: 'diesel_premium',
      puntos: [
        PuntoPrecio(fecha: DateTime(2026, 10, 9), precio: 1.879),
        PuntoPrecio(fecha: DateTime(2026, 10, 10), precio: 1.879),
      ],
    ),
  ],
);

Widget _app(HistorialController historial) => MultiProvider(
  providers: [
    ChangeNotifierProvider.value(value: historial),
    ChangeNotifierProvider(create: (_) => FavoritosController()),
  ],
  child: MaterialApp(
    theme: AppTheme.oscuro,
    home: Scaffold(body: TarjetaGasolinera(gasolinera: _gasolinera())),
  ),
);

void main() {
  testWidgets('flecha de bajada verde, subida roja y neutra si igual', (
    tester,
  ) async {
    final historial = HistorialController(
      api: ApiHistoricoFalsa(resultado: _historico()),
    );

    await tester.pumpWidget(_app(historial));
    await tester.pumpAndSettle();

    final colores = AppTheme.oscuro.extension<ColoresTendencia>()!;
    final abajo = tester.widget<Icon>(find.byIcon(Icons.arrow_downward));
    expect(abajo.color, colores.bajada);
    final arriba = tester.widget<Icon>(find.byIcon(Icons.arrow_upward));
    expect(arriba.color, colores.subida);
    expect(find.text('='), findsOneWidget);
  });

  testWidgets('sin histórico no muestra flechas', (tester) async {
    final historial = HistorialController(api: ApiHistoricoFalsa());

    await tester.pumpWidget(_app(historial));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_downward), findsNothing);
    expect(find.byIcon(Icons.arrow_upward), findsNothing);
    expect(find.text('='), findsNothing);
  });

  testWidgets('al pulsar el precio abre el modal con los últimos precios', (
    tester,
  ) async {
    final historial = HistorialController(
      api: ApiHistoricoFalsa(resultado: _historico()),
    );

    await tester.pumpWidget(_app(historial));
    await tester.pumpAndSettle();

    await tester.tap(find.text('1,719 €/L'));
    await tester.pumpAndSettle();

    expect(find.text('Últimos cambios de precio (90 días)'), findsOneWidget);
    expect(find.text('Gasolina 95 E5'), findsWidgets);
    expect(find.text('10/10/2026'), findsWidgets);
    expect(find.text('09/10/2026'), findsNothing);
    expect(find.text('Baja 0,010 €/L desde el 10/10/2026'), findsOneWidget);
    expect(find.text('Sube 0,010 €/L desde el 10/10/2026'), findsOneWidget);
    expect(find.text('Sin cambios en los últimos 90 días'), findsOneWidget);
  });

  testWidgets('muestra la flecha aunque los últimos días estén planos', (
    tester,
  ) async {
    final historial = HistorialController(
      api: ApiHistoricoFalsa(
        resultado: HistoricoEstacion(
          series: [
            SerieCarburante(
              idApi: 'gasoline_95',
              puntos: [
                PuntoPrecio(fecha: DateTime(2026, 10, 6), precio: 1.709),
                PuntoPrecio(fecha: DateTime(2026, 10, 7), precio: 1.679),
                PuntoPrecio(fecha: DateTime(2026, 10, 8), precio: 1.679),
                PuntoPrecio(fecha: DateTime(2026, 10, 9), precio: 1.679),
                PuntoPrecio(fecha: DateTime(2026, 10, 10), precio: 1.679),
              ],
            ),
          ],
        ),
      ),
    );

    await tester.pumpWidget(_app(historial));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
  });

  testWidgets('el modal muestra carga mientras llega el histórico', (
    tester,
  ) async {
    final completer = Completer<HistoricoEstacion>();
    final historial = HistorialController(
      api: ApiHistoricoFalsa(completer: completer),
    );

    await tester.pumpWidget(_app(historial));
    await tester.pump();

    await tester.tap(find.text('1,719 €/L'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Últimos cambios de precio (90 días)'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(_historico());
    await tester.pumpAndSettle();

    expect(find.text('10/10/2026'), findsWidgets);
  });

  testWidgets('el modal muestra error con reintento', (tester) async {
    final api = ApiHistoricoFalsa(
      error: const ApiException(mensaje: 'Sin conexión.'),
    );
    final historial = HistorialController(api: api);

    await tester.pumpWidget(_app(historial));
    await tester.pumpAndSettle();

    await tester.tap(find.text('1,719 €/L'));
    await tester.pumpAndSettle();

    expect(find.text('Sin conexión.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);

    api
      ..error = null
      ..resultado = _historico();
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('10/10/2026'), findsWidgets);
  });

  testWidgets('el modal avisa cuando no hay histórico', (tester) async {
    final historial = HistorialController(api: ApiHistoricoFalsa());

    await tester.pumpWidget(_app(historial));
    await tester.pumpAndSettle();

    await tester.tap(find.text('1,719 €/L'));
    await tester.pumpAndSettle();

    expect(
      find.text('No hay histórico disponible para esta estación.'),
      findsOneWidget,
    );
  });
}
