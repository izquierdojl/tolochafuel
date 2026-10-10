import 'package:flutter/material.dart';

import 'cabecera_tolocha.dart';
import 'seccion_app.dart';

class MenuLateral extends StatelessWidget {
  const MenuLateral({
    super.key,
    required this.seccion,
    required this.onSeleccionar,
  });

  final SeccionApp seccion;
  final ValueChanged<SeccionApp> onSeleccionar;

  static IconData _icono(SeccionApp seccion) => switch (seccion) {
    SeccionApp.cercanas => Icons.near_me_outlined,
    SeccionApp.favoritas => Icons.favorite_border,
    SeccionApp.buscar => Icons.search,
    SeccionApp.masEconomicas => Icons.savings_outlined,
    SeccionApp.configuracion => Icons.settings_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: SeccionApp.values.indexOf(seccion),
      onDestinationSelected: (indice) =>
          onSeleccionar(SeccionApp.values[indice]),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 16, 12),
          child: CabeceraTolocha(),
        ),
        for (final destino in SeccionApp.values)
          NavigationDrawerDestination(
            icon: Icon(_icono(destino)),
            label: Text(destino.titulo),
          ),
      ],
    );
  }
}
