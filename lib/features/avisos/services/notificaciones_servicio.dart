import '../data/aviso_notificacion.dart';

abstract class NotificacionesServicio {
  Future<void> inicializar({required void Function(String? payload) alTocar});

  Future<String?> lanzamientoInicial();

  Future<bool> solicitarPermiso();

  Future<bool> estanHabilitadas();

  Future<bool> mostrar(AvisoNotificacion aviso);

  Future<void> cancelar(int id);

  Future<void> cancelarTodas();
}

class NotificacionesNulas implements NotificacionesServicio {
  const NotificacionesNulas();

  @override
  Future<void> cancelar(int id) async {}

  @override
  Future<void> cancelarTodas() async {}

  @override
  Future<bool> estanHabilitadas() async => true;

  @override
  Future<void> inicializar({
    required void Function(String? payload) alTocar,
  }) async {}

  @override
  Future<String?> lanzamientoInicial() async => null;

  @override
  Future<bool> mostrar(AvisoNotificacion aviso) async => false;

  @override
  Future<bool> solicitarPermiso() async => true;
}
