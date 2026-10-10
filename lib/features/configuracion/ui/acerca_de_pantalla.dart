import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/meta_datos.dart';

class AcercaDePantalla extends StatelessWidget {
  const AcercaDePantalla({super.key});

  static const _urlLicencia = 'https://creativecommons.org/licenses/by/4.0/';
  static const _urlRepositorio = 'https://github.com/izquierdojl/tolochafuel';

  Future<void> _abrirEnlace(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      // Sin navegador disponible: el texto de la licencia sigue visible.
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final secundario = tema.textTheme.bodyMedium?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de TolochaFuel')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('TolochaFuel', style: tema.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Precios de carburantes de las gasolineras cercanas en España.',
            style: secundario,
          ),
          const SizedBox(height: 16),
          Text('Fuente de los datos', style: tema.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            'Los precios son los oficiales que las gasolineras comunican al '
            'Ministerio para la Transición Ecológica y el Reto Demográfico, '
            'servidos por Gasolina hoy. Se actualizan dos veces al día '
            '(sobre las 8:00 y las 20:00), así que no son precios en tiempo '
            'real.',
            style: secundario,
          ),
          const SizedBox(height: 16),
          Text('Atribución', style: tema.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(MetaDatos.atribucionPorDefecto, style: secundario),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.open_in_new, color: tema.colorScheme.primary),
            title: const Text('Licencia CC BY 4.0'),
            subtitle: const Text(
              'Datos reutilizables citando la fuente (Creative Commons '
              'Atribución 4.0).',
            ),
            onTap: () => _abrirEnlace(_urlLicencia),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.code, color: tema.colorScheme.primary),
            title: const Text('Código en GitHub'),
            subtitle: const Text('izquierdojl/tolochafuel'),
            onTap: () => _abrirEnlace(_urlRepositorio),
          ),
        ],
      ),
    );
  }
}
