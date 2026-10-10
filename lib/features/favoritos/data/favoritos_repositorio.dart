import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'favorito.dart';

class FavoritosRepositorio {
  static const clave = 'favoritos';

  Future<List<Favorito>> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final texto = prefs.getString(clave);
    if (texto == null || texto.isEmpty) return const [];
    try {
      final lista = jsonDecode(texto);
      if (lista is! List) return const [];
      final favoritos = <Favorito>[];
      for (final item in lista) {
        if (item is! Map<String, dynamic>) continue;
        final favorito = Favorito.fromJson(item);
        if (favorito != null) favoritos.add(favorito);
      }
      return favoritos;
    } catch (_) {
      return const [];
    }
  }

  Future<void> guardar(List<Favorito> favoritos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      clave,
      jsonEncode([for (final favorito in favoritos) favorito.toJson()]),
    );
  }

  Future<void> borrar(int id) async {
    final favoritos = await cargar();
    await guardar([
      for (final favorito in favoritos)
        if (favorito.id != id) favorito,
    ]);
  }
}
