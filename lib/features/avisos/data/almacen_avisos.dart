import 'package:shared_preferences/shared_preferences.dart';

abstract class AlmacenAvisos {
  Future<String?> leer(String clave);

  Future<void> escribir(String clave, String valor);

  Future<void> eliminar(String clave);
}

class AlmacenAvisosAsync implements AlmacenAvisos {
  AlmacenAvisosAsync({SharedPreferencesAsync? preferencias})
    : _preferencias = preferencias ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferencias;

  @override
  Future<String?> leer(String clave) => _preferencias.getString(clave);

  @override
  Future<void> escribir(String clave, String valor) =>
      _preferencias.setString(clave, valor);

  @override
  Future<void> eliminar(String clave) => _preferencias.remove(clave);
}
