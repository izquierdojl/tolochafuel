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
  Future<void> _colaPersistencia = Future.value();

  bool esFavorito(int id) => favoritos.any((favorito) => favorito.id == id);

  bool avisosActivos(int id) =>
      favoritos.any((favorito) => favorito.id == id && favorito.avisosPrecio);

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

  Future<bool> marcarAviso(int id, bool activo) async {
    final indice = favoritos.indexWhere((favorito) => favorito.id == id);
    if (indice < 0) return false;
    if (favoritos[indice].avisosPrecio == activo) return true;
    final lista = List<Favorito>.of(favoritos);
    lista[indice] = lista[indice].copyWith(avisosPrecio: activo);
    favoritos = lista;
    notifyListeners();
    await _persistir();
    return true;
  }

  Future<void> mover(int desde, int hasta) async {
    if (favoritos.length < 2) return;
    if (desde < 0 || desde >= favoritos.length) return;
    if (hasta < 0 || hasta >= favoritos.length) return;
    if (desde == hasta) return;
    final lista = List<Favorito>.of(favoritos);
    final favorito = lista.removeAt(desde);
    lista.insert(hasta, favorito);
    favoritos = lista;
    notifyListeners();
    await _persistir();
  }

  Future<void> quitar(int id) async {
    favoritos = [
      for (final favorito in favoritos)
        if (favorito.id != id) favorito,
    ];
    _erroresDetalle.remove(id);
    notifyListeners();
    await _persistir();
  }

  Future<void> _persistir() {
    final instantanea = List<Favorito>.unmodifiable(favoritos);
    final operacion = _colaPersistencia.then(
      (_) => repositorio.guardar(instantanea),
    );
    _colaPersistencia = operacion.catchError((Object _) {});
    return operacion
        .then((_) {
          aviso = null;
          notifyListeners();
        })
        .catchError((Object _) {
          aviso = 'No se pudieron guardar los favoritos en este dispositivo.';
          notifyListeners();
        });
  }

  Future<void> cargarDetalles() async {
    for (final favorito in List.of(favoritos)) {
      await cargarDetalle(favorito.id);
    }
  }

  Future<void> cargarDetalle(int id, {bool forzar = false}) async {
    final enCache = _detalles[id];
    if (!forzar &&
        enCache != null &&
        !_caducado(enCache.proximaActualizacion)) {
      return;
    }
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
