import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tolochafuel/app/shell/seccion_app.dart';
import 'package:tolochafuel/features/configuracion/data/configuracion_repositorio.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('sin preferencias guardadas devuelve los valores por defecto', () async {
    final ajustes = await ConfiguracionRepositorio().cargar();

    expect(ajustes.temaOscuro, isTrue);
    expect(ajustes.radioKm, Ajustes.radioPorDefectoKm);
    expect(ajustes.pantallaInicial, SeccionApp.cercanas);
  });

  test('guarda y vuelve a cargar cada preferencia', () async {
    final repositorio = ConfiguracionRepositorio();
    await repositorio.guardar(
      const Ajustes(
        temaOscuro: false,
        radioKm: 40,
        pantallaInicial: SeccionApp.buscar,
      ),
    );

    final ajustes = await ConfiguracionRepositorio().cargar();

    expect(ajustes.temaOscuro, isFalse);
    expect(ajustes.radioKm, 40);
    expect(ajustes.pantallaInicial, SeccionApp.buscar);
  });

  test(
    'ignora valores inválidos y protege Configuración como inicial',
    () async {
      SharedPreferences.setMockInitialValues({
        ConfiguracionRepositorio.claveRadio: 200.0,
        ConfiguracionRepositorio.clavePantalla: 'configuracion',
        ConfiguracionRepositorio.claveTema: 'no es bool',
      });

      final ajustes = await ConfiguracionRepositorio().cargar();

      expect(ajustes.radioKm, Ajustes.radioPorDefectoKm);
      expect(ajustes.pantallaInicial, SeccionApp.cercanas);
      expect(ajustes.temaOscuro, isTrue);
    },
  );
}
