import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../cercanas/ui/widgets/pie_atribucion.dart';
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
    final favoritos = context.watch<FavoritosController>().favoritos;
    return Column(
      children: [
        Expanded(
          child: favoritos.isEmpty
              ? const _FavoritosVacio()
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  itemCount: favoritos.length,
                  itemBuilder: (context, indice) =>
                      _FavoritoConPrecio(favorito: favoritos[indice]),
                ),
        ),
        const PieAtribucion(meta: null),
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
