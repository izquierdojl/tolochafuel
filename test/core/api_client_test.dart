import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tolochafuel/core/api/api_client.dart';

http.Client _clienteQueResponde(String cuerpo, int codigo) {
  return MockClient(
    (_) async => http.Response(
      cuerpo,
      codigo,
      headers: const {'content-type': 'application/json; charset=utf-8'},
    ),
  );
}

void main() {
  test('devuelve el sobre JSON en una respuesta 200', () async {
    final cliente = ApiClient(
      cliente: _clienteQueResponde(
        '{"data": {"stations": []}, "meta": {}}',
        200,
      ),
    );

    final cuerpo = await cliente.getJson('/v1/stations/nearby');

    expect(cuerpo['data'], isA<Map<String, dynamic>>());
  });

  test('convierte un error RFC 9457 en ApiException con detalle', () async {
    final cliente = ApiClient(
      cliente: _clienteQueResponde(
        '{"type":"https://docs.preciosgasolina.es/conceptos/errores/#station-not-found",'
        '"title":"No encontrado","status":404,'
        '"detail":"No existe la gasolinera 99999999.",'
        '"code":"STATION_NOT_FOUND"}',
        404,
      ),
    );

    await expectLater(
      cliente.getJson('/v1/stations/99999999'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 404)
            .having((e) => e.codigo, 'codigo', 'STATION_NOT_FOUND')
            .having((e) => e.mensaje, 'mensaje', contains('No existe')),
      ),
    );
  });

  test('mensaje específico para 429 sin cuerpo problem+json', () async {
    final cliente = ApiClient(
      cliente: _clienteQueResponde('demasiadas peticiones', 429),
    );

    await expectLater(
      cliente.getJson('/v1/prices'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 429)
            .having((e) => e.mensaje, 'mensaje', contains('Demasiadas')),
      ),
    );
  });

  test('error genérico para 5xx', () async {
    final cliente = ApiClient(cliente: _clienteQueResponde('boom', 503));

    await expectLater(
      cliente.getJson('/v1/prices'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 503)
            .having((e) => e.mensaje, 'mensaje', contains('503')),
      ),
    );
  });
}
