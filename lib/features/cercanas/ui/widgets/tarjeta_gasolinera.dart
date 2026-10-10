import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/models/gasolinera.dart';
import '../../../../core/models/historico_estacion.dart';
import '../../../../core/models/producto_precio.dart';
import '../../../../core/services/navegacion.dart';
import '../../../../core/utilidades/formato.dart';
import '../../../favoritos/ui/favoritos_controller.dart';
import '../historial_controller.dart';
import 'detalle_historico.dart';

class TarjetaGasolinera extends StatefulWidget {
  const TarjetaGasolinera({super.key, required this.gasolinera});

  final Gasolinera gasolinera;

  @override
  State<TarjetaGasolinera> createState() => _TarjetaGasolineraState();
}

class _TarjetaGasolineraState extends State<TarjetaGasolinera> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HistorialController?>()?.cargar(widget.gasolinera.id);
    });
  }

  void _abrirHistorico() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => DetalleHistorico(
        gasolinera: widget.gasolinera,
        productos: widget.gasolinera.productos,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gasolinera = widget.gasolinera;
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    final colores = tema.extension<ColoresTendencia>();
    final esFavorito = context.watch<FavoritosController>().esFavorito(
      gasolinera.id,
    );
    final historial = context.watch<HistorialController?>();
    final historico = historial?.historico(gasolinera.id);
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
                IconButton(
                  tooltip: 'Navegar',
                  visualDensity: VisualDensity.compact,
                  iconSize: 20,
                  color: esquema.onSurfaceVariant,
                  icon: const Icon(Icons.directions),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final abierto = await const Navegacion().abrirDestino(
                      gasolinera,
                    );
                    if (!abierto) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'No se pudo abrir la aplicación de mapas.',
                          ),
                        ),
                      );
                    }
                  },
                ),
                IconButton(
                  tooltip: esFavorito
                      ? 'Quitar de favoritos'
                      : 'Añadir a favoritos',
                  visualDensity: VisualDensity.compact,
                  iconSize: 20,
                  color: esFavorito
                      ? esquema.primary
                      : esquema.onSurfaceVariant,
                  icon: Icon(
                    esFavorito ? Icons.favorite : Icons.favorite_border,
                  ),
                  onPressed: () =>
                      context.read<FavoritosController>().alternar(gasolinera),
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
                _FilaPrecio(
                  producto: producto,
                  tendencia:
                      historico?.serie(producto.idApi)?.tendencia ??
                      Tendencia.desconocida,
                  colores: colores,
                  onAbrir: historial == null ? null : _abrirHistorico,
                ),
          ],
        ),
      ),
    );
  }
}

class _FilaPrecio extends StatelessWidget {
  const _FilaPrecio({
    required this.producto,
    required this.tendencia,
    required this.colores,
    required this.onAbrir,
  });

  final ProductoPrecio producto;
  final Tendencia tendencia;
  final ColoresTendencia? colores;
  final VoidCallback? onAbrir;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    return InkWell(
      onTap: onAbrir,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
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
              formatearPrecio(producto.precio, unidad: producto.unidad),
              style: tema.textTheme.bodyMedium?.copyWith(
                color: esquema.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (colores != null && tendencia != Tendencia.desconocida) ...[
              const SizedBox(width: 6),
              _FlechaTendencia(tendencia: tendencia, colores: colores!),
            ],
          ],
        ),
      ),
    );
  }
}

class _FlechaTendencia extends StatelessWidget {
  const _FlechaTendencia({required this.tendencia, required this.colores});

  final Tendencia tendencia;
  final ColoresTendencia colores;

  @override
  Widget build(BuildContext context) {
    switch (tendencia) {
      case Tendencia.baja:
        return Icon(
          Icons.arrow_downward,
          size: 14,
          color: colores.bajada,
          semanticLabel: 'Precio a la baja',
        );
      case Tendencia.sube:
        return Icon(
          Icons.arrow_upward,
          size: 14,
          color: colores.subida,
          semanticLabel: 'Precio al alza',
        );
      case Tendencia.igual:
        return Text('=', style: TextStyle(color: colores.neutra, fontSize: 14));
      case Tendencia.desconocida:
        return const SizedBox.shrink();
    }
  }
}
