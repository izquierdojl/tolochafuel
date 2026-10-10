double? aDouble(dynamic valor) {
  if (valor == null) return null;
  if (valor is num) return valor.toDouble();
  final texto = valor.toString().trim().replaceAll(',', '.');
  if (texto.isEmpty || texto == '-') return null;
  return double.tryParse(texto);
}

DateTime? aFecha(dynamic valor) {
  if (valor is! String || valor.isEmpty) return null;
  return DateTime.tryParse(valor);
}

int? aEntero(dynamic valor) {
  if (valor is num) return valor.toInt();
  if (valor is String) return int.tryParse(valor.trim());
  return null;
}
