import 'producto_precio.dart';

class DetalleEstacion {
  const DetalleEstacion({required this.productos, this.proximaActualizacion});

  final List<ProductoPrecio> productos;
  final DateTime? proximaActualizacion;
}
