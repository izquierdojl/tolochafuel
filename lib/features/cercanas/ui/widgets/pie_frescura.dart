import 'package:flutter/material.dart';

import '../../../../core/models/meta_datos.dart';
import '../../../../core/utilidades/formato.dart';

class PieFrescura extends StatelessWidget {
  const PieFrescura({super.key, this.meta});

  static const _metaVacio = MetaDatos(
    atribucion: MetaDatos.atribucionPorDefecto,
  );

  final MetaDatos? meta;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final stale = meta?.stale ?? false;
    final color = stale
        ? tema.colorScheme.tertiary
        : tema.colorScheme.onSurfaceVariant;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      decoration: BoxDecoration(
        color: tema.colorScheme.surfaceContainerHighest,
        border: Border(top: BorderSide(color: tema.colorScheme.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            textoFrescura(meta ?? _metaVacio),
            style: tema.textTheme.bodySmall?.copyWith(color: color),
          ),
          if (stale)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Pueden ser datos de la actualización anterior.',
                style: tema.textTheme.bodySmall?.copyWith(
                  color: tema.colorScheme.tertiary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
