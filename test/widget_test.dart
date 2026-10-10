import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tolochafuel/features/configuracion/ui/configuracion_controller.dart';
import 'package:tolochafuel/features/favoritos/ui/favoritos_controller.dart';
import 'package:tolochafuel/main.dart';

void main() {
  testWidgets('la app arranca y muestra la pantalla principal', (tester) async {
    await tester.pumpWidget(
      TolochaFuelApp(
        favoritos: FavoritosController(),
        configuracion: ConfiguracionController(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('TolochaFuel'), findsOneWidget);
  });

  testWidgets('la cabecera muestra el emblema Tolocha y la marca', (
    tester,
  ) async {
    await tester.pumpWidget(
      TolochaFuelApp(
        favoritos: FavoritosController(),
        configuracion: ConfiguracionController(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.text('TolochaFuel'), findsOneWidget);
  });
}
