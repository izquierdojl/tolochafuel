import 'package:flutter/foundation.dart';

import 'seccion_app.dart';

class ShellController extends ChangeNotifier {
  ShellController(SeccionApp inicial) : _seccion = inicial {
    _visitadas.add(inicial);
  }

  SeccionApp _seccion;
  final Set<SeccionApp> _visitadas = {};

  SeccionApp get seccion => _seccion;

  bool visitada(SeccionApp seccion) => _visitadas.contains(seccion);

  void irA(SeccionApp seccion) {
    if (seccion == _seccion) return;
    _seccion = seccion;
    _visitadas.add(seccion);
    notifyListeners();
  }
}
