import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'buscar_controller.dart';
import 'cercanas_controller.dart';
import 'widgets/estados_cercanas.dart';
import 'widgets/pie_frescura.dart';
import 'widgets/tarjeta_gasolinera.dart';

class BuscarPantalla extends StatefulWidget {
  const BuscarPantalla({super.key});

  @override
  State<BuscarPantalla> createState() => _BuscarPantallaState();
}

class _BuscarPantallaState extends State<BuscarPantalla> {
  final _campo = TextEditingController();
  final _foco = FocusNode();

  @override
  void dispose() {
    _campo.dispose();
    _foco.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    _foco.unfocus();
    await context.read<BuscarController>().buscarLugar(_campo.text);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BuscarController>();
    final tema = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _campo,
                  focusNode: _foco,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    labelText: 'Municipio o provincia',
                    hintText: 'p. ej. Madrid, Toledo, Sevilla…',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _buscar(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: controller.buscandoLugar ? null : _buscar,
                child: const Text('Buscar'),
              ),
            ],
          ),
        ),
        if (controller.buscandoLugar) const LinearProgressIndicator(),
        if (controller.errorBusqueda != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              controller.errorBusqueda!,
              style: tema.textTheme.bodyMedium?.copyWith(
                color: tema.colorScheme.error,
              ),
            ),
          ),
        if (controller.resultadosBusqueda.isNotEmpty)
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    'Selecciona dónde buscar:',
                    style: tema.textTheme.titleSmall,
                  ),
                ),
                for (final lugar in controller.resultadosBusqueda)
                  ListTile(
                    leading: const Icon(Icons.place_outlined),
                    title: Text(lugar.nombre),
                    subtitle: lugar.detalle == null
                        ? null
                        : Text(lugar.detalle!),
                    onTap: () => controller.elegirLugar(lugar),
                  ),
              ],
            ),
          )
        else
          Expanded(child: _Resultados(controller: controller)),
      ],
    );
  }
}

class _Resultados extends StatelessWidget {
  const _Resultados({required this.controller});

  final BuscarController controller;

  @override
  Widget build(BuildContext context) {
    switch (controller.estado) {
      case EstadoCercanas.inicial:
        return const _PistaInicial();
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
        return Column(
          children: [
            const Expanded(
              child: VacioCercanas(
                sugerencia:
                    'No se han encontrado gasolineras en ese territorio. '
                    'Prueba con otro municipio o provincia.',
              ),
            ),
            PieFrescura(meta: controller.meta),
          ],
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
                    'Más baratas en ${controller.areaNombre}',
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
            PieFrescura(meta: controller.meta),
          ],
        );
    }
  }
}

class _PistaInicial extends StatelessWidget {
  const _PistaInicial();

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
              Icons.travel_explore,
              size: 40,
              color: tema.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'Busca un municipio o provincia para ver sus gasolineras '
              'más baratas.',
              textAlign: TextAlign.center,
              style: tema.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
