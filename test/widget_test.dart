import 'package:flutter_test/flutter_test.dart';
import 'package:tolochafuel/main.dart';

void main() {
  testWidgets('la app arranca y muestra la pantalla principal', (tester) async {
    await tester.pumpWidget(const TolochaFuelApp());
    await tester.pumpAndSettle();
    expect(find.text('TolochaFuel'), findsOneWidget);
  });
}
