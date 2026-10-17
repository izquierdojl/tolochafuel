import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tolochafuel/app/theme/app_theme.dart';
import 'package:tolochafuel/core/api/api_client.dart';
import 'package:tolochafuel/core/api/precios_gasolina_api.dart';
import 'package:tolochafuel/core/models/gasolinera.dart';
import 'package:tolochafuel/core/models/historico_estacion.dart';
import 'package:tolochafuel/core/models/producto_precio.dart';
import 'package:tolochafuel/features/alias/data/alias_repositorio.dart';
import 'package:tolochafuel/features/alias/ui/alias_controller.dart';
import 'package:tolochafuel/features/cercanas/ui/historial_controller.dart';
import 'package:tolochafuel/features/cercanas/ui/widgets/detalle_historico.dart';
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

class AliasRepositorioFalso extends AliasRepositorio {
  AliasRepositorioFalso(this.inicial);

  final Map<int, String> inicial;

  @override
  Future<Map<int, String>> cargar() async => inicial;
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

HistoricoEstacion _historicoLargo() => HistoricoEstacion(
  series: [
    SerieCarburante(
      idApi: 'gasoline_95',
      puntos: [
        for (var i = 0; i < 62; i++)
          PuntoPrecio(
            fecha: DateTime(2026, 8, 17 + i),
            precio: 1.9 - 0.002 * i,
          ),
      ],
    ),
  ],
);

Finder _bloqueMedias() => find.byWidgetPredicate(
  (widget) =>
      widget is Semantics &&
      widget.properties.label == 'Ver gráfico de precios',
);

Widget _app(HistorialController historial, {AliasController? alias}) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: historial),
        ChangeNotifierProvider(create: (_) => FavoritosController()),
        ChangeNotifierProvider.value(value: alias ?? AliasController()),
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
    expect(find.text('Sin cambios en los últimos 90 días'), findsOneWidget);
    expect(find.text('Ver gráfico de precios'), findsNWidgets(3));
  });

  testWidgets('el modal marca cada cambio con su flecha de dirección', (
    tester,
  ) async {
    final historial = HistorialController(
      api: ApiHistoricoFalsa(resultado: _historico()),
    );

    await tester.pumpWidget(_app(historial));
    await tester.pumpAndSettle();

    await tester.tap(find.text('1,719 €/L'));
    await tester.pumpAndSettle();

    final colores = AppTheme.oscuro.extension<ColoresTendencia>()!;
    final modal = find.byType(DetalleHistorico);
    final abajo = tester.widget<Icon>(
      find.descendant(of: modal, matching: find.byIcon(Icons.arrow_downward)),
    );
    final arriba = tester.widget<Icon>(
      find.descendant(of: modal, matching: find.byIcon(Icons.arrow_upward)),
    );
    expect(abajo.color, colores.bajada);
    expect(arriba.color, colores.subida);
  });

  testWidgets(
    'las medias comparan con la ventana anterior y el gráfico se pliega',
    (tester) async {
      final historial = HistorialController(
        api: ApiHistoricoFalsa(resultado: _historicoLargo()),
      );

      await tester.pumpWidget(_app(historial));
      await tester.pumpAndSettle();

      await tester.tap(find.text('1,719 €/L'));
      await tester.pumpAndSettle();

      expect(find.text('Última semana'), findsOneWidget);
      expect(find.text('Último mes'), findsOneWidget);

      final bloque = find.ancestor(
        of: find.text('Última semana'),
        matching: _bloqueMedias(),
      );
      expect(bloque, findsOneWidget);
      expect(
        find.descendant(of: bloque, matching: find.text('1,784 €/L')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: bloque, matching: find.text('1,807 €/L')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: bloque,
          matching: find.byIcon(Icons.arrow_downward),
        ),
        findsNWidgets(2),
      );

      expect(find.byType(LineChart), findsNothing);
      await tester.tap(find.text('Última semana'));
      await tester.pumpAndSettle();
      expect(find.byType(LineChart), findsOneWidget);
      expect(find.byIcon(Icons.expand_less), findsOneWidget);

      await tester.tap(find.text('Última semana'));
      await tester.pumpAndSettle();
      expect(find.byType(LineChart), findsNothing);
    },
  );

  testWidgets('sin ventana anterior la media aparece sin flecha', (
    tester,
  ) async {
    final historial = HistorialController(
      api: ApiHistoricoFalsa(
        resultado: HistoricoEstacion(
          series: [
            SerieCarburante(
              idApi: 'gasoline_95',
              puntos: [
                for (var i = 0; i < 10; i++)
                  PuntoPrecio(fecha: DateTime(2026, 10, 1 + i), precio: 1.700),
              ],
            ),
          ],
        ),
      ),
    );

    await tester.pumpWidget(_app(historial));
    await tester.pumpAndSettle();

    await tester.tap(find.text('1,719 €/L'));
    await tester.pumpAndSettle();

    expect(find.text('Última semana'), findsOneWidget);
    final bloque = find.ancestor(
      of: find.text('Última semana'),
      matching: _bloqueMedias(),
    );
    expect(find.text('1,700 €/L'), findsOneWidget);
    expect(find.text('Último mes'), findsNothing);
    expect(
      find.descendant(of: bloque, matching: find.byIcon(Icons.arrow_downward)),
      findsNothing,
    );
    expect(
      find.descendant(of: bloque, matching: find.byIcon(Icons.arrow_upward)),
      findsNothing,
    );
  });

  testWidgets('una serie plana muestra medias iguales', (tester) async {
    final historial = HistorialController(
      api: ApiHistoricoFalsa(
        resultado: HistoricoEstacion(
          series: [
            SerieCarburante(
              idApi: 'gasoline_95',
              puntos: [
                for (var i = 0; i < 60; i++)
                  PuntoPrecio(fecha: DateTime(2026, 8, 19 + i), precio: 1.729),
              ],
            ),
          ],
        ),
      ),
    );

    await tester.pumpWidget(_app(historial));
    await tester.pumpAndSettle();

    await tester.tap(find.text('1,719 €/L'));
    await tester.pumpAndSettle();

    expect(find.text('Última semana'), findsOneWidget);
    expect(find.text('Último mes'), findsOneWidget);
    final bloque = find.ancestor(
      of: find.text('Última semana'),
      matching: _bloqueMedias(),
    );
    expect(
      find.descendant(of: bloque, matching: find.text('=')),
      findsNWidgets(2),
    );
  });

  testWidgets('con un solo registro no se ofrece el gráfico', (tester) async {
    final historial = HistorialController(
      api: ApiHistoricoFalsa(
        resultado: HistoricoEstacion(
          series: [
            SerieCarburante(
              idApi: 'gasoline_95',
              puntos: [
                PuntoPrecio(fecha: DateTime(2026, 10, 10), precio: 1.719),
              ],
            ),
          ],
        ),
      ),
    );

    await tester.pumpWidget(_app(historial));
    await tester.pumpAndSettle();

    await tester.tap(find.text('1,719 €/L'));
    await tester.pumpAndSettle();

    expect(find.text('Sin cambios en los últimos 90 días'), findsOneWidget);
    expect(find.text('Ver gráfico de precios'), findsNothing);
    expect(find.byIcon(Icons.expand_more), findsNothing);
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

  testWidgets('el encabezado del histórico usa el alias cuando existe', (
    tester,
  ) async {
    final historial = HistorialController(
      api: ApiHistoricoFalsa(resultado: _historico()),
    );
    final alias = AliasController(
      repositorio: AliasRepositorioFalso(const {3213: 'La de la rotonda'}),
    );
    await alias.cargar();

    await tester.pumpWidget(_app(historial, alias: alias));
    await tester.pumpAndSettle();

    await tester.tap(find.text('1,719 €/L'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(DetalleHistorico),
        matching: find.text('La de la rotonda'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('sin alias el encabezado del histórico usa el nombre de la API', (
    tester,
  ) async {
    final historial = HistorialController(
      api: ApiHistoricoFalsa(resultado: _historico()),
    );

    await tester.pumpWidget(_app(historial));
    await tester.pumpAndSettle();

    await tester.tap(find.text('1,719 €/L'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(DetalleHistorico),
        matching: find.text('Ballenoil Segovia'),
      ),
      findsOneWidget,
    );
  });
}
