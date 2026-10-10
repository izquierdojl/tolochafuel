import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/shell/seccion_app.dart';
import '../../../../app/shell/shell_controller.dart';

class AvisoSinUbicacion extends StatelessWidget {
  const AvisoSinUbicacion({super.key, required this.mensaje});

  final String mensaje;

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
              Icons.location_off_outlined,
              size: 40,
              color: tema.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: tema.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () =>
                  context.read<ShellController>().irA(SeccionApp.buscar),
              icon: const Icon(Icons.search),
              label: const Text('Ir a Buscar'),
            ),
          ],
        ),
      ),
    );
  }
}
