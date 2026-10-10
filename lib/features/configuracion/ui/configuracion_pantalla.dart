import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/shell/seccion_app.dart';
import '../data/configuracion_repositorio.dart';
import 'acerca_de_pantalla.dart';
import 'configuracion_controller.dart';

class ConfiguracionPantalla extends StatelessWidget {
  const ConfiguracionPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ConfiguracionController>();
    final tema = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.brightness_6_outlined),
          title: const Text('Tema oscuro'),
          subtitle: const Text('Desactívalo para usar el tema claro'),
          value: config.temaOscuro,
          onChanged: (valor) => config.cambiarTema(oscuro: valor),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Radio de búsqueda: ${config.radioKm.toStringAsFixed(0)} km',
                style: tema.textTheme.titleMedium,
              ),
              Slider(
                min: Ajustes.radioMinimoKm,
                max: Ajustes.radioMaximoKm,
                divisions: ((Ajustes.radioMaximoKm - Ajustes.radioMinimoKm) / 5)
                    .round(),
                value: config.radioKm,
                label: '${config.radioKm.toStringAsFixed(0)} km',
                onChanged: config.cambiarRadio,
              ),
              Text(
                'De 10 a 50 km. 50 km es el máximo que permite la API; '
                'los precios son los mismos en todo el radio.',
                style: tema.textTheme.bodySmall?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.home_outlined),
          title: const Text('Pantalla inicial'),
          subtitle: const Text('La sección que se abre al iniciar la app'),
          trailing: DropdownButton<SeccionApp>(
            value: config.pantallaInicial,
            onChanged: (seccion) {
              if (seccion != null) {
                config.cambiarPantallaInicial(seccion);
              }
            },
            items: [
              for (final seccion in SeccionApp.iniciales)
                DropdownMenuItem(value: seccion, child: Text(seccion.titulo)),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Acerca de…'),
          subtitle: const Text('Fuente de los datos y licencia'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const AcercaDePantalla()),
          ),
        ),
      ],
    );
  }
}
