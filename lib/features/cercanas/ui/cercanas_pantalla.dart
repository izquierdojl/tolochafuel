import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cercanas_controller.dart';
import 'widgets/aviso_sin_ubicacion.dart';
import 'widgets/estados_cercanas.dart';
import 'widgets/pie_frescura.dart';
import 'widgets/tarjeta_gasolinera.dart';

class CercanasPantalla extends StatefulWidget {
  const CercanasPantalla({super.key});

  @override
  State<CercanasPantalla> createState() => _CercanasPantallaState();
}

class _CercanasPantallaState extends State<CercanasPantalla> {
  @override
  void initState() {
    super.initState();
    final controller = context.read<CercanasController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.inicializar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CercanasController>();
    return _Cuerpo(controller: controller);
  }
}

class _Cuerpo extends StatelessWidget {
  const _Cuerpo({required this.controller});

  final CercanasController controller;

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
        return Column(
          children: [
            Expanded(
              child: VacioCercanas(
                sugerencia:
                    'No hay gasolineras en el radio de '
                    '${controller.radioKm.toStringAsFixed(0)} km. '
                    'Prueba a ampliar el radio en Configuración o cambia de '
                    'ubicación.',
              ),
            ),
            PieFrescura(meta: controller.meta),
          ],
        );
      case EstadoCercanas.datos:
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                itemCount: controller.gasolineras.length,
                itemBuilder: (context, indice) => TarjetaGasolinera(
                  gasolinera: controller.gasolineras[indice],
                ),
              ),
            ),
            PieFrescura(meta: controller.meta),
          ],
        );
    }
  }
}
