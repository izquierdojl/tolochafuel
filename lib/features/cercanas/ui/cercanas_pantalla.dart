import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'cercanas_controller.dart';
import 'widgets/estados_cercanas.dart';
import 'widgets/panel_busqueda_manual.dart';
import 'widgets/pie_atribucion.dart';
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
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset('assets/icons/tolocha.svg', width: 28, height: 28),
            const SizedBox(width: 8),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Tolocha'),
                  TextSpan(
                    text: 'Fuel',
                    style: TextStyle(color: tema.colorScheme.primary),
                  ),
                ],
              ),
              style: tema.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          if (controller.modoManual && !controller.mostrandoPanelManual)
            IconButton(
              tooltip: 'Buscar otro municipio o provincia',
              icon: const Icon(Icons.search),
              onPressed: controller.volverABusqueda,
            ),
        ],
      ),
      body: controller.mostrandoPanelManual
          ? PanelBusquedaManual(controller: controller)
          : Column(
              children: [
                if (controller.areaNombre != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Más baratas en ${controller.areaNombre}',
                            style: tema.textTheme.titleSmall,
                          ),
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
                Expanded(child: _Cuerpo(controller: controller)),
                PieAtribucion(meta: controller.meta),
              ],
            ),
    );
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
        return VacioCercanas(
          sugerencia: controller.modoManual
              ? 'No se han encontrado gasolineras en esa zona. '
                    'Prueba con otro municipio o provincia.'
              : 'No hay gasolineras en el radio de '
                    '${controller.radioKm.toStringAsFixed(0)} km. '
                    'Prueba a ampliar la búsqueda o cambia de ubicación.',
        );
      case EstadoCercanas.datos:
        return ListView.builder(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          itemCount: controller.gasolineras.length,
          itemBuilder: (context, indice) =>
              TarjetaGasolinera(gasolinera: controller.gasolineras[indice]),
        );
    }
  }
}
