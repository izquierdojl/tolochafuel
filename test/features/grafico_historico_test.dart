import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tolochafuel/app/theme/app_theme.dart';
import 'package:tolochafuel/core/models/historico_estacion.dart';
import 'package:tolochafuel/features/cercanas/ui/widgets/grafico_historico.dart';

Widget _app(Widget hijo) => MaterialApp(
  theme: AppTheme.oscuro,
  home: Scaffold(body: hijo),
);

void main() {
  test('el tooltip muestra fecha y precio en la unidad del producto', () {
    final texto = textoPunto(
      PuntoPrecio(fecha: DateTime(2026, 10, 10), precio: 1.719),
      'L',
    );

    expect(texto, '10/10/2026\n1,719 €/L');
  });

  testWidgets('una serie plana larga se pinta con una sola media', (
    tester,
  ) async {
    final serie = SerieCarburante(
      idApi: 'gasoline_95',
      puntos: [
        for (var i = 0; i < 31; i++)
          PuntoPrecio(fecha: DateTime(2026, 9, 17 + i), precio: 1.7),
      ],
    );

    await tester.pumpWidget(_app(GraficoHistorico(serie: serie, unidad: 'L')));
    await tester.pumpAndSettle();

    expect(find.byType(LineChart), findsOneWidget);
  });

  testWidgets('una serie corta de dos puntos se pinta sin medias', (
    tester,
  ) async {
    final serie = SerieCarburante(
      idApi: 'gasoline_95',
      puntos: [
        PuntoPrecio(fecha: DateTime(2026, 10, 9), precio: 1.729),
        PuntoPrecio(fecha: DateTime(2026, 10, 10), precio: 1.719),
      ],
    );

    await tester.pumpWidget(_app(GraficoHistorico(serie: serie, unidad: 'L')));
    await tester.pumpAndSettle();

    expect(find.byType(LineChart), findsOneWidget);
  });
}
