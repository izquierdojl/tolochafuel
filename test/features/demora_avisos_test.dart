import 'package:flutter_test/flutter_test.dart';
import 'package:tolochafuel/features/avisos/services/demora_avisos.dart';

void main() {
  final ahora = DateTime.utc(2026, 11, 22, 8);

  test('una fecha futura añade el margen de cinco minutos', () {
    final demora = calcularDemoraAvisos(
      proxima: DateTime.utc(2026, 11, 22, 20),
      ahora: ahora,
    );

    expect(demora, const Duration(hours: 12, minutes: 5));
  });

  test('una fecha pasada reintenta en una hora', () {
    final demora = calcularDemoraAvisos(
      proxima: DateTime.utc(2026, 11, 22, 7, 50),
      ahora: ahora,
    );

    expect(demora, reintentoAvisos);
  });

  test('sin fecha usa el respaldo de doce horas', () {
    expect(calcularDemoraAvisos(ahora: ahora), respaldoAvisos);
  });

  test('una fecha demasiado cercana respeta el mínimo de quince minutos', () {
    final demora = calcularDemoraAvisos(
      proxima: ahora.add(const Duration(minutes: 2)),
      ahora: ahora,
    );

    expect(demora, demoraMinimaAvisos);
  });
}
