import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/theme/app_theme.dart';
import 'features/cercanas/ui/cercanas_controller.dart';
import 'features/cercanas/ui/cercanas_pantalla.dart';
import 'features/favoritos/ui/favoritos_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final favoritos = FavoritosController();
  await favoritos.cargar();
  runApp(TolochaFuelApp(favoritos: favoritos));
}

class TolochaFuelApp extends StatelessWidget {
  const TolochaFuelApp({super.key, required this.favoritos});

  final FavoritosController favoritos;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CercanasController()),
        ChangeNotifierProvider.value(value: favoritos),
      ],
      child: MaterialApp(
        title: 'TolochaFuel',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.claro,
        darkTheme: AppTheme.oscuro,
        themeMode: ThemeMode.dark,
        home: const CercanasPantalla(),
      ),
    );
  }
}
