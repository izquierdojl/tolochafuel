import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/shell/shell_pantalla.dart';
import 'app/theme/app_theme.dart';
import 'features/cercanas/ui/buscar_controller.dart';
import 'features/cercanas/ui/cercanas_controller.dart';
import 'features/cercanas/ui/mas_economicas_controller.dart';
import 'features/configuracion/ui/configuracion_controller.dart';
import 'features/favoritos/ui/favoritos_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final favoritos = FavoritosController();
  final configuracion = ConfiguracionController();
  await Future.wait([favoritos.cargar(), configuracion.cargar()]);
  runApp(TolochaFuelApp(favoritos: favoritos, configuracion: configuracion));
}

class TolochaFuelApp extends StatelessWidget {
  const TolochaFuelApp({
    super.key,
    required this.favoritos,
    required this.configuracion,
  });

  final FavoritosController favoritos;
  final ConfiguracionController configuracion;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CercanasController(configuracion: configuracion),
        ),
        ChangeNotifierProvider(create: (_) => BuscarController()),
        ChangeNotifierProvider(
          create: (_) => MasEconomicasController(configuracion: configuracion),
        ),
        ChangeNotifierProvider.value(value: favoritos),
        ChangeNotifierProvider.value(value: configuracion),
      ],
      child: Consumer<ConfiguracionController>(
        builder: (context, config, _) => MaterialApp(
          title: 'TolochaFuel',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.claro,
          darkTheme: AppTheme.oscuro,
          themeMode: config.temaOscuro ? ThemeMode.dark : ThemeMode.light,
          home: const ShellPantalla(),
        ),
      ),
    );
  }
}
