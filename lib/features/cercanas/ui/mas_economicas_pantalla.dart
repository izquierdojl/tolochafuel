import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cercanas_controller.dart';
import 'mas_economicas_controller.dart';
import 'widgets/aviso_sin_ubicacion.dart';
import 'widgets/estados_cercanas.dart';
import 'widgets/tarjeta_gasolinera.dart';

class MasEconomicasPantalla extends StatefulWidget {
  const MasEconomicasPantalla({super.key});

  @override
  State<MasEconomicasPantalla> createState() => _MasEconomicasPantallaState();
}

class _MasEconomicasPantallaState extends State<MasEconomicasPantalla> {
  @override
  void initState() {
    super.initState();
    final controller = context.read<MasEconomicasController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.inicializar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MasEconomicasController>();
    return _Cuerpo(controller: controller);
  }
}

class _Cuerpo extends StatelessWidget {
  const _Cuerpo({required this.controller});

  final MasEconomicasController controller;

  @override
  Widget build(BuildContext context) {
    switch (controller.estado) {
      case EstadoCercanas.inicial:
      case EstadoCercanas.cargando:
        return const CargandoCercanas();
      case EstadoCercanas.error:
        return ErrorCercanas(
          mensaje:
              controller.mensajeError ??
              'No se pudieron cargar las gasolineras.',
          onReintentar: controller.reintentar,
        );
      case EstadoCercanas.vacio:
        final aviso = controller.avisoUbicacion;
        if (aviso != null) return AvisoSinUbicacion(mensaje: aviso);
        return VacioCercanas(
          sugerencia:
              'No hay estaciones en el radio de '
              '${controller.radioKm.toStringAsFixed(0)} km. '
              'Prueba a ampliar el radio en Configuración o cambia de '
              'ubicación.',
        );
      case EstadoCercanas.datos:
        final tema = Theme.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Más económicas en '
                    '${controller.radioKm.toStringAsFixed(0)} km',
                    style: tema.textTheme.titleSmall,
                  ),
                  Text(
                    'Orden por Gasolina 95',
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: tema.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                itemCount: controller.gasolineras.length,
                itemBuilder: (context, indice) => TarjetaGasolinera(
                  gasolinera: controller.gasolineras[indice],
                ),
              ),
            ),
          ],
        );
    }
  }
}
