class CambioPrecio {
  const CambioPrecio({
    required this.idApi,
    required this.etiqueta,
    required this.unidad,
    required this.anterior,
    required this.actual,
  });

  final String idApi;
  final String etiqueta;
  final String unidad;
  final int anterior;
  final int actual;

  bool get sube => actual > anterior;

  double get precioAnterior => anterior / 1000;

  double get precioActual => actual / 1000;
}

class AvisoPrecio {
  const AvisoPrecio({
    required this.estacionId,
    required this.nombre,
    required this.cambios,
    this.lastUpdated,
    this.stale = false,
  });

  final int estacionId;
  final String nombre;
  final List<CambioPrecio> cambios;
  final DateTime? lastUpdated;
  final bool stale;
}
