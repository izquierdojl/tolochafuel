import '../../../core/utilidades/formato.dart';
import '../data/aviso_notificacion.dart';
import '../data/aviso_precio.dart';
import 'navegacion_avisos.dart';

AvisoNotificacion formatearAviso({required AvisoPrecio aviso, String? alias}) {
  final titulo = alias == null || alias.trim().isEmpty
      ? aviso.nombre
      : alias.trim();
  final cambios = [for (final cambio in aviso.cambios) _lineaCambio(cambio)];
  final cuerpo = cambios.length == 1
      ? cambios.single
      : '${cambios.length} precios actualizados';
  final frescura = _frescura(aviso.lastUpdated, aviso.stale);
  return AvisoNotificacion(
    estacionId: aviso.estacionId,
    titulo: titulo,
    cuerpo: cuerpo,
    textoLargo: '${cambios.join('\n')}\n$frescura',
    payload: payloadEstacionAviso(
      EstacionAviso(id: aviso.estacionId, nombre: aviso.nombre),
    ),
    stale: aviso.stale,
  );
}

String _lineaCambio(CambioPrecio cambio) {
  final anterior = formatearPrecio(
    cambio.precioAnterior,
    unidad: cambio.unidad,
  );
  final actual = formatearPrecio(cambio.precioActual, unidad: cambio.unidad);
  return '${cambio.etiqueta}: $anterior → $actual';
}

String _frescura(DateTime? lastUpdated, bool stale) {
  final fecha = lastUpdated == null
      ? 'Datos oficiales actualizados 2 veces al día'
      : 'Datos del ${formatearFechaHora(lastUpdated)}';
  if (!stale) return fecha;
  return '$fecha\nPueden ser datos de la actualización anterior.';
}
