import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tolochafuel/features/alias/data/alias_repositorio.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('guarda y vuelve a cargar los alias', () async {
    final repositorio = AliasRepositorio();
    await repositorio.guardar({1: 'La de la rotonda', 2: 'La del polígono'});

    final recargados = await AliasRepositorio().cargar();

    expect(recargados, {1: 'La de la rotonda', 2: 'La del polígono'});
  });

  test('quitar elimina solo el alias indicado', () async {
    final repositorio = AliasRepositorio();
    await repositorio.guardar({1: 'Una', 2: 'Otra'});

    await repositorio.quitar(1);

    final restantes = await AliasRepositorio().cargar();
    expect(restantes, {2: 'Otra'});
  });

  test('sin datos guardados devuelve un mapa vacío', () async {
    expect(await AliasRepositorio().cargar(), isEmpty);
  });

  test('ignora entradas inválidas y datos corruptos', () async {
    SharedPreferences.setMockInitialValues({
      AliasRepositorio.clave: '{no es json',
    });
    expect(await AliasRepositorio().cargar(), isEmpty);

    SharedPreferences.setMockInitialValues({
      AliasRepositorio.clave: '["texto", 7]',
    });
    expect(await AliasRepositorio().cargar(), isEmpty);

    SharedPreferences.setMockInitialValues({
      AliasRepositorio.clave:
          '{"7": "  Válida  ", "sin-id": "No vale", "8": 3, "9": "   "}',
    });
    expect(await AliasRepositorio().cargar(), {7: 'Válida'});
  });
}
