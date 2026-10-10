import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/precios_gasolina_api.dart';
import '../../../core/models/historico_estacion.dart';

class HistorialController extends ChangeNotifier {
  HistorialController({PreciosGasolinaApi? api})
    : api = api ?? PreciosGasolinaApi();

  static const maxConcurrentes = 4;

  final PreciosGasolinaApi api;
  final Map<int, HistoricoEstacion> _historicos = {};
  final Set<int> _enCurso = {};
  final Map<int, String> _errores = {};
  final Queue<Future<void> Function()> _pendientes = Queue();
  int _activas = 0;

  HistoricoEstacion? historico(int id) => _historicos[id];

  bool cargando(int id) => _enCurso.contains(id);

  String? error(int id) => _errores[id];

  Future<void> cargar(int id) async {
    final enCache = _historicos[id];
    if (enCache != null && !_caducado(enCache.proximaActualizacion)) return;
    if (!_enCurso.add(id)) return;
    _errores.remove(id);
    notifyListeners();
    await _encolar(() => _descargar(id));
  }

  Future<void> _descargar(int id) async {
    try {
      _historicos[id] = await api.historico(id);
    } on ApiException catch (error) {
      _errores[id] = error.mensaje;
    } catch (_) {
      _errores[id] = 'No se pudo consultar el histórico. Inténtalo de nuevo.';
    } finally {
      _enCurso.remove(id);
      notifyListeners();
    }
  }

  Future<void> _encolar(Future<void> Function() tarea) {
    final completer = Completer<void>();
    _pendientes.add(() async {
      try {
        await tarea();
      } finally {
        completer.complete();
      }
    });
    _bombear();
    return completer.future;
  }

  void _bombear() {
    while (_activas < maxConcurrentes && _pendientes.isNotEmpty) {
      final tarea = _pendientes.removeFirst();
      _activas++;
      unawaited(
        tarea().whenComplete(() {
          _activas--;
          _bombear();
        }),
      );
    }
  }

  bool _caducado(DateTime? proximaActualizacion) {
    if (proximaActualizacion == null) return false;
    return DateTime.now().toUtc().isAfter(proximaActualizacion.toUtc());
  }
}
