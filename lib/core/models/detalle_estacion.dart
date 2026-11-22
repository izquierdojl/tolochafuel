import 'meta_datos.dart';
import 'producto_precio.dart';

class DetalleEstacion {
  const DetalleEstacion({
    required this.productos,
    this.proximaActualizacion,
    this.meta,
    this.nombre,
    this.direccion,
    this.lat,
    this.lng,
    this.urlWeb,
  });

  final List<ProductoPrecio> productos;
  final DateTime? proximaActualizacion;
  final MetaDatos? meta;
  final String? nombre;
  final String? direccion;
  final double? lat;
  final double? lng;
  final String? urlWeb;
}
