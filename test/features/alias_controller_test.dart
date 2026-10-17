import 'package:flutter_test/flutter_test.dart';
import 'package:tolochafuel/features/alias/data/alias_repositorio.dart';
import 'package:tolochafuel/features/alias/ui/alias_controller.dart';

class RepositorioFalso extends AliasRepositorio {
  RepositorioFalso({this.inicial = const {}});

  Map<int, String> inicial;
  Map<int, String>? guardados;
  final List<int> quitados = [];
  bool fallarCarga = false;
  bool fallarGuardado = false;

  @override
  Future<Map<int, String>> cargar() async {
    if (fallarCarga) throw Exception('fallo de carga');
    return inicial;
  }

  @override
  Future<void> guardar(Map<int, String> alias) async {
    if (fallarGuardado) throw Exception('fallo de guardado');
    guardados = {...alias};
  }

  @override
  Future<void> quitar(int id) async {
    if (fallarGuardado) throw Exception('fallo de borrado');
    quitados.add(id);
  }
}

void main() {
  test('carga los alias guardados', () async {
    final controller = AliasController(
      repositorio: RepositorioFalso(inicial: const {7: 'La de la rotonda'}),
    );

    await controller.cargar();

    expect(controller.aliasDe(7), 'La de la rotonda');
    expect(controller.aliasDe(8), isNull);
  });

  test('carga tolerante: si falla la lectura, sigue sin alias', () async {
    final controller = AliasController(
      repositorio: RepositorioFalso()..fallarCarga = true,
    );

    await controller.cargar();

    expect(controller.aliasDe(7), isNull);
  });

  test('guardar recorta el texto, notifica y persiste', () async {
    final repositorio = RepositorioFalso();
    final controller = AliasController(repositorio: repositorio);
    await controller.cargar();
    var avisos = 0;
    controller.addListener(() => avisos++);

    final resultado = await controller.guardar(7, '  La de la rotonda  ');

    expect(resultado, isTrue);
    expect(controller.aliasDe(7), 'La de la rotonda');
    expect(repositorio.guardados, {7: 'La de la rotonda'});
    expect(avisos, 1);
  });

  test('guardar en blanco equivale a quitar', () async {
    final repositorio = RepositorioFalso(inicial: const {7: 'Una'});
    final controller = AliasController(repositorio: repositorio);
    await controller.cargar();

    final resultado = await controller.guardar(7, '   ');

    expect(resultado, isTrue);
    expect(controller.aliasDe(7), isNull);
    expect(repositorio.quitados, [7]);
  });

  test('quitar elimina el alias y persiste', () async {
    final repositorio = RepositorioFalso(inicial: const {7: 'Una', 8: 'Otra'});
    final controller = AliasController(repositorio: repositorio);
    await controller.cargar();

    await controller.quitar(7);

    expect(controller.aliasDe(7), isNull);
    expect(controller.aliasDe(8), 'Otra');
    expect(repositorio.quitados, [7]);
  });

  test('si falla el guardado devuelve false y mantiene el alias', () async {
    final controller = AliasController(
      repositorio: RepositorioFalso()..fallarGuardado = true,
    );
    await controller.cargar();

    final resultado = await controller.guardar(7, 'La de la rotonda');

    expect(resultado, isFalse);
    expect(controller.aliasDe(7), 'La de la rotonda');
  });
}
