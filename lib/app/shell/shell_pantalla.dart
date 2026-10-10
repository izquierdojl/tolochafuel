import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/cercanas/ui/buscar_pantalla.dart';
import '../../features/cercanas/ui/cercanas_pantalla.dart';
import '../../features/cercanas/ui/mas_economicas_pantalla.dart';
import '../../features/configuracion/ui/configuracion_controller.dart';
import '../../features/configuracion/ui/configuracion_pantalla.dart';
import '../../features/favoritos/ui/favoritos_pantalla.dart';
import 'cabecera_tolocha.dart';
import 'menu_lateral.dart';
import 'seccion_app.dart';
import 'shell_controller.dart';

class ShellPantalla extends StatefulWidget {
  const ShellPantalla({super.key});

  @override
  State<ShellPantalla> createState() => _ShellPantallaState();
}

class _ShellPantallaState extends State<ShellPantalla> {
  late final ShellController _shell;

  @override
  void initState() {
    super.initState();
    _shell = ShellController(
      context.read<ConfiguracionController>().pantallaInicial,
    );
  }

  @override
  void dispose() {
    _shell.dispose();
    super.dispose();
  }

  void _seleccionar(SeccionApp seccion) {
    _shell.irA(seccion);
    Navigator.of(context).pop();
  }

  Widget _construir(SeccionApp seccion) => switch (seccion) {
    SeccionApp.cercanas => const CercanasPantalla(),
    SeccionApp.favoritas => const FavoritosPantalla(),
    SeccionApp.buscar => const BuscarPantalla(),
    SeccionApp.masEconomicas => const MasEconomicasPantalla(),
    SeccionApp.configuracion => const ConfiguracionPantalla(),
  };

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _shell,
      child: Consumer<ShellController>(
        builder: (context, shell, _) => Scaffold(
          appBar: AppBar(title: const CabeceraTolocha()),
          drawer: MenuLateral(
            seccion: shell.seccion,
            onSeleccionar: _seleccionar,
          ),
          body: IndexedStack(
            index: SeccionApp.values.indexOf(shell.seccion),
            children: [
              for (final seccion in SeccionApp.values)
                if (shell.visitada(seccion))
                  _construir(seccion)
                else
                  const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
