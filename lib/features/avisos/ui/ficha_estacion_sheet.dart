import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/models/detalle_estacion.dart';
import '../../../core/models/gasolinera.dart';
import '../../../core/models/historico_estacion.dart';
import '../../../core/models/producto_precio.dart';
import '../../../core/services/navegacion.dart';
import '../../../core/utilidades/formato.dart';
import '../../alias/ui/alias_controller.dart';
import '../../alias/ui/nombre_mostrado.dart';
import '../../avisos/data/aviso_notificacion.dart';
import '../../avisos/ui/avisos_controller.dart';
import '../../avisos/ui/mensajes_avisos.dart';
import '../../cercanas/ui/historial_controller.dart';
import '../../cercanas/ui/widgets/flecha_tendencia.dart';
import '../../cercanas/ui/widgets/seccion_historico.dart';
import '../../favoritos/data/favorito.dart';
import '../../favoritos/ui/favoritos_controller.dart';

class FichaEstacionSheet extends StatefulWidget {
  const FichaEstacionSheet({super.key, required this.estacion});

  final EstacionAviso estacion;

  @override
  State<FichaEstacionSheet> createState() => _FichaEstacionSheetState();
}

class _FichaEstacionSheetState extends State<FichaEstacionSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<FavoritosController>().cargarDetalle(
        widget.estacion.id,
        forzar: true,
      );
      context.read<HistorialController?>()?.cargar(widget.estacion.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    final favoritos = context.watch<FavoritosController>();
    final avisos = context.watch<AvisosController?>();
    final alias = context.watch<AliasController>();
    final historial = context.watch<HistorialController?>();
    final favorito = _favorito(favoritos, widget.estacion.id);
    final detalle = favoritos.detalle(widget.estacion.id);
    final productos = detalle?.productos ?? const <ProductoPrecio>[];
    final gasolinera = _gasolinera(favorito, detalle).conProductos(productos);
    final mostrado = nombreMostrado(gasolinera, alias.aliasDe(gasolinera.id));
    final cargando = favoritos.cargandoDetalle(widget.estacion.id);
    final error = favoritos.errorDetalle(widget.estacion.id);
    final esFavorito = favorito != null;
    final puedeUsarCoordenadas = favorito != null || detalle?.lat != null;
    final avisoActivo = favorito?.avisosPrecio ?? false;
    final estiloSecundario = tema.textTheme.bodySmall?.copyWith(
      color: esquema.onSurfaceVariant,
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    mostrado.titulo,
                    style: tema.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Navegar',
                  icon: const Icon(Icons.directions),
                  onPressed: puedeUsarCoordenadas
                      ? () => _navegar(context, gasolinera)
                      : null,
                ),
                IconButton(
                  tooltip: esFavorito
                      ? 'Quitar de favoritos'
                      : 'Añadir a favoritos',
                  color: esFavorito
                      ? esquema.primary
                      : esquema.onSurfaceVariant,
                  icon: Icon(
                    esFavorito ? Icons.favorite : Icons.favorite_border,
                  ),
                  onPressed: esFavorito || puedeUsarCoordenadas
                      ? () => favoritos.alternar(gasolinera)
                      : null,
                ),
                if (esFavorito && avisos != null)
                  IconButton(
                    tooltip: avisoActivo
                        ? 'Desactivar avisos de precio'
                        : 'Avisarme de cambios de precio',
                    color: avisoActivo
                        ? esquema.primary
                        : esquema.onSurfaceVariant,
                    icon: Icon(
                      avisoActivo
                          ? Icons.notifications_active_outlined
                          : Icons.notifications_none,
                    ),
                    onPressed: avisos.estaOcupado(gasolinera.id)
                        ? null
                        : () async {
                            final resultado = await avisos.alternarAviso(
                              gasolinera.id,
                            );
                            if (!context.mounted) return;
                            await mostrarResultadoAviso(context, resultado);
                          },
                  ),
              ],
            ),
            if (mostrado.subtitulo.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(mostrado.subtitulo, style: estiloSecundario),
            ],
            if (gasolinera.abierta24h) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: esquema.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text('Abierta 24 horas', style: estiloSecundario),
                ],
              ),
            ],
            const SizedBox(height: 12),
            if (cargando) const LinearProgressIndicator(),
            if (error != null)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      error,
                      style: tema.textTheme.bodySmall?.copyWith(
                        color: esquema.error,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => favoritos.cargarDetalle(
                      widget.estacion.id,
                      forzar: true,
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            if (productos.isEmpty && !cargando && error == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('Precios no disponibles', style: estiloSecundario),
              ),
            for (final producto in productos)
              _FilaPrecio(
                producto: producto,
                tendencia:
                    historial
                        ?.historico(gasolinera.id)
                        ?.serie(producto.idApi)
                        ?.tendencia ??
                    Tendencia.desconocida,
                colores: tema.extension<ColoresTendencia>(),
              ),
            const SizedBox(height: 16),
            SeccionHistorico(gasolinera: gasolinera, productos: productos),
          ],
        ),
      ),
    );
  }

  Favorito? _favorito(FavoritosController favoritos, int id) {
    for (final favorito in favoritos.favoritos) {
      if (favorito.id == id) return favorito;
    }
    return null;
  }

  Gasolinera _gasolinera(Favorito? favorito, DetalleEstacion? detalle) {
    if (favorito != null) return favorito.aGasolinera();
    return Gasolinera(
      id: widget.estacion.id,
      nombre: detalle?.nombre ?? widget.estacion.nombre,
      lat: detalle?.lat ?? 0,
      lng: detalle?.lng ?? 0,
      urlWeb: detalle?.urlWeb ?? '',
      direccion: detalle?.direccion,
    );
  }

  Future<void> _navegar(BuildContext context, Gasolinera gasolinera) async {
    final messenger = ScaffoldMessenger.of(context);
    final abierto = await const Navegacion().abrirDestino(gasolinera);
    if (!abierto) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir la aplicación de mapas.'),
        ),
      );
    }
  }
}

class _FilaPrecio extends StatelessWidget {
  const _FilaPrecio({
    required this.producto,
    required this.tendencia,
    required this.colores,
  });

  final ProductoPrecio producto;
  final Tendencia tendencia;
  final ColoresTendencia? colores;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    return Padding(
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
    );
  }
}
