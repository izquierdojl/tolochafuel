import 'dart:math';

import '../../../core/api/precios_gasolina_api.dart';
import '../../../core/models/detalle_estacion.dart';
import '../../../core/models/lugar.dart';

class CercanasRepositorio {
  CercanasRepositorio({PreciosGasolinaApi? api})
    : api = api ?? PreciosGasolinaApi();

  static const limiteListado = 20;
  static const concurrenciaFichas = 6;

  final PreciosGasolinaApi api;
  final Map<String, ResultadoGasolineras> _cacheListados = {};
  final Map<int, DetalleEstacion> _cacheFichas = {};

  Future<ResultadoGasolineras> cercanas({
    required double lat,
    required double lng,
    double radioKm = 5,
  }) {
    final clave =
        'cercanas:${lat.toStringAsFixed(3)},${lng.toStringAsFixed(3)},$radioKm';
    return _conCacheListado(clave, () async {
      final resultado = await api.cercanas(
        lat: lat,
        lng: lng,
        radioKm: radioKm,
        limite: limiteListado,
      );
      return _conFichas(resultado);
    });
  }

  Future<ResultadoGasolineras> masBaratas({required Lugar lugar}) {
    final clave = 'territorio:${lugar.nivel},${lugar.codigo}';
    return _conCacheListado(clave, () async {
      final resultado = await api.masBaratas(
        nivel: lugar.nivel,
        codigo: lugar.codigo,
        limite: limiteListado,
      );
      return _conFichas(resultado);
    });
  }

  Future<List<Lugar>> buscarLugar(String consulta) => api.buscarLugar(consulta);

  void limpiarCache() {
    _cacheListados.clear();
    _cacheFichas.clear();
  }

  Future<ResultadoGasolineras> _conFichas(
    ResultadoGasolineras resultado,
  ) async {
    final detalles = <int, DetalleEstacion>{};
    for (var i = 0; i < resultado.gasolineras.length; i += concurrenciaFichas) {
      final lote = resultado.gasolineras.sublist(
        i,
        min(i + concurrenciaFichas, resultado.gasolineras.length),
      );
      await Future.wait(
        lote.map((gasolinera) async {
          try {
            detalles[gasolinera.id] = await _fichaDe(gasolinera.id);
          } catch (_) {
            // Sin ficha: la tarjeta mostrará «Precios no disponibles».
          }
        }),
      );
    }
    return ResultadoGasolineras(
      gasolineras: [
        for (final gasolinera in resultado.gasolineras)
          gasolinera.conProductos(
            detalles[gasolinera.id]?.productos ?? const [],
          ),
      ],
      meta: resultado.meta,
      areaNombre: resultado.areaNombre,
    );
  }

  Future<DetalleEstacion> _fichaDe(int id) async {
    final enCache = _cacheFichas[id];
    if (enCache != null && !_caducado(enCache.proximaActualizacion)) {
      return enCache;
    }
    final detalle = await api.detalle(id);
    _cacheFichas[id] = detalle;
    return detalle;
  }

  Future<ResultadoGasolineras> _conCacheListado(
    String clave,
    Future<ResultadoGasolineras> Function() cargar,
  ) async {
    final enCache = _cacheListados[clave];
    if (enCache != null && !_caducado(enCache.meta.proximaActualizacion)) {
      return enCache;
    }
    final resultado = await cargar();
    _cacheListados[clave] = resultado;
    return resultado;
  }

  bool _caducado(DateTime? proximaActualizacion) {
    if (proximaActualizacion == null) return false;
    return DateTime.now().toUtc().isAfter(proximaActualizacion.toUtc());
  }
}
