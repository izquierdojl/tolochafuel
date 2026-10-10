import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/precios_gasolina_api.dart';
import '../../../core/models/detalle_estacion.dart';
import '../../../core/models/gasolinera.dart';
import '../../../core/models/meta_datos.dart';
import '../data/favorito.dart';
import '../data/favoritos_repositorio.dart';

class FavoritosController extends ChangeNotifier {
  FavoritosController({
    FavoritosRepositorio? repositorio,
    PreciosGasolinaApi? api,
  }) : repositorio = repositorio ?? FavoritosRepositorio(),
       api = api ?? PreciosGasolinaApi();

  final FavoritosRepositorio repositorio;
  final PreciosGasolinaApi api;

  List<Favorito> favoritos = const [];
  bool cargado = false;
  String? aviso;
  MetaDatos? meta;

  final Map<int, DetalleEstacion> _detalles = {};
  final Set<int> _cargandoDetalle = {};
  final Map<int, String> _erroresDetalle = {};
  final Set<int> _consultando = {};

  bool esFavorito(int id) => favoritos.any((favorito) => favorito.id == id);

  DetalleEstacion? detalle(int id) => _detalles[id];

  bool cargandoDetalle(int id) => _cargandoDetalle.contains(id);

  String? errorDetalle(int id) => _erroresDetalle[id];

  Future<void> cargar() async {
    try {
      favoritos = await repositorio.cargar();
    } catch (_) {
      favoritos = const [];
      aviso = 'No se pudieron cargar los favoritos guardados.';
    }
    cargado = true;
    notifyListeners();
  }

  Future<void> alternar(Gasolinera gasolinera) async {
    if (esFavorito(gasolinera.id)) {
      await quitar(gasolinera.id);
    } else {
      await agregar(gasolinera);
    }
  }

  Future<void> agregar(Gasolinera gasolinera) async {
    if (esFavorito(gasolinera.id)) return;
    favoritos = [...favoritos, Favorito.desdeGasolinera(gasolinera)];
    notifyListeners();
    await _persistir();
    await cargarDetalle(gasolinera.id);
  }

  Future<void> quitar(int id) async {
    favoritos = [
      for (final favorito in favoritos)
        if (favorito.id != id) favorito,
    ];
    _detalles.remove(id);
    _erroresDetalle.remove(id);
    notifyListeners();
    await _persistirBorrado(id);
  }

  Future<void> _persistir() async {
    try {
      await repositorio.guardar(favoritos);
    } catch (_) {
      aviso = 'No se pudieron guardar los favoritos en este dispositivo.';
      notifyListeners();
    }
  }

  Future<void> _persistirBorrado(int id) async {
    try {
      await repositorio.borrar(id);
    } catch (_) {
      aviso = 'No se pudieron guardar los favoritos en este dispositivo.';
      notifyListeners();
    }
  }

  Future<void> cargarDetalles() async {
    for (final favorito in List.of(favoritos)) {
      await cargarDetalle(favorito.id);
    }
  }

  Future<void> cargarDetalle(int id) async {
    final enCache = _detalles[id];
    if (enCache != null && !_caducado(enCache.proximaActualizacion)) return;
    if (!_consultando.add(id)) return;
    _cargandoDetalle.add(id);
    _erroresDetalle.remove(id);
    notifyListeners();
    try {
      final detalle = await api.detalle(id);
      _detalles[id] = detalle;
      if (detalle.meta != null) meta = detalle.meta;
    } on ApiException catch (error) {
      _erroresDetalle[id] = error.mensaje;
    } catch (_) {
      _erroresDetalle[id] =
          'No se pudo consultar el precio. Inténtalo de nuevo.';
    } finally {
      _consultando.remove(id);
      _cargandoDetalle.remove(id);
      notifyListeners();
    }
  }

  bool _caducado(DateTime? proximaActualizacion) {
    if (proximaActualizacion == null) return false;
    return DateTime.now().toUtc().isAfter(proximaActualizacion.toUtc());
  }
}
