import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tolochafuel/features/alias/ui/alias_controller.dart';
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
      repositorio: RepositorioFalso(
        inicial: const Ajustes(tema: ThemeMode.light),
      ),
    );
    await configuracion.cargar();

    await tester.pumpWidget(
      TolochaFuelApp(
        favoritos: FavoritosController(),
        configuracion: configuracion,
        alias: AliasController(),
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
        alias: AliasController(),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.system,
    );

    await configuracion.cambiarTema(ThemeMode.dark);
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );

    await configuracion.cambiarTema(ThemeMode.light);
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
  });

  Brightness brilloActual(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(Scaffold).first)).brightness;

  testWidgets('con Sistema la app sigue el brillo de la plataforma', (
    tester,
  ) async {
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    final configuracion = ConfiguracionController(
      repositorio: RepositorioFalso(),
    );
    await configuracion.cargar();

    await tester.pumpWidget(
      TolochaFuelApp(
        favoritos: FavoritosController(),
        configuracion: configuracion,
        alias: AliasController(),
      ),
    );
    await tester.pumpAndSettle();
    expect(brilloActual(tester), Brightness.dark);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await tester.pumpAndSettle();
    expect(brilloActual(tester), Brightness.light);
  });

  testWidgets('con Claro u Oscuro la app ignora el brillo de la plataforma', (
    tester,
  ) async {
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    final configuracion = ConfiguracionController(
      repositorio: RepositorioFalso(
        inicial: const Ajustes(tema: ThemeMode.light),
      ),
    );
    await configuracion.cargar();

    await tester.pumpWidget(
      TolochaFuelApp(
        favoritos: FavoritosController(),
        configuracion: configuracion,
        alias: AliasController(),
      ),
    );
    await tester.pumpAndSettle();
    expect(brilloActual(tester), Brightness.light);

    await configuracion.cambiarTema(ThemeMode.dark);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await tester.pumpAndSettle();
    expect(brilloActual(tester), Brightness.dark);
  });
}
