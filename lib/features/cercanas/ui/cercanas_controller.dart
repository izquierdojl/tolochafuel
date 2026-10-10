import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/models/gasolinera.dart';
import '../../../core/models/meta_datos.dart';
import '../../../core/services/ubicacion.dart';
import '../../configuracion/ui/configuracion_controller.dart';
import '../data/cercanas_repositorio.dart';

enum EstadoCercanas { inicial, cargando, datos, vacio, error }

class CercanasController extends ChangeNotifier {
  CercanasController({
    CercanasRepositorio? repositorio,
    Ubicacion? ubicacion,
    this.configuracion,
    this.radioKmInicial = 5,
  }) : repositorio = repositorio ?? CercanasRepositorio(),
       ubicacion = ubicacion ?? const Ubicacion() {
    configuracion?.addListener(_alCambiarConfiguracion);
  }

  final CercanasRepositorio repositorio;
  final Ubicacion ubicacion;
  final ConfiguracionController? configuracion;
  final double radioKmInicial;

  EstadoCercanas estado = EstadoCercanas.inicial;
  List<Gasolinera> gasolineras = const [];
  MetaDatos? meta;
  String? mensajeError;
  String? avisoUbicacion;

  (double, double)? _centro;
  double? _radioUsado;

  double get radioKm => configuracion?.radioKm ?? radioKmInicial;

  Future<void> inicializar() async {
    avisoUbicacion = null;
    _establecer(EstadoCercanas.cargando);

    final resultado = await ubicacion.preparar();
    switch (resultado) {
      case ResultadoUbicacion.concedida:
        final posicion = await ubicacion.actual();
        if (posicion == null) {
          _avisarSinUbicacion(
            'No se pudo obtener la ubicación actual. '
            'Busca por municipio o provincia.',
          );
          return;
        }
        _centro = (posicion.latitude, posicion.longitude);
        await _cargar();
      case ResultadoUbicacion.denegada:
        _avisarSinUbicacion(
          'Permiso de ubicación denegado. Busca por municipio o provincia.',
        );
      case ResultadoUbicacion.deshabilitada:
        _avisarSinUbicacion(
          'La ubicación está desactivada. Busca por municipio o provincia.',
        );
      case ResultadoUbicacion.noSoportada:
        _avisarSinUbicacion(
          'Este dispositivo no ofrece ubicación. '
          'Busca por municipio o provincia.',
        );
    }
  }

  Future<void> reintentar() async {
    if (_centro == null) {
      await inicializar();
      return;
    }
    await _cargar();
  }

  Future<void> _cargar() async {
    _establecer(EstadoCercanas.cargando);
    try {
      final radio = radioKm;
      final centro = _centro!;
      final resultado = await repositorio.cercanas(
        lat: centro.$1,
        lng: centro.$2,
        radioKm: radio,
      );
      _radioUsado = radio;
      gasolineras = resultado.gasolineras;
      meta = resultado.meta;
      _establecer(
        gasolineras.isEmpty ? EstadoCercanas.vacio : EstadoCercanas.datos,
      );
    } on ApiException catch (error) {
      mensajeError = error.mensaje;
      _establecer(EstadoCercanas.error);
    } catch (_) {
      mensajeError = 'Ha ocurrido un error inesperado. Inténtalo de nuevo.';
      _establecer(EstadoCercanas.error);
    }
  }

  void _avisarSinUbicacion(String aviso) {
    avisoUbicacion = aviso;
    _establecer(EstadoCercanas.vacio);
  }

  void _alCambiarConfiguracion() {
    if (_centro == null || configuracion?.radioKm == _radioUsado) return;
    _cargar();
  }

  void _establecer(EstadoCercanas nuevo) {
    estado = nuevo;
    notifyListeners();
  }

  @override
  void dispose() {
    configuracion?.removeListener(_alCambiarConfiguracion);
    super.dispose();
  }
}
