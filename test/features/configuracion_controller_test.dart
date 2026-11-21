import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tolochafuel/app/shell/seccion_app.dart';
import 'package:tolochafuel/core/models/criterio_economicas.dart';
import 'package:tolochafuel/features/configuracion/data/configuracion_repositorio.dart';
import 'package:tolochafuel/features/configuracion/ui/configuracion_controller.dart';

class RepositorioFalso extends ConfiguracionRepositorio {
  RepositorioFalso({this.inicial = const Ajustes()});

  Ajustes inicial;
  Ajustes? guardados;
  bool fallarCarga = false;
  bool fallarGuardado = false;

  @override
  Future<Ajustes> cargar() async {
    if (fallarCarga) throw Exception('fallo de lectura');
    return inicial;
  }

  @override
  Future<void> guardar(Ajustes ajustes) async {
    if (fallarGuardado) throw Exception('fallo de guardado');
    guardados = ajustes;
  }
}

void main() {
  test('carga los ajustes guardados', () async {
    final controller = ConfiguracionController(
      repositorio: RepositorioFalso(
        inicial: const Ajustes(
          tema: ThemeMode.light,
          radioKm: 40,
          pantallaInicial: SeccionApp.favoritas,
        ),
      ),
    );

    await controller.cargar();

    expect(controller.cargado, isTrue);
    expect(controller.tema, ThemeMode.light);
    expect(controller.radioKm, 40);
    expect(controller.pantallaInicial, SeccionApp.favoritas);
  });

  test('si falla la lectura usa los valores por defecto y avisa', () async {
    final controller = ConfiguracionController(
      repositorio: RepositorioFalso()..fallarCarga = true,
    );

    await controller.cargar();

    expect(controller.tema, ThemeMode.system);
    expect(controller.radioKm, Ajustes.radioPorDefectoKm);
    expect(controller.aviso, isNotNull);
  });

  test('cambiar tema y pantalla inicial persiste cada cambio', () async {
    final repositorio = RepositorioFalso();
    final controller = ConfiguracionController(repositorio: repositorio);
    await controller.cargar();

    await controller.cambiarTema(ThemeMode.light);
    expect(controller.tema, ThemeMode.light);
    expect(repositorio.guardados!.tema, ThemeMode.light);

    await controller.cambiarTema(ThemeMode.dark);
    expect(controller.tema, ThemeMode.dark);
    expect(repositorio.guardados!.tema, ThemeMode.dark);

    await controller.cambiarTema(ThemeMode.system);
    expect(controller.tema, ThemeMode.system);
    expect(repositorio.guardados!.tema, ThemeMode.system);

    await controller.cambiarPantallaInicial(SeccionApp.masEconomicas);
    expect(controller.pantallaInicial, SeccionApp.masEconomicas);
    expect(repositorio.guardados!.pantallaInicial, SeccionApp.masEconomicas);

    await controller.cambiarCriterioEconomicas(CriterioEconomicas.media);
    expect(controller.ajustes.criterioEconomicas, CriterioEconomicas.media);
    expect(repositorio.guardados!.criterioEconomicas, CriterioEconomicas.media);
  });

  test('el radio se limita al rango permitido por la API', () async {
    final controller = ConfiguracionController(repositorio: RepositorioFalso());
    await controller.cargar();

    await controller.cambiarRadio(5);
    expect(controller.radioKm, Ajustes.radioMinimoKm);

    await controller.cambiarRadio(200);
    expect(controller.radioKm, Ajustes.radioMaximoKm);
  });

  test('Configuración nunca es pantalla inicial', () async {
    final controller = ConfiguracionController(repositorio: RepositorioFalso());
    await controller.cargar();

    await controller.cambiarPantallaInicial(SeccionApp.configuracion);

    expect(controller.pantallaInicial, SeccionApp.cercanas);
  });

  test('si falla el guardado avisa sin perder el cambio en memoria', () async {
    final controller = ConfiguracionController(
      repositorio: RepositorioFalso()..fallarGuardado = true,
    );
    await controller.cargar();

    await controller.cambiarTema(ThemeMode.light);

    expect(controller.tema, ThemeMode.light);
    expect(controller.aviso, isNotNull);
  });
}
