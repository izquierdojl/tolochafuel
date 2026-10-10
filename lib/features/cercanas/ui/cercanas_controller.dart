import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/models/gasolinera.dart';
import '../../../core/models/lugar.dart';
import '../../../core/models/meta_datos.dart';
import '../../../core/services/ubicacion.dart';
import '../data/cercanas_repositorio.dart';

enum EstadoCercanas { inicial, cargando, datos, vacio, error }

class CercanasController extends ChangeNotifier {
  CercanasController({
    CercanasRepositorio? repositorio,
    Ubicacion? ubicacion,
    this.radioKm = 5,
  }) : repositorio = repositorio ?? CercanasRepositorio(),
       ubicacion = ubicacion ?? const Ubicacion();

  final CercanasRepositorio repositorio;
  final Ubicacion ubicacion;
  final double radioKm;

  EstadoCercanas estado = EstadoCercanas.inicial;
  List<Gasolinera> gasolineras = const [];
  MetaDatos? meta;
  String? areaNombre;
  String? mensajeError;

  bool modoManual = false;
  bool seleccionUbicacion = false;
  String? avisoUbicacion;
  List<Lugar> resultadosBusqueda = const [];
  bool buscandoLugar = false;
  String? errorBusqueda;

  (double, double)? _centro;
  Lugar? _lugar;

  bool get mostrandoPanelManual => modoManual && seleccionUbicacion;

  Future<void> inicializar() async {
    modoManual = false;
    seleccionUbicacion = false;
    avisoUbicacion = null;
    _lugar = null;
    _establecer(EstadoCercanas.cargando);

    final resultado = await ubicacion.preparar();
    switch (resultado) {
      case ResultadoUbicacion.concedida:
        final posicion = await ubicacion.actual();
        if (posicion == null) {
          _pasarAModoManual(
            'No se pudo obtener la ubicación actual. '
            'Busca por municipio o provincia.',
          );
          return;
        }
        _centro = (posicion.latitude, posicion.longitude);
        await _cargarSegunOrigen();
      case ResultadoUbicacion.denegada:
        _pasarAModoManual(
          'Permiso de ubicación denegado. Busca por municipio o provincia.',
        );
      case ResultadoUbicacion.deshabilitada:
        _pasarAModoManual(
          'La ubicación está desactivada. Busca por municipio o provincia.',
        );
      case ResultadoUbicacion.noSoportada:
        _pasarAModoManual(
          'Este dispositivo no ofrece ubicación. '
          'Busca por municipio o provincia.',
        );
    }
  }

  Future<void> reintentar() async {
    if (_centro == null && _lugar == null) {
      await inicializar();
      return;
    }
    await _cargarSegunOrigen();
  }

  Future<void> buscarLugar(String consulta) async {
    final texto = consulta.trim();
    if (texto.isEmpty) return;
    buscandoLugar = true;
    errorBusqueda = null;
    resultadosBusqueda = const [];
    notifyListeners();
    try {
      resultadosBusqueda = await repositorio.buscarLugar(texto);
      if (resultadosBusqueda.isEmpty) {
        errorBusqueda =
            'No se han encontrado municipios ni provincias para «$texto».';
      }
    } on ApiException catch (error) {
      errorBusqueda = error.mensaje;
    } catch (_) {
      errorBusqueda = 'No se pudo buscar. Inténtalo de nuevo.';
    } finally {
      buscandoLugar = false;
      notifyListeners();
    }
  }

  Future<void> elegirLugar(Lugar lugar) async {
    _lugar = lugar;
    _centro = null;
    seleccionUbicacion = false;
    resultadosBusqueda = const [];
    errorBusqueda = null;
    await _cargarSegunOrigen();
  }

  void volverABusqueda() {
    seleccionUbicacion = true;
    resultadosBusqueda = const [];
    errorBusqueda = null;
    notifyListeners();
  }

  void _pasarAModoManual(String aviso) {
    modoManual = true;
    seleccionUbicacion = true;
    avisoUbicacion = aviso;
    _establecer(EstadoCercanas.vacio);
  }

  Future<void> _cargarSegunOrigen() async {
    _establecer(EstadoCercanas.cargando);
    try {
      final lugar = _lugar;
      final centro = _centro;
      final resultado = lugar != null
          ? await repositorio.masBaratas(lugar: lugar)
          : await repositorio.cercanas(
              lat: centro!.$1,
              lng: centro.$2,
              radioKm: radioKm,
            );
      gasolineras = resultado.gasolineras;
      meta = resultado.meta;
      areaNombre = resultado.areaNombre;
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

  void _establecer(EstadoCercanas nuevo) {
    estado = nuevo;
    notifyListeners();
  }
}
