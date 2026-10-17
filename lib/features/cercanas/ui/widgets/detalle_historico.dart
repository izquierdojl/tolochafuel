import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/models/gasolinera.dart';
import '../../../../core/models/historico_estacion.dart';
import '../../../../core/models/producto_precio.dart';
import '../../../../core/utilidades/formato.dart';
import '../../../alias/ui/alias_controller.dart';
import '../../../alias/ui/nombre_mostrado.dart';
import '../historial_controller.dart';
import 'flecha_tendencia.dart';
import 'grafico_historico.dart';

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
    final alias = context.watch<AliasController>().aliasDe(gasolinera.id);
    final mostrado = nombreMostrado(gasolinera, alias);
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
            Text(mostrado.titulo, style: tema.textTheme.titleMedium),
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

class _SeccionProducto extends StatefulWidget {
  const _SeccionProducto({required this.producto, required this.serie});

  final ProductoPrecio producto;
  final SerieCarburante serie;

  @override
  State<_SeccionProducto> createState() => _SeccionProductoState();
}

class _SeccionProductoState extends State<_SeccionProducto> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.extension<ColoresTendencia>();
    final producto = widget.producto;
    final serie = widget.serie;
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
          else
            for (final cambio in cambios.reversed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        formatearFecha(cambio.punto.fecha),
                        style: tema.textTheme.bodySmall?.copyWith(
                          color: tema.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Text(
                      formatearPrecio(
                        cambio.punto.precio,
                        unidad: producto.unidad,
                      ),
                      style: tema.textTheme.bodyMedium,
                    ),
                    if (colores != null) ...[
                      const SizedBox(width: 6),
                      FlechaTendencia(
                        tendencia: cambio.tendencia,
                        colores: colores,
                      ),
                    ],
                  ],
                ),
              ),
          if (serie.puntos.length >= 2) ...[
            const SizedBox(height: 6),
            _BloqueMedias(
              producto: producto,
              serie: serie,
              expandido: _expandido,
              onPulsar: () => setState(() => _expandido = !_expandido),
            ),
            if (_expandido) ...[
              const SizedBox(height: 8),
              GraficoHistorico(serie: serie, unidad: producto.unidad),
            ],
          ],
        ],
      ),
    );
  }
}

class _BloqueMedias extends StatelessWidget {
  const _BloqueMedias({
    required this.producto,
    required this.serie,
    required this.expandido,
    required this.onPulsar,
  });

  final ProductoPrecio producto;
  final SerieCarburante serie;
  final bool expandido;
  final VoidCallback onPulsar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    final colores = tema.extension<ColoresTendencia>();
    final semana = serie.media(7);
    final mes = serie.media(30);
    final filas = <Widget>[
      if (semana != null)
        _FilaMedia(
          etiqueta: 'Última semana',
          media: semana,
          tendencia: serie.tendenciaMedia(7),
          producto: producto,
          colores: colores,
        ),
      if (mes != null)
        _FilaMedia(
          etiqueta: 'Último mes',
          media: mes,
          tendencia: serie.tendenciaMedia(30),
          producto: producto,
          colores: colores,
        ),
    ];
    return Semantics(
      container: true,
      button: true,
      label: 'Ver gráfico de precios',
      child: InkWell(
        onTap: onPulsar,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: esquema.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: filas.isEmpty
                    ? Text(
                        'Ver gráfico de precios',
                        style: tema.textTheme.bodySmall?.copyWith(
                          color: esquema.onSurfaceVariant,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: filas,
                      ),
              ),
              const SizedBox(width: 8),
              Icon(
                expandido ? Icons.expand_less : Icons.expand_more,
                size: 18,
                color: esquema.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilaMedia extends StatelessWidget {
  const _FilaMedia({
    required this.etiqueta,
    required this.media,
    required this.tendencia,
    required this.producto,
    required this.colores,
  });

  final String etiqueta;
  final double media;
  final Tendencia tendencia;
  final ProductoPrecio producto;
  final ColoresTendencia? colores;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              etiqueta,
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            formatearPrecio(media, unidad: producto.unidad),
            style: tema.textTheme.bodyMedium?.copyWith(
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
