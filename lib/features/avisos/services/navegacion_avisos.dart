import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../data/aviso_notificacion.dart';

EstacionAviso? parsearEstacionAviso(String? payload) {
  if (payload == null || payload.isEmpty) return null;
  try {
    final json = jsonDecode(payload);
    if (json is! Map<String, dynamic>) return null;
    final id = json['id'];
    final nombre = json['nombre'];
    if (id is! num) return null;
    final nombreTexto = nombre is String ? nombre.trim() : '';
    return EstacionAviso(
      id: id.toInt(),
      nombre: nombreTexto.isEmpty ? 'Gasolinera' : nombreTexto,
    );
  } catch (_) {
    return null;
  }
}

String payloadEstacionAviso(EstacionAviso estacion) =>
    jsonEncode({'id': estacion.id, 'nombre': estacion.nombre});

class NavegacionAvisosController extends ChangeNotifier {
  EstacionAviso? _pendiente;

  EstacionAviso? get pendiente => _pendiente;

  void abrir(EstacionAviso estacion) {
    _pendiente = estacion;
    notifyListeners();
  }

  EstacionAviso? consumir() {
    final estacion = _pendiente;
    _pendiente = null;
    return estacion;
  }
}
