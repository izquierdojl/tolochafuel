import '../utilidades/parseo.dart';

class ProductoPrecio {
  const ProductoPrecio({
    required this.idApi,
    required this.etiqueta,
    required this.unidad,
    this.precio,
  });

  final String idApi;
  final String etiqueta;
  final String unidad;
  final double? precio;

  factory ProductoPrecio.fromJson(Map<String, dynamic> json) {
    final id = (json['fuel'] ?? json['product'] ?? json['id'] ?? '').toString();
    final etiqueta = json['label'] ?? json['name'] ?? id;
    return ProductoPrecio(
      idApi: id,
      etiqueta: etiqueta is String && etiqueta.trim().isNotEmpty
          ? etiqueta.trim()
          : 'Producto',
      unidad: json['unit'] as String? ?? 'L',
      precio: aDouble(json['price']),
    );
  }
}
