import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/shell/shell_pantalla.dart';
import 'app/theme/app_theme.dart';
import 'features/alias/ui/alias_controller.dart';
import 'features/cercanas/ui/buscar_controller.dart';
import 'features/cercanas/ui/cercanas_controller.dart';
import 'features/cercanas/ui/historial_controller.dart';
import 'features/cercanas/ui/mas_economicas_controller.dart';
import 'features/configuracion/ui/configuracion_controller.dart';
import 'features/favoritos/ui/favoritos_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final favoritos = FavoritosController();
  final configuracion = ConfiguracionController();
  final alias = AliasController();
  await Future.wait([
    favoritos.cargar(),
    configuracion.cargar(),
    alias.cargar(),
  ]);
  runApp(
    TolochaFuelApp(
      favoritos: favoritos,
      configuracion: configuracion,
      alias: alias,
    ),
  );
}

class TolochaFuelApp extends StatelessWidget {
  const TolochaFuelApp({
    super.key,
    required this.favoritos,
    required this.configuracion,
    required this.alias,
  });

  final FavoritosController favoritos;
  final ConfiguracionController configuracion;
  final AliasController alias;

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
        ChangeNotifierProvider(create: (_) => HistorialController()),
        ChangeNotifierProvider.value(value: favoritos),
        ChangeNotifierProvider.value(value: alias),
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
