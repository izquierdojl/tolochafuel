import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/models/gasolinera.dart';
import '../../../../core/models/historico_estacion.dart';
import '../../../../core/models/producto_precio.dart';
import '../../../../core/services/navegacion.dart';
import '../../../../core/utilidades/formato.dart';
import '../../../alias/ui/alias_controller.dart';
import '../../../alias/ui/dialogo_alias.dart';
import '../../../alias/ui/nombre_mostrado.dart';
import '../../../favoritos/ui/favoritos_controller.dart';
import '../historial_controller.dart';
import 'detalle_historico.dart';
import 'flecha_tendencia.dart';

enum _AccionTarjeta { alias }

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

  Future<void> _abrirAlias() async {
    final gasolinera = widget.gasolinera;
    final aliasController = context.read<AliasController>();
    final texto = await showDialog<String>(
      context: context,
      builder: (_) => DialogoAlias(
        nombreApi: gasolinera.nombre,
        aliasActual: aliasController.aliasDe(gasolinera.id),
      ),
    );
    if (texto == null || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final guardado = await aliasController.guardar(gasolinera.id, texto);
    if (!guardado) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar el alias en este dispositivo.'),
        ),
      );
    }
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
    final alias = context.watch<AliasController>().aliasDe(gasolinera.id);
    final mostrado = nombreMostrado(gasolinera, alias);
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
                    mostrado.titulo,
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
                PopupMenuButton<_AccionTarjeta>(
                  tooltip: 'Más acciones',
                  iconSize: 20,
                  icon: Icon(Icons.more_vert, color: esquema.onSurfaceVariant),
                  onSelected: (_) => _abrirAlias(),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _AccionTarjeta.alias,
                      child: Text(
                        alias == null ? 'Poner alias…' : 'Editar alias…',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (mostrado.subtitulo.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(mostrado.subtitulo, style: estiloSecundario),
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
              FlechaTendencia(tendencia: tendencia, colores: colores!),
            ],
          ],
        ),
      ),
    );
  }
}
