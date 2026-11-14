import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tolochafuel/app/shell/seccion_app.dart';
import 'package:tolochafuel/core/models/criterio_economicas.dart';
import 'package:tolochafuel/features/configuracion/data/configuracion_repositorio.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('sin preferencias guardadas devuelve los valores por defecto', () async {
    final ajustes = await ConfiguracionRepositorio().cargar();

    expect(ajustes.tema, ThemeMode.system);
    expect(ajustes.radioKm, Ajustes.radioPorDefectoKm);
    expect(ajustes.pantallaInicial, SeccionApp.cercanas);
    expect(ajustes.criterioEconomicas, CriterioEconomicas.gasolina95);
  });

  test('guarda y vuelve a cargar cada preferencia', () async {
    final repositorio = ConfiguracionRepositorio();
    await repositorio.guardar(
      const Ajustes(
        tema: ThemeMode.light,
        radioKm: 40,
        pantallaInicial: SeccionApp.buscar,
        criterioEconomicas: CriterioEconomicas.media,
      ),
    );

    final ajustes = await ConfiguracionRepositorio().cargar();

    expect(ajustes.tema, ThemeMode.light);
    expect(ajustes.radioKm, 40);
    expect(ajustes.pantallaInicial, SeccionApp.buscar);
    expect(ajustes.criterioEconomicas, CriterioEconomicas.media);
  });

  test('ida y vuelta de los tres modos de tema', () async {
    for (final modo in ThemeMode.values) {
      SharedPreferences.setMockInitialValues({});
      await ConfiguracionRepositorio().guardar(Ajustes(tema: modo));

      final ajustes = await ConfiguracionRepositorio().cargar();

      expect(ajustes.tema, modo);
    }
  });

  test('migra la preferencia booleana anterior: oscuro', () async {
    SharedPreferences.setMockInitialValues({
      ConfiguracionRepositorio.claveTemaAnterior: true,
    });

    final ajustes = await ConfiguracionRepositorio().cargar();

    expect(ajustes.tema, ThemeMode.dark);
  });

  test('migra la preferencia booleana anterior: claro', () async {
    SharedPreferences.setMockInitialValues({
      ConfiguracionRepositorio.claveTemaAnterior: false,
    });

    final ajustes = await ConfiguracionRepositorio().cargar();

    expect(ajustes.tema, ThemeMode.light);
  });

  test('la clave nueva prevalece sobre la booleana anterior', () async {
    SharedPreferences.setMockInitialValues({
      ConfiguracionRepositorio.claveTema: 'sistema',
      ConfiguracionRepositorio.claveTemaAnterior: false,
    });

    final ajustes = await ConfiguracionRepositorio().cargar();

    expect(ajustes.tema, ThemeMode.system);
  });

  test('la migración no borra la clave anterior', () async {
    SharedPreferences.setMockInitialValues({
      ConfiguracionRepositorio.claveTemaAnterior: false,
    });

    await ConfiguracionRepositorio().cargar();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(ConfiguracionRepositorio.claveTemaAnterior), isFalse);
  });

  test('tema con valor inválido vuelve a Sistema', () async {
    SharedPreferences.setMockInitialValues({
      ConfiguracionRepositorio.claveTema: 'no es un modo',
    });

    final ajustes = await ConfiguracionRepositorio().cargar();

    expect(ajustes.tema, ThemeMode.system);
  });

  test(
    'ignora valores inválidos y protege Configuración como inicial',
    () async {
      SharedPreferences.setMockInitialValues({
        ConfiguracionRepositorio.claveRadio: 200.0,
        ConfiguracionRepositorio.clavePantalla: 'configuracion',
        ConfiguracionRepositorio.claveTema: 'no es un modo',
        ConfiguracionRepositorio.claveCriterio: 'queroseno',
      });

      final ajustes = await ConfiguracionRepositorio().cargar();

      expect(ajustes.radioKm, Ajustes.radioPorDefectoKm);
      expect(ajustes.pantallaInicial, SeccionApp.cercanas);
      expect(ajustes.tema, ThemeMode.system);
      expect(ajustes.criterioEconomicas, CriterioEconomicas.gasolina95);
    },
  );
}
