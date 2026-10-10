import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tolochafuel/core/models/gasolinera.dart';
import 'package:tolochafuel/core/services/navegacion.dart';

Gasolinera _gasolinera() => const Gasolinera(
  id: 3213,
  nombre: 'Ballenoil Segovia',
  lat: 40.41025,
  lng: -3.717528,
  urlWeb: '',
);

void main() {
  const navegacion = Navegacion();

  test('en Android construye un intent geo con coordenadas y rótulo', () {
    final uri = navegacion.uriParaNavegar(
      _gasolinera(),
      plataforma: TargetPlatform.android,
    );

    expect(uri.scheme, 'geo');
    expect(uri.path, '0,0');
    expect(uri.query, contains('40.41025,-3.717528'));
    expect(Uri.decodeComponent(uri.query), contains('Ballenoil Segovia'));
  });

  test('en escritorio construye la URL de Google Maps con el destino', () {
    final uri = navegacion.uriParaNavegar(
      _gasolinera(),
      plataforma: TargetPlatform.windows,
    );

    expect(uri.scheme, 'https');
    expect(uri.host, 'www.google.com');
    expect(uri.path, '/maps/dir/');
    expect(uri.queryParameters['api'], '1');
    expect(uri.queryParameters['destination'], '40.41025,-3.717528');
    expect(uri.queryParameters['travelmode'], 'driving');
  });
}
