class Lugar {
  const Lugar({
    required this.nombre,
    required this.nivel,
    required this.codigo,
    this.detalle,
  });

  final String nombre;
  final String nivel;
  final String codigo;
  final String? detalle;

  String get etiquetaCompleta =>
      detalle == null ? nombre : '$nombre · $detalle';

  factory Lugar.fromJson(Map<String, dynamic> json) {
    return Lugar(
      nombre: json['name'] as String,
      nivel: json['level'] as String,
      codigo: json['code'] as String,
      detalle: json['detail'] as String?,
    );
  }
}
