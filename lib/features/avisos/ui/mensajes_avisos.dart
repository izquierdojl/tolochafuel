import 'package:material_ui/material_ui.dart';

import 'avisos_controller.dart';

Future<void> mostrarResultadoAviso(
  BuildContext context,
  ResultadoAviso resultado,
) async {
  final (String, String)? datos = switch (resultado) {
    ResultadoAviso.activado => (
      'Avisos activados',
      'Te avisaremos cuando cambien los precios de esta gasolinera. '
          'Los datos se actualizan 2 veces al día.',
    ),
    ResultadoAviso.activadoSinBase => (
      'Aviso activado',
      'Se comprobará el precio cuando haya conexión. '
          'Los datos se actualizan 2 veces al día.',
    ),
    ResultadoAviso.permisoDenegado => (
      'Notificaciones desactivadas',
      'Para recibir avisos, activa las notificaciones de TolochaFuel en los '
          'ajustes del sistema.',
    ),
    ResultadoAviso.notificacionesDesactivadas => (
      'Notificaciones desactivadas',
      'Las notificaciones están desactivadas en el sistema. Actívalas para '
          'recibir avisos.',
    ),
    ResultadoAviso.noFavorito => (
      'Gasolinera no favorita',
      'Esta gasolinera ya no está en favoritos.',
    ),
    ResultadoAviso.error => (
      'No se pudo activar el aviso',
      'No se pudieron guardar los avisos en este dispositivo.',
    ),
    _ => null,
  };
  if (datos == null) return;
  final (titulo, mensaje) = datos;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Entendido'),
        ),
      ],
    ),
  );
}
