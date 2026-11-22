import 'dart:convert';

import 'almacen_avisos.dart';
import 'estado_avisos.dart';

class AvisosRepositorio {
  AvisosRepositorio({AlmacenAvisos? almacen})
    : _almacen = almacen ?? AlmacenAvisosAsync();

  static const clave = 'avisos_precios_v1';
  static const duracionBloqueo = Duration(minutes: 5);

  final AlmacenAvisos _almacen;

  Future<EstadoAvisos> cargar() async {
    try {
      final texto = await _almacen.leer(clave);
      if (texto == null || texto.isEmpty) return const EstadoAvisos();
      final json = jsonDecode(texto);
      if (json is! Map<String, dynamic>) return const EstadoAvisos();
      return EstadoAvisos.fromJson(json);
    } catch (_) {
      return const EstadoAvisos();
    }
  }

  Future<void> guardar(EstadoAvisos estado) async {
    await _almacen.escribir(clave, jsonEncode(estado.toJson()));
  }

  Future<void> guardarBase(int id, BasePrecios base) async {
    final estado = await cargar();
    await guardar(estado.conBase(id, base));
  }

  Future<void> eliminarBase(int id) async {
    final estado = await cargar();
    if (!estado.estaciones.containsKey(id)) return;
    await guardar(estado.sinBase(id));
  }

  Future<bool> reconciliar(Set<int> idsActivos) async {
    final estado = await cargar();
    final sobrantes = estado.estaciones.keys
        .where((id) => !idsActivos.contains(id))
        .toList();
    if (sobrantes.isEmpty) return false;
    var nuevo = estado;
    for (final id in sobrantes) {
      nuevo = nuevo.sinBase(id);
    }
    await guardar(nuevo);
    return true;
  }

  Future<bool> adquirirBloqueo(
    DateTime ahora, {
    Duration duracion = duracionBloqueo,
  }) async {
    final estado = await cargar();
    final bloqueo = estado.lockHasta;
    if (bloqueo != null && ahora.toUtc().isBefore(bloqueo.toUtc())) {
      return false;
    }
    await guardar(estado.copyWith(lockHasta: ahora.toUtc().add(duracion)));
    return true;
  }

  Future<void> liberarBloqueo() async {
    final estado = await cargar();
    if (estado.lockHasta == null) return;
    await guardar(estado.copyWith(limpiarBloqueo: true));
  }
}
