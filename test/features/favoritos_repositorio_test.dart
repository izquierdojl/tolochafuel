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

  test('borrar elimina solo el favorito indicado', () async {
    final repositorio = FavoritosRepositorio();
    await repositorio.guardar(const [
      Favorito(id: 1, nombre: 'Una', lat: 40.4, lng: -3.7),
      Favorito(id: 2, nombre: 'Otra', lat: 40.5, lng: -3.8),
    ]);

    await repositorio.borrar(1);

    final restantes = await repositorio.cargar();
    expect(restantes, hasLength(1));
    expect(restantes.single.id, 2);
  });
}
