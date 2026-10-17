import '../../../core/models/carburante.dart';
import '../../../core/models/gasolinera.dart';

double? mediaCarburantes(Gasolinera gasolinera) {
  final precios = [
    for (final producto in gasolinera.productos)
      if (producto.precio != null &&
          producto.unidad == 'L' &&
          Carburante.desdeIdApi(producto.idApi) != null)
        producto.precio!,
  ];
  if (precios.isEmpty) return null;
  return precios.reduce((a, b) => a + b) / precios.length;
}

List<Gasolinera> ordenarPorMedia(Iterable<Gasolinera> gasolineras) {
  final medias = <Gasolinera, double>{};
  for (final gasolinera in gasolineras) {
    final media = mediaCarburantes(gasolinera);
    if (media != null) medias[gasolinera] = media;
  }
  final ordenadas = medias.keys.toList()
    ..sort((a, b) => medias[a]!.compareTo(medias[b]!));
  return ordenadas;
}
