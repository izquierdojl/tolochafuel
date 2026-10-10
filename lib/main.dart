import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/theme/app_theme.dart';
import 'features/cercanas/ui/cercanas_controller.dart';
import 'features/cercanas/ui/cercanas_pantalla.dart';

void main() {
  runApp(const TolochaFuelApp());
}

class TolochaFuelApp extends StatelessWidget {
  const TolochaFuelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CercanasController(),
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
