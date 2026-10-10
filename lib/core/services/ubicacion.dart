import 'dart:async';

import 'package:geolocator/geolocator.dart';

enum ResultadoUbicacion { concedida, denegada, deshabilitada, noSoportada }

class Ubicacion {
  const Ubicacion();

  Future<ResultadoUbicacion> preparar() async {
    try {
      final servicioActivo = await Geolocator.isLocationServiceEnabled()
          .timeout(const Duration(seconds: 10));
      if (!servicioActivo) return ResultadoUbicacion.deshabilitada;

      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) {
        return ResultadoUbicacion.denegada;
      }
      return ResultadoUbicacion.concedida;
    } catch (_) {
      return ResultadoUbicacion.noSoportada;
    }
  }

  Future<Position?> actual() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      ).timeout(const Duration(seconds: 12));
    } catch (_) {
      return null;
    }
  }
}
