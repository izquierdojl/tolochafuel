import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException({required this.mensaje, this.codigo, this.statusCode});

  final String mensaje;
  final String? codigo;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode, $codigo): $mensaje';
}

class ApiClient {
  ApiClient({http.Client? cliente, Uri? baseUrl})
    : _cliente = cliente ?? http.Client(),
      _baseUrl = baseUrl ?? Uri.parse('https://api.preciosgasolina.es');

  final http.Client _cliente;
  final Uri _baseUrl;

  Future<Map<String, dynamic>> getJson(
    String ruta, {
    Map<String, String>? parametros,
  }) async {
    final uri = _baseUrl.replace(path: ruta, queryParameters: parametros);
    final http.Response respuesta;
    try {
      respuesta = await _cliente
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const ApiException(
        mensaje: 'La conexión ha tardado demasiado. Inténtalo de nuevo.',
      );
    } catch (_) {
      throw const ApiException(
        mensaje:
            'No se pudo conectar con el servicio de precios. '
            'Comprueba tu conexión a internet.',
      );
    }

    if (respuesta.statusCode != 200) {
      throw _aExcepcion(respuesta);
    }

    final cuerpo = jsonDecode(utf8.decode(respuesta.bodyBytes));
    if (cuerpo is Map<String, dynamic>) {
      return cuerpo;
    }
    throw const ApiException(
      mensaje: 'La respuesta del servicio no tiene el formato esperado.',
    );
  }

  ApiException _aExcepcion(http.Response respuesta) {
    try {
      final problema = jsonDecode(utf8.decode(respuesta.bodyBytes));
      if (problema is Map<String, dynamic>) {
        final detalle = problema['detail'];
        return ApiException(
          mensaje: detalle is String && detalle.isNotEmpty
              ? detalle
              : 'El servicio de precios respondió con un error.',
          codigo: problema['code'] as String?,
          statusCode: respuesta.statusCode,
        );
      }
    } on FormatException {
      // El cuerpo no es problem+json: se usa el mensaje genérico de abajo.
    }
    if (respuesta.statusCode == 429) {
      return const ApiException(
        mensaje: 'Demasiadas peticiones seguidas. Espera unos segundos.',
        statusCode: 429,
      );
    }
    return ApiException(
      mensaje:
          'El servicio de precios no está disponible '
          '(${respuesta.statusCode}).',
      statusCode: respuesta.statusCode,
    );
  }
}
