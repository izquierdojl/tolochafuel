import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/shell/seccion_app.dart';
import '../../../core/api/precios_gasolina_api.dart';
import '../../../core/models/criterio_economicas.dart';

class Ajustes {
  const Ajustes({
    this.tema = ThemeMode.system,
    this.radioKm = radioPorDefectoKm,
    this.pantallaInicial = SeccionApp.cercanas,
    this.criterioEconomicas = CriterioEconomicas.gasolina95,
  });

  static const radioMinimoKm = 10.0;
  static const radioMaximoKm = PreciosGasolinaApi.radioMaximoKm;
  static const radioPorDefectoKm = 25.0;

  final ThemeMode tema;
  final double radioKm;
  final SeccionApp pantallaInicial;
  final CriterioEconomicas criterioEconomicas;

  Ajustes copyWith({
    ThemeMode? tema,
    double? radioKm,
    SeccionApp? pantallaInicial,
    CriterioEconomicas? criterioEconomicas,
  }) => Ajustes(
    tema: tema ?? this.tema,
    radioKm: radioKm ?? this.radioKm,
    pantallaInicial: pantallaInicial ?? this.pantallaInicial,
    criterioEconomicas: criterioEconomicas ?? this.criterioEconomicas,
  );
}

class ConfiguracionRepositorio {
  static const claveTema = 'config.tema';
  static const claveTemaAnterior = 'config.temaOscuro';
  static const claveRadio = 'config.radioKm';
  static const clavePantalla = 'config.pantallaInicial';
  static const claveCriterio = 'config.criterioEconomicas';

  Future<Ajustes> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final tema = _leerTema(prefs.get(claveTema), prefs.get(claveTemaAnterior));
    final radio = prefs.get(claveRadio);
    final pantalla = prefs.get(clavePantalla);
    final criterio = prefs.get(claveCriterio);
    final radioNum = radio is num ? radio.toDouble() : null;
    final radioValido =
        radioNum != null &&
        radioNum >= Ajustes.radioMinimoKm &&
        radioNum <= Ajustes.radioMaximoKm;
    final inicial = pantalla is String
        ? SeccionApp.desdeClave(pantalla)
        : SeccionApp.cercanas;
    return Ajustes(
      tema: tema,
      radioKm: radioValido ? radioNum : Ajustes.radioPorDefectoKm,
      pantallaInicial: inicial == SeccionApp.configuracion
          ? SeccionApp.cercanas
          : inicial,
      criterioEconomicas: criterio is String
          ? CriterioEconomicas.desdeClave(criterio)
          : CriterioEconomicas.gasolina95,
    );
  }

  Future<void> guardar(Ajustes ajustes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(claveTema, _claveDeTema(ajustes.tema));
    await prefs.setDouble(claveRadio, ajustes.radioKm);
    await prefs.setString(clavePantalla, ajustes.pantallaInicial.clave);
    await prefs.setString(claveCriterio, ajustes.criterioEconomicas.clave);
  }

  static ThemeMode _leerTema(Object? actual, Object? anterior) {
    switch (actual) {
      case 'sistema':
        return ThemeMode.system;
      case 'claro':
        return ThemeMode.light;
      case 'oscuro':
        return ThemeMode.dark;
    }
    if (actual == null && anterior is bool) {
      return anterior ? ThemeMode.dark : ThemeMode.light;
    }
    return ThemeMode.system;
  }

  static String _claveDeTema(ThemeMode tema) => switch (tema) {
    ThemeMode.system => 'sistema',
    ThemeMode.light => 'claro',
    ThemeMode.dark => 'oscuro',
  };
}
