import 'package:flutter/material.dart';

import '../../../../core/models/gasolinera.dart';
import '../../../../core/utilidades/formato.dart';

class TarjetaGasolinera extends StatelessWidget {
  const TarjetaGasolinera({super.key, required this.gasolinera});

  final Gasolinera gasolinera;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    final subtitulo = [
      if (gasolinera.direccion != null) gasolinera.direccion!,
      if (gasolinera.municipio != null) gasolinera.municipio!,
    ].join(' · ');
    final estiloSecundario = tema.textTheme.bodySmall?.copyWith(
      color: esquema.onSurfaceVariant,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    gasolinera.nombre,
                    style: tema.textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (gasolinera.abierta24h) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: esquema.secondaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '24h',
                      style: tema.textTheme.labelSmall?.copyWith(
                        color: esquema.onSecondaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (gasolinera.distanciaKm != null)
                  Text(
                    formatearDistancia(gasolinera.distanciaKm),
                    style: estiloSecundario,
                  ),
              ],
            ),
            if (subtitulo.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(subtitulo, style: estiloSecundario),
            ],
            const SizedBox(height: 8),
            if (gasolinera.productos.isEmpty)
              Text('Precios no disponibles', style: estiloSecundario)
            else
              for (final producto in gasolinera.productos)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          producto.etiqueta,
                          style: tema.textTheme.bodySmall?.copyWith(
                            color: esquema.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        formatearPrecio(
                          producto.precio,
                          unidad: producto.unidad,
                        ),
                        style: tema.textTheme.bodyMedium?.copyWith(
                          color: esquema.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
