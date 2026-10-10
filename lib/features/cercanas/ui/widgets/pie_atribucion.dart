import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/models/meta_datos.dart';
import '../../../../core/utilidades/formato.dart';

class PieAtribucion extends StatelessWidget {
  const PieAtribucion({super.key, required this.meta});

  final MetaDatos? meta;

  Future<void> _abrirEnlace(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      // Sin navegador disponible: la atribución como texto sigue visible.
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    final datos = meta;
    final estilo = tema.textTheme.bodySmall?.copyWith(
      color: esquema.onSurfaceVariant,
    );

    return Material(
      color: esquema.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (datos != null && datos.stale)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'La fuente no respondió: puede que los datos sean de una '
                  'actualización anterior.',
                  style: estilo?.copyWith(color: esquema.error),
                ),
              ),
            InkWell(
              onTap: () =>
                  _abrirEnlace(datos?.webUrl ?? 'https://preciosgasolina.es'),
              child: Row(
                children: [
                  Icon(Icons.open_in_new, size: 14, color: esquema.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      datos?.atribucion ?? MetaDatos.atribucionPorDefecto,
                      style: estilo,
                    ),
                  ),
                ],
              ),
            ),
            if (datos != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(textoFrescura(datos), style: estilo),
              ),
          ],
        ),
      ),
    );
  }
}
