import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tolochafuel/features/configuracion/data/configuracion_repositorio.dart';
import 'package:tolochafuel/features/configuracion/ui/configuracion_controller.dart';
import 'package:tolochafuel/features/favoritos/ui/favoritos_controller.dart';
import 'package:tolochafuel/main.dart';

class RepositorioFalso extends ConfiguracionRepositorio {
  RepositorioFalso({this.inicial = const Ajustes()});

  Ajustes inicial;
  Ajustes? guardados;

  @override
  Future<Ajustes> cargar() async => inicial;

  @override
  Future<void> guardar(Ajustes ajustes) async {
    guardados = ajustes;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('la app arranca con el tema guardado (claro)', (tester) async {
    final configuracion = ConfiguracionController(
      repositorio: RepositorioFalso(inicial: const Ajustes(temaOscuro: false)),
    );
    await configuracion.cargar();

    await tester.pumpWidget(
      TolochaFuelApp(
        favoritos: FavoritosController(),
        configuracion: configuracion,
      ),
    );
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.light);
  });

  testWidgets('el tema cambia al instante desde el controlador', (
    tester,
  ) async {
    final configuracion = ConfiguracionController(
      repositorio: RepositorioFalso(),
    );
    await configuracion.cargar();

    await tester.pumpWidget(
      TolochaFuelApp(
        favoritos: FavoritosController(),
        configuracion: configuracion,
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );

    await configuracion.cambiarTema(oscuro: false);
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
  });
}
