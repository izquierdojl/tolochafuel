import '../models/meta_datos.dart';

String formatearPrecio(double? precio, {String unidad = 'L'}) {
  if (precio == null) return 'Sin precio';
  return '${precio.toStringAsFixed(3).replaceAll('.', ',')} €/$unidad';
}

String formatearDistancia(double? distanciaKm) {
  if (distanciaKm == null) return '';
  return 'a ${distanciaKm.toStringAsFixed(1).replaceAll('.', ',')} km';
}

String formatearFechaHora(DateTime fecha) {
  final local = fecha.toLocal();
  String dos(int valor) => valor.toString().padLeft(2, '0');
  return '${dos(local.day)}/${dos(local.month)}/${local.year} '
      '${dos(local.hour)}:${dos(local.minute)}';
}

String formatearFecha(DateTime fecha) {
  final local = fecha.toLocal();
  String dos(int valor) => valor.toString().padLeft(2, '0');
  return '${dos(local.day)}/${dos(local.month)}/${local.year}';
}

String formatearFechaCorta(DateTime fecha) {
  final local = fecha.toLocal();
  String dos(int valor) => valor.toString().padLeft(2, '0');
  return '${dos(local.day)}/${dos(local.month)}';
}

String textoFrescura(MetaDatos meta) {
  final partes = <String>[];
  final ultima = meta.ultimaActualizacion;
  if (ultima != null) {
    partes.add('Datos del ${formatearFechaHora(ultima)}');
  } else {
    partes.add('Datos oficiales actualizados 2 veces al día');
  }
  final edad = meta.antiguedadSegundos;
  if (edad != null) {
    if (edad < 120) {
      partes.add('hace unos segundos');
    } else if (edad < 3600) {
      partes.add('hace ${edad ~/ 60} min');
    } else {
      partes.add('hace ${edad ~/ 3600} h');
    }
  }
  return partes.join(' · ');
}
