import 'meta_datos.dart';
import 'producto_precio.dart';

class DetalleEstacion {
  const DetalleEstacion({
    required this.productos,
    this.proximaActualizacion,
    this.meta,
  });

  final List<ProductoPrecio> productos;
  final DateTime? proximaActualizacion;
  final MetaDatos? meta;
}
