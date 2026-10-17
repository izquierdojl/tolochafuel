import 'package:flutter_test/flutter_test.dart';
import 'package:tolochafuel/core/models/gasolinera.dart';
import 'package:tolochafuel/features/alias/ui/nombre_mostrado.dart';

Gasolinera _gasolinera({
  String nombre = 'REPSOL',
  String? direccion = 'Calle Mayor, 1',
  String? municipio = 'Segovia',
}) => Gasolinera(
  id: 1,
  nombre: nombre,
  lat: 40.4,
  lng: -3.7,
  urlWeb: '',
  direccion: direccion,
  municipio: municipio,
);

void main() {
  test('sin alias usa el rótulo de la API y el subtítulo de siempre', () {
    final mostrado = nombreMostrado(_gasolinera(), null);

    expect(mostrado.titulo, 'REPSOL');
    expect(mostrado.subtitulo, 'Calle Mayor, 1 · Segovia');
  });

  test('con alias el título es el alias y el rótulo pasa al subtítulo', () {
    final mostrado = nombreMostrado(_gasolinera(), 'La de la rotonda');

    expect(mostrado.titulo, 'La de la rotonda');
    expect(mostrado.subtitulo, 'REPSOL · Calle Mayor, 1 · Segovia');
  });

  test('si el alias coincide con el rótulo no se duplica', () {
    final mostrado = nombreMostrado(_gasolinera(), 'REPSOL');

    expect(mostrado.titulo, 'REPSOL');
    expect(mostrado.subtitulo, 'Calle Mayor, 1 · Segovia');
  });

  test('sin rótulo en la API el alias no arrastra «Sin rótulo»', () {
    final mostrado = nombreMostrado(
      _gasolinera(nombre: 'Sin rótulo'),
      'La del polígono',
    );

    expect(mostrado.titulo, 'La del polígono');
    expect(mostrado.subtitulo, 'Calle Mayor, 1 · Segovia');
  });

  test('sin dirección ni municipio el subtítulo queda vacío', () {
    final mostrado = nombreMostrado(
      _gasolinera(nombre: 'Sin rótulo', direccion: null, municipio: null),
      'La del polígono',
    );

    expect(mostrado.titulo, 'La del polígono');
    expect(mostrado.subtitulo, isEmpty);
  });

  test('un alias en blanco se trata como ausente', () {
    final mostrado = nombreMostrado(_gasolinera(), '   ');

    expect(mostrado.titulo, 'REPSOL');
    expect(mostrado.subtitulo, 'Calle Mayor, 1 · Segovia');
  });
}
