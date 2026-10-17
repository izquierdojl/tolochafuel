import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AliasRepositorio {
  static const clave = 'alias_estaciones';

  Future<Map<int, String>> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final texto = prefs.getString(clave);
    if (texto == null || texto.isEmpty) return {};
    try {
      final decodificado = jsonDecode(texto);
      if (decodificado is! Map<String, dynamic>) return {};
      final alias = <int, String>{};
      for (final entrada in decodificado.entries) {
        final id = int.tryParse(entrada.key);
        final valor = entrada.value;
        if (id == null || valor is! String) continue;
        final recortado = valor.trim();
        if (recortado.isEmpty) continue;
        alias[id] = recortado;
      }
      return alias;
    } catch (_) {
      return {};
    }
  }

  Future<void> guardar(Map<int, String> alias) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      clave,
      jsonEncode({
        for (final entrada in alias.entries) '${entrada.key}': entrada.value,
      }),
    );
  }

  Future<void> quitar(int id) async {
    final alias = await cargar();
    alias.remove(id);
    await guardar(alias);
  }
}
