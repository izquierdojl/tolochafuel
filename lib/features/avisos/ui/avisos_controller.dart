import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../favoritos/data/favorito.dart';
import '../../favoritos/ui/favoritos_controller.dart';
import '../data/aviso_notificacion.dart';
import '../data/avisos_repositorio.dart';
import '../services/comprobador_avisos.dart';
import '../services/notificaciones_servicio.dart';
import '../services/programador_avisos.dart';

enum ResultadoAviso {
  activado,
  activadoSinBase,
  desactivado,
  permisoDenegado,
  notificacionesDesactivadas,
  noFavorito,
  sinCambios,
  error,
}

class AvisosController extends ChangeNotifier {
  factory AvisosController({
    required FavoritosController favoritos,
    ComprobadorAvisos? comprobador,
    AvisosRepositorio? repositorio,
    NotificacionesServicio? notificaciones,
    ProgramadorAvisos? programador,
  }) {
    final notificacionesFinal = notificaciones ?? const NotificacionesNulas();
    final repositorioFinal = repositorio ?? AvisosRepositorio();
    final programadorFinal = programador ?? ProgramadorPrimerPlano();
    return AvisosController._(
      favoritos: favoritos,
      comprobador:
          comprobador ??
          ComprobadorAvisosApi(
            favoritos: favoritos.repositorio,
            avisos: repositorioFinal,
            notificaciones: notificacionesFinal,
            programador: programadorFinal,
          ),
      repositorio: repositorioFinal,
      notificaciones: notificacionesFinal,
      programador: programadorFinal,
    );
  }

  AvisosController._({
    required this.favoritos,
    required this.comprobador,
    required this.repositorio,
    required this.notificaciones,
    required this.programador,
  }) {
    _idsConAviso = _idsActivos();
    favoritos.addListener(_alCambiarFavoritos);
  }

  final FavoritosController favoritos;
  final ComprobadorAvisos comprobador;
  final AvisosRepositorio repositorio;
  final NotificacionesServicio notificaciones;
  final ProgramadorAvisos programador;

  final Set<int> _ocupados = {};
  Set<int> _idsConAviso = {};
  Future<void> _cola = Future.value();
  bool _comprobando = false;

  List<AvisoNotificacion> avisosEnApp = const [];
  String? aviso;

  bool estaOcupado(int id) => _ocupados.contains(id);

  Future<ResultadoAviso> alternarAviso(int id) async {
    if (_ocupados.contains(id)) return ResultadoAviso.sinCambios;
    final favorito = _favorito(id);
    if (favorito == null) return ResultadoAviso.noFavorito;
    _ocupados.add(id);
    notifyListeners();
    try {
      if (favorito.avisosPrecio) {
        await favoritos.marcarAviso(id, false);
        await repositorio.eliminarBase(id);
        await notificaciones.cancelar(id);
        await _reprogramar();
        return ResultadoAviso.desactivado;
      }

      final permiso = await notificaciones.solicitarPermiso();
      if (!permiso) return ResultadoAviso.permisoDenegado;
      if (!await notificaciones.estanHabilitadas()) {
        return ResultadoAviso.notificacionesDesactivadas;
      }

      await favoritos.marcarAviso(id, true);
      final base = await comprobador.crearBase(id);
      await _reprogramar();
      return base == ResultadoBase.creada
          ? ResultadoAviso.activado
          : ResultadoAviso.activadoSinBase;
    } catch (_) {
      aviso = 'No se pudieron guardar los avisos en este dispositivo.';
      notifyListeners();
      return ResultadoAviso.error;
    } finally {
      _ocupados.remove(id);
      notifyListeners();
    }
  }

  Future<void> comprobarSiToca() async {
    if (_comprobando) return;
    _comprobando = true;
    try {
      final resultado = await comprobador.comprobar();
      if (resultado.avisosEnApp.isNotEmpty) {
        avisosEnApp = [...avisosEnApp, ...resultado.avisosEnApp];
        notifyListeners();
      }
    } catch (_) {
      return;
    } finally {
      _comprobando = false;
    }
  }

  void olvidarAvisoEnApp(AvisoNotificacion aviso) {
    avisosEnApp = [
      for (final pendiente in avisosEnApp)
        if (pendiente != aviso) pendiente,
    ];
    notifyListeners();
  }

  Future<void> reconciliar() {
    final operacion = _cola.then((_) => _reconciliar());
    _cola = operacion.catchError((Object _) {});
    return operacion;
  }

  Future<void> _reconciliar() async {
    final ids = _idsActivos();
    _idsConAviso = ids;
    try {
      await repositorio.reconciliar(ids);
      final estado = await repositorio.cargar();
      if (ids.isEmpty) {
        await notificaciones.cancelarTodas();
        await programador.cancelar();
      } else {
        await programador.programar(estado.proximaComprobacion);
      }
    } catch (_) {
      aviso = 'No se pudieron actualizar los avisos de precio.';
      notifyListeners();
    }
  }

  Future<void> _reprogramar() async {
    final estado = await repositorio.cargar();
    if (_idsActivos().isEmpty) {
      await programador.cancelar();
    } else {
      await programador.programar(estado.proximaComprobacion);
    }
  }

  Favorito? _favorito(int id) {
    for (final favorito in favoritos.favoritos) {
      if (favorito.id == id) return favorito;
    }
    return null;
  }

  Set<int> _idsActivos() => {
    for (final favorito in favoritos.favoritos)
      if (favorito.avisosPrecio) favorito.id,
  };

  void _alCambiarFavoritos() {
    final ids = _idsActivos();
    if (setEquals(ids, _idsConAviso)) return;
    _idsConAviso = ids;
    unawaited(reconciliar());
  }

  @override
  void dispose() {
    favoritos.removeListener(_alCambiarFavoritos);
    super.dispose();
  }
}
