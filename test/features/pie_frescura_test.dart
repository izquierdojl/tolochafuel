import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tolochafuel/app/theme/app_theme.dart';
import 'package:tolochafuel/core/models/meta_datos.dart';
import 'package:tolochafuel/features/cercanas/ui/widgets/pie_frescura.dart';

Widget _app(MetaDatos? meta) => MaterialApp(
  theme: AppTheme.oscuro,
  home: Scaffold(
    body: Column(
      children: [
        const Spacer(),
        PieFrescura(meta: meta),
      ],
    ),
  ),
);

void main() {
  testWidgets('muestra la fecha y la antigüedad', (tester) async {
    final meta = MetaDatos(
      atribucion: MetaDatos.atribucionPorDefecto,
      ultimaActualizacion: DateTime.utc(2026, 10, 9, 18, 10),
      antiguedadSegundos: 300,
    );

    await tester.pumpWidget(_app(meta));

    expect(find.textContaining('Datos del'), findsOneWidget);
    expect(find.textContaining('hace 5 min'), findsOneWidget);
  });

  testWidgets('sin fecha usa el texto genérico', (tester) async {
    await tester.pumpWidget(_app(null));

    expect(
      find.text('Datos oficiales actualizados 2 veces al día'),
      findsOneWidget,
    );
  });

  testWidgets('avisa cuando los datos son stale', (tester) async {
    final meta = MetaDatos(
      atribucion: MetaDatos.atribucionPorDefecto,
      ultimaActualizacion: DateTime.utc(2026, 10, 9, 18, 10),
      stale: true,
    );

    await tester.pumpWidget(_app(meta));

    expect(
      find.text('Pueden ser datos de la actualización anterior.'),
      findsOneWidget,
    );
  });
}
