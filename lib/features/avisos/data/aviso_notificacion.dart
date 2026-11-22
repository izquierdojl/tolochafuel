class EstacionAviso {
  const EstacionAviso({required this.id, required this.nombre});

  final int id;
  final String nombre;
}

class AvisoNotificacion {
  const AvisoNotificacion({
    required this.estacionId,
    required this.titulo,
    required this.cuerpo,
    required this.textoLargo,
    required this.payload,
    this.stale = false,
  });

  final int estacionId;
  final String titulo;
  final String cuerpo;
  final String textoLargo;
  final String payload;
  final bool stale;
}

class ResultadoComprobacion {
  const ResultadoComprobacion({
    this.avisos = const [],
    this.avisosEnApp = const [],
    this.peticiones = 0,
    this.omitida = false,
    this.error,
  });

  final List<AvisoNotificacion> avisos;
  final List<AvisoNotificacion> avisosEnApp;
  final int peticiones;
  final bool omitida;
  final String? error;

  static const vacio = ResultadoComprobacion(omitida: true);
}
