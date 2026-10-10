import '../utilidades/parseo.dart';

class MetaDatos {
  const MetaDatos({
    required this.atribucion,
    this.ultimaActualizacion,
    this.proximaActualizacion,
    this.antiguedadSegundos,
    this.stale = false,
    this.webUrl,
  });

  static const atribucionPorDefecto =
      'Gasolina hoy (preciosgasolina.es), con datos del Ministerio para la '
      'Transición Ecológica y el Reto Demográfico';

  final String atribucion;
  final DateTime? ultimaActualizacion;
  final DateTime? proximaActualizacion;
  final int? antiguedadSegundos;
  final bool stale;
  final String? webUrl;

  factory MetaDatos.fromJson(Map<String, dynamic> json) {
    final atribucion = json['attribution'];
    return MetaDatos(
      atribucion: atribucion is String && atribucion.trim().isNotEmpty
          ? atribucion.trim()
          : atribucionPorDefecto,
      ultimaActualizacion: aFecha(json['last_updated']),
      proximaActualizacion: aFecha(json['next_update']),
      antiguedadSegundos: aEntero(json['data_age_seconds']),
      stale: json['stale'] == true,
      webUrl: json['web_url'] as String?,
    );
  }
}
