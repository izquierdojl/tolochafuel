import 'package:flutter_test/flutter_test.dart';
import 'package:tolochafuel/app/theme/app_theme.dart';

void main() {
  test('los temas claro y oscuro exponen los colores de tendencia', () {
    for (final tema in [AppTheme.claro, AppTheme.oscuro]) {
      final colores = tema.extension<ColoresTendencia>();
      expect(colores, isNotNull);
      expect(colores!.bajada, isNot(colores.subida));
      expect(colores.neutra, isNot(colores.bajada));
    }
  });
}
