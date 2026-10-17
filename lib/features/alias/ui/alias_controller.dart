import 'package:flutter/foundation.dart';

import '../data/alias_repositorio.dart';

class AliasController extends ChangeNotifier {
  AliasController({AliasRepositorio? repositorio})
    : repositorio = repositorio ?? AliasRepositorio();

  final AliasRepositorio repositorio;

  Map<int, String> _alias = const {};

  String? aliasDe(int id) => _alias[id];

  Future<void> cargar() async {
    try {
      _alias = await repositorio.cargar();
    } catch (_) {
      _alias = const {};
    }
    notifyListeners();
  }

  Future<bool> guardar(int id, String texto) async {
    final recortado = texto.trim();
    if (recortado.isEmpty) return quitar(id);
    _alias = {..._alias, id: recortado};
    notifyListeners();
    try {
      await repositorio.guardar(_alias);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> quitar(int id) async {
    _alias = {
      for (final entrada in _alias.entries)
        if (entrada.key != id) entrada.key: entrada.value,
    };
    notifyListeners();
    try {
      await repositorio.quitar(id);
      return true;
    } catch (_) {
      return false;
    }
  }
}
