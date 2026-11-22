import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/gasolinera.dart';
import '../../../../core/models/producto_precio.dart';
import '../../../alias/ui/alias_controller.dart';
import '../../../alias/ui/nombre_mostrado.dart';
import 'seccion_historico.dart';

class DetalleHistorico extends StatelessWidget {
  const DetalleHistorico({
    super.key,
    required this.gasolinera,
    required this.productos,
  });

  final Gasolinera gasolinera;
  final List<ProductoPrecio> productos;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final alias = context.watch<AliasController>().aliasDe(gasolinera.id);
    final mostrado = nombreMostrado(gasolinera, alias);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mostrado.titulo, style: tema.textTheme.titleMedium),
            const SizedBox(height: 12),
            SeccionHistorico(gasolinera: gasolinera, productos: productos),
          ],
        ),
      ),
    );
  }
}
