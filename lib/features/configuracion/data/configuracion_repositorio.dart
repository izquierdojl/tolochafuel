import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/shell/seccion_app.dart';
import '../../../core/api/precios_gasolina_api.dart';

class Ajustes {
  const Ajustes({
    this.temaOscuro = true,
    this.radioKm = radioPorDefectoKm,
    this.pantallaInicial = SeccionApp.cercanas,
  });

  static const radioMinimoKm = 10.0;
  static const radioMaximoKm = PreciosGasolinaApi.radioMaximoKm;
  static const radioPorDefectoKm = 25.0;

  final bool temaOscuro;
  final double radioKm;
  final SeccionApp pantallaInicial;

  Ajustes copyWith({
    bool? temaOscuro,
    double? radioKm,
    SeccionApp? pantallaInicial,
  }) => Ajustes(
    temaOscuro: temaOscuro ?? this.temaOscuro,
    radioKm: radioKm ?? this.radioKm,
    pantallaInicial: pantallaInicial ?? this.pantallaInicial,
  );
}

class ConfiguracionRepositorio {
  static const claveTema = 'config.temaOscuro';
  static const claveRadio = 'config.radioKm';
  static const clavePantalla = 'config.pantallaInicial';

  Future<Ajustes> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final tema = prefs.get(claveTema);
    final radio = prefs.get(claveRadio);
    final pantalla = prefs.get(clavePantalla);
    final radioNum = radio is num ? radio.toDouble() : null;
    final radioValido =
        radioNum != null &&
        radioNum >= Ajustes.radioMinimoKm &&
        radioNum <= Ajustes.radioMaximoKm;
    final inicial = pantalla is String
        ? SeccionApp.desdeClave(pantalla)
        : SeccionApp.cercanas;
    return Ajustes(
      temaOscuro: tema is bool ? tema : true,
      radioKm: radioValido ? radioNum : Ajustes.radioPorDefectoKm,
      pantallaInicial: inicial == SeccionApp.configuracion
          ? SeccionApp.cercanas
          : inicial,
    );
  }

  Future<void> guardar(Ajustes ajustes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(claveTema, ajustes.temaOscuro);
    await prefs.setDouble(claveRadio, ajustes.radioKm);
    await prefs.setString(clavePantalla, ajustes.pantallaInicial.clave);
  }
}
