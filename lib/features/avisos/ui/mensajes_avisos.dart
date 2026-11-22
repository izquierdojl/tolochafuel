import 'package:material_ui/material_ui.dart';

import 'avisos_controller.dart';

void mostrarResultadoAviso(BuildContext context, ResultadoAviso resultado) {
  final mensaje = switch (resultado) {
    ResultadoAviso.activadoSinBase =>
      'Aviso activado. Se comprobará el precio cuando haya conexión.',
    ResultadoAviso.permisoDenegado =>
      'Para recibir avisos, activa las notificaciones de TolochaFuel en los '
          'ajustes del sistema.',
    ResultadoAviso.notificacionesDesactivadas =>
      'Las notificaciones están desactivadas en el sistema. Actívalas para '
          'recibir avisos.',
    ResultadoAviso.noFavorito => 'Esta gasolinera ya no está en favoritos.',
    ResultadoAviso.error =>
      'No se pudieron guardar los avisos en este dispositivo.',
    _ => null,
  };
  if (mensaje == null) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
}
