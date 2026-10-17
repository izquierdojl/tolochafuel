import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/models/historico_estacion.dart';
import '../../../../core/utilidades/formato.dart';

String textoPunto(PuntoPrecio punto, String unidad) =>
    '${formatearFecha(punto.fecha)}\n'
    '${formatearPrecio(punto.precio, unidad: unidad)}';

class GraficoHistorico extends StatelessWidget {
  const GraficoHistorico({
    super.key,
    required this.serie,
    required this.unidad,
  });

  final SerieCarburante serie;
  final String unidad;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    final puntos = serie.puntos;
    final minimo = puntos.map((p) => p.precio).reduce(math.min);
    final maximo = puntos.map((p) => p.precio).reduce(math.max);
    final rango = maximo - minimo;
    final margen = rango <= 0 ? 0.01 : math.max(rango * 0.1, 0.002);
    final minY = minimo - margen;
    final maxY = maximo + margen;
    final intervaloY = (maxY - minY) / 2;

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (puntos.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          baselineY: minY,
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < puntos.length; i++)
                  FlSpot(i.toDouble(), puntos[i].precio),
              ],
              isCurved: false,
              barWidth: 2,
              color: esquema.primary,
              dotData: FlDotData(
                checkToShowDot: (spot, barData) =>
                    spot.x == (puntos.length - 1).toDouble(),
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                      radius: 3.5,
                      color: esquema.primary,
                      strokeWidth: 2,
                      strokeColor: esquema.surface,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    esquema.primary.withValues(alpha: 0.25),
                    esquema.primary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ],
          extraLinesData: _lineasMedias(tema, serie),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: intervaloY,
            getDrawingHorizontalLine: (value) => FlLine(
              color: esquema.outlineVariant.withValues(alpha: 0.5),
              strokeWidth: 0.5,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 46,
                interval: intervaloY,
                getTitlesWidget: (value, meta) => Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    value.toStringAsFixed(3).replaceAll('.', ','),
                    style: tema.textTheme.labelSmall?.copyWith(
                      color: esquema.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final indice = value.round();
                  if (indice < 0 || indice >= puntos.length) {
                    return const SizedBox.shrink();
                  }
                  final centro = ((puntos.length - 1) / 2).round();
                  if (indice != 0 &&
                      indice != centro &&
                      indice != puntos.length - 1) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      formatearFechaCorta(puntos[indice].fecha),
                      style: tema.textTheme.labelSmall?.copyWith(
                        color: esquema.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchSpotThreshold: 20,
            touchTooltipData: LineTouchTooltipData(
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipColor: (_) => esquema.surfaceContainerHighest,
              getTooltipItems: (tocados) => [
                for (final toque in tocados)
                  LineTooltipItem(
                    textoPunto(puntos[toque.x.round()], unidad),
                    tema.textTheme.labelMedium?.copyWith(
                          color: esquema.onSurface,
                        ) ??
                        TextStyle(color: esquema.onSurface),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ExtraLinesData _lineasMedias(ThemeData tema, SerieCarburante serie) {
    final esquema = tema.colorScheme;
    final estilo = tema.textTheme.labelSmall?.copyWith(
      color: esquema.onSurfaceVariant,
    );
    final semana = serie.media(7);
    final mes = serie.media(30);
    final lineas = <HorizontalLine>[];
    if (semana != null &&
        mes != null &&
        (semana * 1000).round() == (mes * 1000).round()) {
      lineas.add(_lineaHorizontal(semana, 'media', esquema, estilo));
    } else {
      if (semana != null) {
        lineas.add(_lineaHorizontal(semana, 'semana', esquema, estilo));
      }
      if (mes != null) {
        lineas.add(_lineaHorizontal(mes, 'mes', esquema, estilo));
      }
    }
    return ExtraLinesData(horizontalLines: lineas);
  }

  HorizontalLine _lineaHorizontal(
    double valor,
    String etiqueta,
    ColorScheme esquema,
    TextStyle? estilo,
  ) => HorizontalLine(
    y: valor,
    color: esquema.onSurfaceVariant.withValues(alpha: 0.6),
    strokeWidth: 1,
    dashArray: [4, 4],
    label: HorizontalLineLabel(
      show: true,
      alignment: Alignment.topRight,
      padding: const EdgeInsets.only(right: 4),
      style: estilo,
      labelResolver: (_) => etiqueta,
    ),
  );
}
