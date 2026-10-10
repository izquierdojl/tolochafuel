import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/models/gasolinera.dart';
import '../../../core/models/lugar.dart';
import '../../../core/models/meta_datos.dart';
import '../data/cercanas_repositorio.dart';
import 'cercanas_controller.dart';

class BuscarController extends ChangeNotifier {
  BuscarController({CercanasRepositorio? repositorio})
    : repositorio = repositorio ?? CercanasRepositorio();

  final CercanasRepositorio repositorio;

  EstadoCercanas estado = EstadoCercanas.inicial;
  List<Lugar> resultadosBusqueda = const [];
  bool buscandoLugar = false;
  String? errorBusqueda;
  List<Gasolinera> gasolineras = const [];
  String? areaNombre;
  MetaDatos? meta;
  String? mensajeError;
  Lugar? lugarElegido;

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
    lugarElegido = lugar;
    resultadosBusqueda = const [];
    errorBusqueda = null;
    await _cargarMasBaratas();
  }

  Future<void> reintentar() async {
    if (lugarElegido == null) return;
    await _cargarMasBaratas();
  }

  Future<void> _cargarMasBaratas() async {
    _establecer(EstadoCercanas.cargando);
    try {
      final lugar = lugarElegido!;
      final resultado = await repositorio.masBaratas(lugar: lugar);
      gasolineras = resultado.gasolineras;
      areaNombre = resultado.areaNombre ?? lugar.nombre;
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

  void _establecer(EstadoCercanas nuevo) {
    estado = nuevo;
    notifyListeners();
  }
}
