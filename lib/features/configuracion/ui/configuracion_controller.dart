import 'package:flutter/foundation.dart';

import '../../../app/shell/seccion_app.dart';
import '../data/configuracion_repositorio.dart';

class ConfiguracionController extends ChangeNotifier {
  ConfiguracionController({ConfiguracionRepositorio? repositorio})
    : repositorio = repositorio ?? ConfiguracionRepositorio();

  final ConfiguracionRepositorio repositorio;

  Ajustes ajustes = const Ajustes();
  bool cargado = false;
  String? aviso;

  bool get temaOscuro => ajustes.temaOscuro;

  double get radioKm => ajustes.radioKm;

  SeccionApp get pantallaInicial => ajustes.pantallaInicial;

  Future<void> cargar() async {
    try {
      ajustes = await repositorio.cargar();
    } catch (_) {
      ajustes = const Ajustes();
      aviso = 'No se pudo leer la configuración guardada.';
    }
    cargado = true;
    notifyListeners();
  }

  Future<void> cambiarTema({required bool oscuro}) =>
      _aplicar(ajustes.copyWith(temaOscuro: oscuro));

  Future<void> cambiarRadio(double km) => _aplicar(
    ajustes.copyWith(
      radioKm: km
          .clamp(Ajustes.radioMinimoKm, Ajustes.radioMaximoKm)
          .toDouble(),
    ),
  );

  Future<void> cambiarPantallaInicial(SeccionApp seccion) {
    if (seccion == SeccionApp.configuracion) return Future.value();
    return _aplicar(ajustes.copyWith(pantallaInicial: seccion));
  }

  Future<void> _aplicar(Ajustes nuevos) async {
    ajustes = nuevos;
    notifyListeners();
    try {
      await repositorio.guardar(nuevos);
    } catch (_) {
      aviso = 'No se pudo guardar la configuración en este dispositivo.';
      notifyListeners();
    }
  }
}
