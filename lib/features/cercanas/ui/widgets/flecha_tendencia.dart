import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/models/historico_estacion.dart';

class FlechaTendencia extends StatelessWidget {
  const FlechaTendencia({
    super.key,
    required this.tendencia,
    required this.colores,
  });

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
