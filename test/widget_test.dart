import 'package:flutter_test/flutter_test.dart';
import 'package:tolochafuel/main.dart';

void main() {
  testWidgets('la pantalla inicial muestra el título TolochaFuel', (
    tester,
  ) async {
    await tester.pumpWidget(const TolochaFuelApp());
    expect(find.text('TolochaFuel'), findsOneWidget);
  });
}
