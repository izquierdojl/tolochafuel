import 'package:flutter/material.dart';

import 'app/theme/app_theme.dart';

void main() {
  runApp(const TolochaFuelApp());
}

class TolochaFuelApp extends StatelessWidget {
  const TolochaFuelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TolochaFuel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro,
      darkTheme: AppTheme.oscuro,
      themeMode: ThemeMode.dark,
      home: const PantallaInicio(),
    );
  }
}

class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TolochaFuel')),
      body: const Center(child: Text('App en construcción')),
    );
  }
}
