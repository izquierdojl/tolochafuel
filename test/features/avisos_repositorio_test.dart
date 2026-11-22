import 'package:flutter_test/flutter_test.dart';
import 'package:tolochafuel/features/avisos/data/avisos_repositorio.dart';
import 'package:tolochafuel/features/avisos/data/estado_avisos.dart';

import '../support/almacen_memoria.dart';

void main() {
  test('guarda y recupera estaciones, metadatos y bloqueo', () async {
    final almacen = AlmacenMemoria();
    final repositorio = AvisosRepositorio(almacen: almacen);
    final estado = EstadoAvisos(
      estaciones: {
        1: BasePrecios(
          precios: const {'gasoline_95': 1459, 'diesel': 1399},
          actualizadoEn: DateTime.utc(2026, 11, 22, 8, 12),
          lastUpdated: DateTime.utc(2026, 11, 22, 8),
        ),
      },
      ultimaComprobacion: DateTime.utc(2026, 11, 22, 8, 12),
      ultimoLastUpdated: DateTime.utc(2026, 11, 22, 8),
      proximaComprobacion: DateTime.utc(2026, 11, 22, 20),
      lockHasta: DateTime.utc(2026, 11, 22, 8, 17),
    );

    await repositorio.guardar(estado);
    final recargado = await repositorio.cargar();

    expect(recargado.estaciones[1]!.precios, {
      'gasoline_95': 1459,
      'diesel': 1399,
    });
    expect(recargado.estaciones[1]!.lastUpdated, DateTime.utc(2026, 11, 22, 8));
    expect(recargado.ultimaComprobacion, DateTime.utc(2026, 11, 22, 8, 12));
    expect(recargado.proximaComprobacion, DateTime.utc(2026, 11, 22, 20));
    expect(recargado.lockHasta, DateTime.utc(2026, 11, 22, 8, 17));
  });

  test('sin datos o con JSON corrupto devuelve un estado vacío', () async {
    expect(
      await AvisosRepositorio(almacen: AlmacenMemoria()).cargar(),
      isA<EstadoAvisos>(),
    );

    final almacen = AlmacenMemoria({AvisosRepositorio.clave: '{no es json'});
    final estado = await AvisosRepositorio(almacen: almacen).cargar();

    expect(estado.estaciones, isEmpty);
    expect(estado.ultimaComprobacion, isNull);
  });

  test(
    'ignora estaciones y precios inválidos sin perder las válidas',
    () async {
      final almacen = AlmacenMemoria({
        AvisosRepositorio.clave:
            '{"estaciones": {'
            '"1": {"precios": {"gasoline_95": 1459, "diesel": -1}, '
            '"actualizado_en": "2026-11-22T08:12:00Z"}, '
            '"sin-id": {"precios": {"diesel": 1399}}, '
            '"2": {"precios": {"diesel": 1399}}'
            '}}',
      });

      final estado = await AvisosRepositorio(almacen: almacen).cargar();

      expect(estado.estaciones.keys, containsAll([1, 2]));
      expect(estado.estaciones[1]!.precios, {'gasoline_95': 1459});
      expect(estado.estaciones[2]!.precios, {'diesel': 1399});
    },
  );

  test('el bloqueo evita comprobaciones simultáneas y caduca', () async {
    final repositorio = AvisosRepositorio(almacen: AlmacenMemoria());
    final ahora = DateTime.utc(2026, 11, 22, 8, 0);

    expect(
      await repositorio.adquirirBloqueo(
        ahora,
        duracion: const Duration(minutes: 5),
      ),
      isTrue,
    );
    expect(
      await repositorio.adquirirBloqueo(ahora.add(const Duration(minutes: 1))),
      isFalse,
    );
    expect(
      await repositorio.adquirirBloqueo(ahora.add(const Duration(minutes: 6))),
      isTrue,
    );

    await repositorio.liberarBloqueo();

    final estado = await repositorio.cargar();
    expect(estado.lockHasta, isNull);
  });

  test('reconciliar elimina bases que ya no tienen aviso', () async {
    final repositorio = AvisosRepositorio(almacen: AlmacenMemoria());
    final base = BasePrecios(
      precios: const {'diesel': 1399},
      actualizadoEn: DateTime.utc(2026, 11, 22),
    );
    await repositorio.guardarBase(1, base);
    await repositorio.guardarBase(2, base);

    expect(await repositorio.reconciliar({2}), isTrue);

    final estado = await repositorio.cargar();
    expect(estado.estaciones.keys, [2]);
  });

  test('guardarBase y eliminarBase conservan el resto del estado', () async {
    final repositorio = AvisosRepositorio(almacen: AlmacenMemoria());
    final base = BasePrecios(
      precios: const {'diesel': 1399},
      actualizadoEn: DateTime.utc(2026, 11, 22),
    );

    await repositorio.guardarBase(1, base);
    await repositorio.guardarBase(2, base);
    await repositorio.eliminarBase(1);

    final estado = await repositorio.cargar();
    expect(estado.estaciones.keys, [2]);
  });
}
