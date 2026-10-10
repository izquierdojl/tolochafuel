import 'package:flutter/material.dart';

import '../cercanas_controller.dart';

class PanelBusquedaManual extends StatefulWidget {
  const PanelBusquedaManual({super.key, required this.controller});

  final CercanasController controller;

  @override
  State<PanelBusquedaManual> createState() => _PanelBusquedaManualState();
}

class _PanelBusquedaManualState extends State<PanelBusquedaManual> {
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
    await widget.controller.buscarLugar(_campo.text);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final tema = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (controller.avisoUbicacion != null) ...[
          Text(
            controller.avisoUbicacion!,
            style: tema.textTheme.bodyMedium?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
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
        const SizedBox(height: 8),
        Row(
          children: [
            FilledButton.icon(
              onPressed: controller.buscandoLugar ? null : _buscar,
              icon: const Icon(Icons.search),
              label: const Text('Buscar'),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: controller.inicializar,
              child: const Text('Usar mi ubicación'),
            ),
          ],
        ),
        if (controller.buscandoLugar) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(),
        ],
        if (controller.errorBusqueda != null) ...[
          const SizedBox(height: 12),
          Text(
            controller.errorBusqueda!,
            style: tema.textTheme.bodyMedium?.copyWith(
              color: tema.colorScheme.error,
            ),
          ),
        ],
        if (controller.resultadosBusqueda.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Selecciona dónde buscar:', style: tema.textTheme.titleSmall),
          for (final lugar in controller.resultadosBusqueda)
            ListTile(
              leading: const Icon(Icons.place_outlined),
              title: Text(lugar.nombre),
              subtitle: lugar.detalle == null ? null : Text(lugar.detalle!),
              onTap: () => controller.elegirLugar(lugar),
            ),
        ],
      ],
    );
  }
}
