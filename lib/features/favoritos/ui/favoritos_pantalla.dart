import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../cercanas/ui/widgets/pie_frescura.dart';
import '../../cercanas/ui/widgets/tarjeta_gasolinera.dart';
import '../data/favorito.dart';
import 'favoritos_controller.dart';

class FavoritosPantalla extends StatefulWidget {
  const FavoritosPantalla({super.key});

  @override
  State<FavoritosPantalla> createState() => _FavoritosPantallaState();
}

class _FavoritosPantallaState extends State<FavoritosPantalla> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<FavoritosController>().cargarDetalles();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FavoritosController>();
    final favoritos = controller.favoritos;
    final aviso = controller.aviso;
    return Column(
      children: [
        if (aviso != null) _AvisoFavoritos(mensaje: aviso),
        Expanded(
          child: favoritos.isEmpty
              ? const _FavoritosVacio()
              : ReorderableListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  buildDefaultDragHandles: false,
                  itemCount: favoritos.length,
                  onReorderItem: (antiguo, nuevo) {
                    controller.mover(antiguo, nuevo);
                  },
                  itemBuilder: (context, indice) {
                    final favorito = favoritos[indice];
                    return _FavoritoReordenable(
                      key: ValueKey(favorito.id),
                      favorito: favorito,
                      indice: indice,
                      mostrarAsa: favoritos.length > 1,
                    );
                  },
                ),
        ),
        if (favoritos.isNotEmpty) PieFrescura(meta: controller.meta),
      ],
    );
  }
}

class _AvisoFavoritos extends StatelessWidget {
  const _AvisoFavoritos({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: esquema.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 20, color: esquema.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensaje,
              style: tema.textTheme.bodySmall?.copyWith(
                color: esquema.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoritoReordenable extends StatelessWidget {
  const _FavoritoReordenable({
    super.key,
    required this.favorito,
    required this.indice,
    required this.mostrarAsa,
  });

  final Favorito favorito;
  final int indice;
  final bool mostrarAsa;

  @override
  Widget build(BuildContext context) {
    final contenido = ReorderableDelayedDragStartListener(
      index: indice,
      child: _FavoritoConPrecio(favorito: favorito),
    );
    if (!mostrarAsa) return contenido;
    final esquema = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: contenido),
        Semantics(
          button: true,
          label: 'Reordenar ${favorito.nombre}',
          child: ReorderableDragStartListener(
            index: indice,
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(Icons.drag_handle, color: esquema.onSurfaceVariant),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FavoritoConPrecio extends StatelessWidget {
  const _FavoritoConPrecio({required this.favorito});

  final Favorito favorito;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final controller = context.watch<FavoritosController>();
    final detalle = controller.detalle(favorito.id);
    final gasolinera = favorito.aGasolinera().conProductos(
      detalle?.productos ?? const [],
    );
    final cargando = controller.cargandoDetalle(favorito.id);
    final error = controller.errorDetalle(favorito.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TarjetaGasolinera(gasolinera: gasolinera),
        if (cargando) const LinearProgressIndicator(),
        if (error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    error,
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: tema.colorScheme.error,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => controller.cargarDetalle(favorito.id),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _FavoritosVacio extends StatelessWidget {
  const _FavoritosVacio();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border,
              size: 48,
              color: tema.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'Aún no tienes gasolineras favoritas',
              style: tema.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Pulsa el corazón de una gasolinera en la lista de cercanas '
              'para guardarla aquí.',
              style: tema.textTheme.bodyMedium?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
