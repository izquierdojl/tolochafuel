import 'package:tolochafuel/features/avisos/data/almacen_avisos.dart';

class AlmacenMemoria implements AlmacenAvisos {
  AlmacenMemoria([Map<String, String>? datos]) : datos = datos ?? {};

  final Map<String, String> datos;

  @override
  Future<void> eliminar(String clave) async {
    datos.remove(clave);
  }

  @override
  Future<void> escribir(String clave, String valor) async {
    datos[clave] = valor;
  }

  @override
  Future<String?> leer(String clave) async => datos[clave];
}
