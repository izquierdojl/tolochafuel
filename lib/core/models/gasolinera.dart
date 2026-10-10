import '../utilidades/parseo.dart';
import 'producto_precio.dart';

class Gasolinera {
  const Gasolinera({
    required this.id,
    required this.nombre,
    required this.lat,
    required this.lng,
    required this.urlWeb,
    this.marca,
    this.direccion,
    this.municipio,
    this.precio,
    this.precioActualizadoEn,
    this.distanciaKm,
    this.abierta24h = false,
    this.horario,
    this.productos = const [],
  });

  final int id;
  final String nombre;
  final double lat;
  final double lng;
  final String urlWeb;
  final String? marca;
  final String? direccion;
  final String? municipio;
  final double? precio;
  final DateTime? precioActualizadoEn;
  final double? distanciaKm;
  final bool abierta24h;
  final String? horario;
  final List<ProductoPrecio> productos;

  factory Gasolinera.fromJson(Map<String, dynamic> json) {
    final nombre = json['name'];
    final marca = json['brand'];
    final municipio = json['municipality'];
    return Gasolinera(
      id: (json['id'] as num).toInt(),
      nombre: nombre is String && nombre.trim().isNotEmpty
          ? nombre.trim()
          : 'Sin rótulo',
      lat: aDouble(json['lat']) ?? 0,
      lng: aDouble(json['lng']) ?? 0,
      urlWeb: json['web_url'] as String? ?? '',
      marca: marca is Map<String, dynamic> ? marca['name'] as String? : null,
      direccion: json['address'] as String?,
      municipio: municipio is Map<String, dynamic>
          ? municipio['name'] as String?
          : null,
      precio: aDouble(json['price']),
      precioActualizadoEn: aFecha(json['price_updated_at']),
      distanciaKm: aDouble(json['distance_km']),
      abierta24h: json['is_24h'] == true,
      horario: json['hours'] as String?,
    );
  }

  Gasolinera conDistancia(double distancia) => _copiar(distanciaKm: distancia);

  Gasolinera conProductos(List<ProductoPrecio> productos) =>
      _copiar(productos: productos);

  Gasolinera _copiar({double? distanciaKm, List<ProductoPrecio>? productos}) {
    return Gasolinera(
      id: id,
      nombre: nombre,
      lat: lat,
      lng: lng,
      urlWeb: urlWeb,
      marca: marca,
      direccion: direccion,
      municipio: municipio,
      precio: precio,
      precioActualizadoEn: precioActualizadoEn,
      distanciaKm: distanciaKm ?? this.distanciaKm,
      abierta24h: abierta24h,
      horario: horario,
      productos: productos ?? this.productos,
    );
  }
}
