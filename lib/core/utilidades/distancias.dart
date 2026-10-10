import 'dart:math';

double distanciaKmEntre(double lat1, double lng1, double lat2, double lng2) {
  const radioTierraKm = 6371.0;
  final dLat = _radianes(lat2 - lat1);
  final dLng = _radianes(lng2 - lng1);
  final a =
      pow(sin(dLat / 2), 2) +
      cos(_radianes(lat1)) * cos(_radianes(lat2)) * pow(sin(dLng / 2), 2);
  return radioTierraKm * 2 * atan2(sqrt(a), sqrt(1 - a));
}

double _radianes(double grados) => grados * pi / 180;
