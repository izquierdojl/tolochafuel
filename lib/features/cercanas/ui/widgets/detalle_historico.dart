import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/models/gasolinera.dart';
import '../../../../core/models/historico_estacion.dart';
import '../../../../core/models/producto_precio.dart';
import '../../../../core/utilidades/formato.dart';
import '../historial_controller.dart';

class DetalleHistorico extends StatelessWidget {
  const DetalleHistorico({
    super.key,
    required this.gasolinera,
    required this.productos,
  });

  final Gasolinera gasolinera;
  final List<ProductoPrecio> productos;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final controller = context.watch<HistorialController>();
    final historico = controller.historico(gasolinera.id);
    final cargando = controller.cargando(gasolinera.id);
    final error = controller.error(gasolinera.id);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(gasolinera.nombre, style: tema.textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(
              'Últimos cambios de precio (90 días)',
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (historico != null)
              ..._secciones(tema, historico)
            else if (cargando)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (error != null)
              _ErrorHistorico(
                mensaje: error,
                onReintentar: () => controller.cargar(gasolinera.id),
              )
            else
              Text(
                'No hay histórico disponible para esta estación.',
                style: tema.textTheme.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _secciones(ThemeData tema, HistoricoEstacion historico) {
    final secciones = <Widget>[];
    for (final producto in productos) {
      final serie = historico.serie(producto.idApi);
      if (serie == null) continue;
      secciones.add(_SeccionProducto(producto: producto, serie: serie));
    }
    if (secciones.isEmpty) {
      secciones.add(
        Text(
          'No hay histórico disponible para esta estación.',
          style: tema.textTheme.bodyMedium,
        ),
      );
    }
    return secciones;
  }
}

class _SeccionProducto extends StatelessWidget {
  const _SeccionProducto({required this.producto, required this.serie});

  final ProductoPrecio producto;
  final SerieCarburante serie;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cambios = serie.cambios();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(producto.etiqueta, style: tema.textTheme.titleSmall),
          const SizedBox(height: 4),
          if (cambios.isEmpty)
            Text(
              'Sin cambios en los últimos 90 días',
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            )
          else ...[
            for (final punto in cambios.reversed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        formatearFecha(punto.fecha),
                        style: tema.textTheme.bodySmall?.copyWith(
                          color: tema.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Text(
                      formatearPrecio(punto.precio, unidad: producto.unidad),
                      style: tema.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 2),
            _ResumenVariacion(producto: producto, variacion: serie.variacion),
          ],
        ],
      ),
    );
  }
}

class _ResumenVariacion extends StatelessWidget {
  const _ResumenVariacion({required this.producto, required this.variacion});

  final ProductoPrecio producto;
  final Variacion variacion;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.extension<ColoresTendencia>();
    final delta = variacion.delta;
    final desde = variacion.desde;
    final String texto;
    final Color? color;
    if ((variacion.tendencia == Tendencia.baja ||
            variacion.tendencia == Tendencia.sube) &&
        delta != null &&
        desde != null) {
      final verbo = variacion.tendencia == Tendencia.baja ? 'Baja' : 'Sube';
      texto =
          '$verbo ${formatearPrecio(delta.abs(), unidad: producto.unidad)} '
          'desde el ${formatearFecha(desde)}';
      color = variacion.tendencia == Tendencia.baja
          ? colores?.bajada
          : colores?.subida;
    } else {
      texto = 'Sin cambios en los últimos 5 días';
      color = colores?.neutra;
    }
    return Text(
      texto,
      style: tema.textTheme.bodySmall?.copyWith(
        color: color ?? tema.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _ErrorHistorico extends StatelessWidget {
  const _ErrorHistorico({required this.mensaje, required this.onReintentar});

  final String mensaje;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            mensaje,
            style: tema.textTheme.bodyMedium?.copyWith(
              color: tema.colorScheme.error,
            ),
          ),
        ),
        TextButton(onPressed: onReintentar, child: const Text('Reintentar')),
      ],
    );
  }
}
