import '../../../core/models/carburante.dart';
import '../../../core/models/producto_precio.dart';
import '../data/aviso_precio.dart';

Map<String, int> preciosDesdeProductos(List<ProductoPrecio> productos) {
  final precios = <String, int>{};
  for (final producto in productos) {
    if (Carburante.desdeIdApi(producto.idApi) == null) continue;
    final precio = producto.precio;
    if (precio == null || precio <= 0) continue;
    precios[producto.idApi] = (precio * 1000).round();
  }
  return precios;
}

List<CambioPrecio> calcularCambios({
  required Map<String, int> base,
  required List<ProductoPrecio> productos,
}) {
  final actuales = <String, ProductoPrecio>{};
  for (final producto in productos) {
    if (Carburante.desdeIdApi(producto.idApi) == null) continue;
    final precio = producto.precio;
    if (precio == null || precio <= 0) continue;
    actuales[producto.idApi] = producto;
  }

  final cambios = <CambioPrecio>[];
  for (final carburante in Carburante.values) {
    final anterior = base[carburante.idApi];
    final producto = actuales[carburante.idApi];
    if (anterior == null || producto == null) continue;
    final actual = (producto.precio! * 1000).round();
    if (actual == anterior) continue;
    cambios.add(
      CambioPrecio(
        idApi: producto.idApi,
        etiqueta: producto.etiqueta,
        unidad: producto.unidad,
        anterior: anterior,
        actual: actual,
      ),
    );
  }
  return cambios;
}
