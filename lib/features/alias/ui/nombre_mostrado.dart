import '../../../core/models/gasolinera.dart';

const sinRotulo = 'Sin rótulo';

class NombreMostrado {
  const NombreMostrado({required this.titulo, required this.subtitulo});

  final String titulo;
  final String subtitulo;
}

NombreMostrado nombreMostrado(Gasolinera gasolinera, String? alias) {
  final recortado = alias?.trim();
  final efectivo = recortado == null || recortado.isEmpty ? null : recortado;
  final subtitulo = [
    if (efectivo != null &&
        gasolinera.nombre != sinRotulo &&
        gasolinera.nombre != efectivo)
      gasolinera.nombre,
    if (gasolinera.direccion != null) gasolinera.direccion!,
    if (gasolinera.municipio != null) gasolinera.municipio!,
  ].join(' · ');
  return NombreMostrado(
    titulo: efectivo ?? gasolinera.nombre,
    subtitulo: subtitulo,
  );
}
