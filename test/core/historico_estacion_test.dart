import 'package:flutter_test/flutter_test.dart';
import 'package:tolochafuel/core/models/historico_estacion.dart';

Map<String, dynamic> _json() => {
  'series': [
    {
      'fuel': 'gasoline_95',
      'unit': 'L',
      'points': [
        {'date': '2026-10-08', 'price': 1.729},
        {'date': '2026-10-06', 'price': 1.739},
        {'date': '2026-10-10', 'price': 1.719},
      ],
    },
    {
      'fuel': 'diesel',
      'unit': 'L',
      'points': [
        {'date': '2026-10-06', 'price': 1.859},
        {'date': '2026-10-10', 'price': 1.869},
      ],
    },
    {'fuel': 'sin-puntos', 'points': []},
  ],
};

void main() {
  test('parsea las series y ordena los puntos por fecha', () {
    final historico = HistoricoEstacion.fromJson(_json());

    expect(historico.series, hasLength(2));
    final gasolina = historico.serie('gasoline_95')!;
    expect(gasolina.puntos.map((p) => p.precio), [1.739, 1.729, 1.719]);
    expect(gasolina.puntos.first.fecha, DateTime(2026, 10, 6));
  });

  test('la tendencia usa la última variación registrada', () {
    final historico = HistoricoEstacion.fromJson(_json());

    expect(historico.serie('gasoline_95')!.tendencia, Tendencia.baja);
    expect(historico.serie('diesel')!.tendencia, Tendencia.sube);

    final variacion = historico.serie('gasoline_95')!.variacion;
    expect(variacion.delta, closeTo(-0.010, 0.0001));
    expect(variacion.desde, DateTime(2026, 10, 10));
  });

  test('lista solo los días con cambio y limita a los últimos cinco', () {
    final historico = HistoricoEstacion.fromJson(_json());

    final gasolina = historico.serie('gasoline_95')!;
    expect(gasolina.cambios().map((p) => p.fecha), [
      DateTime(2026, 10, 8),
      DateTime(2026, 10, 10),
    ]);
    expect(gasolina.cambios().map((p) => p.precio), [1.729, 1.719]);

    final plana = SerieCarburante(
      idApi: 'gasoline_95',
      puntos: [
        PuntoPrecio(fecha: DateTime(2026, 10, 8), precio: 1.7),
        PuntoPrecio(fecha: DateTime(2026, 10, 9), precio: 1.7),
        PuntoPrecio(fecha: DateTime(2026, 10, 10), precio: 1.7),
      ],
    );
    expect(plana.cambios(), isEmpty);

    final muchas = SerieCarburante(
      idApi: 'gasoline_95',
      puntos: [
        for (var i = 0; i < 8; i++)
          PuntoPrecio(
            fecha: DateTime(2026, 10, 1 + i),
            precio: 1.70 + i * 0.01,
          ),
      ],
    );
    expect(muchas.cambios(), hasLength(5));
    expect(muchas.cambios().first.precio, closeTo(1.73, 0.001));
    expect(muchas.cambios().last.precio, closeTo(1.77, 0.001));
  });

  test('detecta la variación aunque los últimos días estén planos', () {
    final bajada = SerieCarburante(
      idApi: 'gasoline_95',
      puntos: [
        PuntoPrecio(fecha: DateTime(2026, 10, 6), precio: 1.709),
        PuntoPrecio(fecha: DateTime(2026, 10, 7), precio: 1.679),
        PuntoPrecio(fecha: DateTime(2026, 10, 8), precio: 1.679),
        PuntoPrecio(fecha: DateTime(2026, 10, 9), precio: 1.679),
        PuntoPrecio(fecha: DateTime(2026, 10, 10), precio: 1.679),
      ],
    );
    expect(bajada.tendencia, Tendencia.baja);
    expect(bajada.variacion.desde, DateTime(2026, 10, 7));

    final subida = SerieCarburante(
      idApi: 'gasoline_95',
      puntos: [
        PuntoPrecio(fecha: DateTime(2026, 10, 8), precio: 1.749),
        PuntoPrecio(fecha: DateTime(2026, 10, 9), precio: 1.759),
        PuntoPrecio(fecha: DateTime(2026, 10, 10), precio: 1.759),
      ],
    );
    expect(subida.tendencia, Tendencia.sube);
  });

  test('sin cambios o sin puntos devuelve igual o desconocida', () {
    final igual = HistoricoEstacion.fromJson({
      'series': [
        {
          'fuel': 'gasoline_95',
          'points': [
            {'date': '2026-10-09', 'price': 1.729},
            {'date': '2026-10-10', 'price': 1.729},
          ],
        },
      ],
    });
    expect(igual.serie('gasoline_95')!.tendencia, Tendencia.igual);
    expect(igual.serie('gasoline_95')!.variacion.delta, 0.0);

    final vacio = HistoricoEstacion.fromJson(const {});
    expect(vacio.series, isEmpty);
  });

  test('tolera puntos inválidos y campos ausentes', () {
    final historico = HistoricoEstacion.fromJson({
      'series': [
        {
          'fuel': 'gasoline_95',
          'points': [
            {'date': '2026-10-10'},
            {'price': 1.7},
            {'date': '2026-10-10', 'price': '1,719'},
          ],
        },
        'no-es-mapa',
      ],
    });

    final gasolina = historico.serie('gasoline_95')!;
    expect(gasolina.puntos, hasLength(1));
    expect(gasolina.puntos.single.precio, 1.719);
  });
}
