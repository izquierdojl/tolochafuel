import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tolochafuel/app/shell/seccion_app.dart';
import 'package:tolochafuel/core/models/meta_datos.dart';
import 'package:tolochafuel/features/configuracion/data/configuracion_repositorio.dart';
import 'package:tolochafuel/features/configuracion/ui/acerca_de_pantalla.dart';
import 'package:tolochafuel/features/configuracion/ui/configuracion_controller.dart';
import 'package:tolochafuel/features/configuracion/ui/configuracion_pantalla.dart';

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

Widget _pantalla(ConfiguracionController controller) =>
    ChangeNotifierProvider.value(
      value: controller,
      child: const MaterialApp(home: Scaffold(body: ConfiguracionPantalla())),
    );

void main() {
  testWidgets('cambia el tema al instante y lo persiste', (tester) async {
    final repositorio = RepositorioFalso();
    final controller = ConfiguracionController(repositorio: repositorio);
    await controller.cargar();

    await tester.pumpWidget(_pantalla(controller));
    await tester.pumpAndSettle();
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isTrue,
    );

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(controller.temaOscuro, isFalse);
    expect(repositorio.guardados!.temaOscuro, isFalse);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );
  });

  testWidgets('el radio va de 10 a 50 km con nota del máximo de la API', (
    tester,
  ) async {
    final controller = ConfiguracionController(repositorio: RepositorioFalso());
    await controller.cargar();

    await tester.pumpWidget(_pantalla(controller));
    await tester.pumpAndSettle();

    final slider = tester.widget<Slider>(find.byType(Slider));
    expect(slider.min, Ajustes.radioMinimoKm);
    expect(slider.max, Ajustes.radioMaximoKm);
    expect(find.text('Radio de búsqueda: 25 km'), findsOneWidget);
    expect(find.textContaining('máximo que permite la API'), findsOneWidget);

    await controller.cambiarRadio(40);
    await tester.pumpAndSettle();
    expect(find.text('Radio de búsqueda: 40 km'), findsOneWidget);
  });

  testWidgets('elige la pantalla inicial sin ofrecer Configuración', (
    tester,
  ) async {
    final repositorio = RepositorioFalso();
    final controller = ConfiguracionController(repositorio: repositorio);
    await controller.cargar();

    await tester.pumpWidget(_pantalla(controller));
    await tester.pumpAndSettle();
    expect(find.text('Cercanas'), findsOneWidget);

    await tester.tap(find.byType(DropdownButton<SeccionApp>));
    await tester.pumpAndSettle();
    expect(find.text('Configuración'), findsNothing);

    await tester.tap(find.text('Buscar').last);
    await tester.pumpAndSettle();

    expect(controller.pantallaInicial, SeccionApp.buscar);
    expect(repositorio.guardados!.pantallaInicial, SeccionApp.buscar);
    expect(find.text('Buscar'), findsOneWidget);
  });

  testWidgets('Acerca de muestra atribución y licencia CC BY 4.0', (
    tester,
  ) async {
    final controller = ConfiguracionController(repositorio: RepositorioFalso());
    await controller.cargar();

    await tester.pumpWidget(_pantalla(controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Acerca de…'));
    await tester.pumpAndSettle();

    expect(find.byType(AcercaDePantalla), findsOneWidget);
    expect(find.text('TolochaFuel'), findsOneWidget);
    expect(find.textContaining('Ministerio'), findsWidgets);
    expect(find.text(MetaDatos.atribucionPorDefecto), findsOneWidget);
    expect(find.textContaining('CC BY 4.0'), findsOneWidget);
    expect(find.text('Código en GitHub'), findsOneWidget);
  });
}
