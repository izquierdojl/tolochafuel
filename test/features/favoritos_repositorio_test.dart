import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tolochafuel/features/favoritos/data/favorito.dart';
import 'package:tolochafuel/features/favoritos/data/favoritos_repositorio.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('guarda y vuelve a cargar los favoritos con sus datos', () async {
    final repositorio = FavoritosRepositorio();
    await repositorio.guardar(const [
      Favorito(
        id: 1,
        nombre: 'Ballenoil Segovia',
        lat: 40.41,
        lng: -3.71,
        direccion: 'Calle de la Estación, 12',
      ),
      Favorito(id: 2, nombre: 'Repsol', lat: 40.42, lng: -3.72),
    ]);

    final recargados = await FavoritosRepositorio().cargar();

    expect(recargados, hasLength(2));
    expect(recargados[0].id, 1);
    expect(recargados[0].nombre, 'Ballenoil Segovia');
    expect(recargados[0].direccion, 'Calle de la Estación, 12');
    expect(recargados[0].lat, closeTo(40.41, 0.0001));
    expect(recargados[1].id, 2);
    expect(recargados[1].direccion, isNull);
  });

  test('ignora entradas inválidas y datos corruptos', () async {
    SharedPreferences.setMockInitialValues({
      FavoritosRepositorio.clave:
          '[{"id": 1, "nombre": "Válida", "lat": 40.4, "lng": -3.7}, '
          '{"nombre": "Sin id", "lat": 40.4, "lng": -3.7}, '
          '"texto suelto", 7]',
    });
    final repositorio = FavoritosRepositorio();
    expect(await repositorio.cargar(), hasLength(1));

    SharedPreferences.setMockInitialValues({
      FavoritosRepositorio.clave: '{no es json',
    });
    expect(await FavoritosRepositorio().cargar(), isEmpty);
  });

  test('conserva el orden en que se guardan los favoritos', () async {
    await FavoritosRepositorio().guardar(const [
      Favorito(id: 3, nombre: 'Tercera', lat: 40.3, lng: -3.6),
      Favorito(id: 1, nombre: 'Primera', lat: 40.4, lng: -3.7),
      Favorito(id: 2, nombre: 'Segunda', lat: 40.5, lng: -3.8),
    ]);

    final recargados = await FavoritosRepositorio().cargar();

    expect(recargados.map((favorito) => favorito.id), [3, 1, 2]);
  });

  test('guarda el estado de aviso y tolera favoritos antiguos', () async {
    await FavoritosRepositorio().guardar(const [
      Favorito(
        id: 1,
        nombre: 'Con aviso',
        lat: 40.4,
        lng: -3.7,
        avisosPrecio: true,
      ),
      Favorito(id: 2, nombre: 'Sin aviso', lat: 40.5, lng: -3.8),
    ]);

    final recargados = await FavoritosRepositorio().cargar();

    expect(recargados[0].avisosPrecio, isTrue);
    expect(recargados[1].avisosPrecio, isFalse);

    SharedPreferences.setMockInitialValues({
      FavoritosRepositorio.clave:
          '[{"id": 1, "nombre": "Antigua", "lat": 40.4, "lng": -3.7}]',
    });
    final antiguos = await FavoritosRepositorio().cargar();

    expect(antiguos.single.avisosPrecio, isFalse);
  });

  test('cargarAsync devuelve los mismos datos que cargar', () async {
    await FavoritosRepositorio().guardar(const [
      Favorito(
        id: 1,
        nombre: 'Con aviso',
        lat: 40.4,
        lng: -3.7,
        avisosPrecio: true,
      ),
    ]);

    final recargados = await FavoritosRepositorio().cargarAsync();

    expect(recargados.single.id, 1);
    expect(recargados.single.avisosPrecio, isTrue);
  });
}
