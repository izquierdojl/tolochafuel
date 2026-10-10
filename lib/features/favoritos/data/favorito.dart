import '../../../core/models/gasolinera.dart';
import '../../../core/utilidades/parseo.dart';

class Favorito {
  const Favorito({
    required this.id,
    required this.nombre,
    required this.lat,
    required this.lng,
    this.direccion,
  });

  final int id;
  final String nombre;
  final double lat;
  final double lng;
  final String? direccion;

  factory Favorito.desdeGasolinera(Gasolinera gasolinera) => Favorito(
    id: gasolinera.id,
    nombre: gasolinera.nombre,
    lat: gasolinera.lat,
    lng: gasolinera.lng,
    direccion: gasolinera.direccion,
  );

  static Favorito? fromJson(Map<String, dynamic> json) {
    final id = aEntero(json['id']);
    final lat = aDouble(json['lat']);
    final lng = aDouble(json['lng']);
    if (id == null || lat == null || lng == null) return null;
    final nombre = json['nombre'];
    final direccion = json['direccion'];
    return Favorito(
      id: id,
      nombre: nombre is String && nombre.trim().isNotEmpty
          ? nombre.trim()
          : 'Sin rótulo',
      lat: lat,
      lng: lng,
      direccion: direccion is String && direccion.trim().isNotEmpty
          ? direccion.trim()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'lat': lat,
    'lng': lng,
    'direccion': direccion,
  };

  Gasolinera aGasolinera() => Gasolinera(
    id: id,
    nombre: nombre,
    lat: lat,
    lng: lng,
    urlWeb: '',
    direccion: direccion,
  );
}
