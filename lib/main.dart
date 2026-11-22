import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'app/shell/shell_pantalla.dart';
import 'app/theme/app_theme.dart';
import 'features/alias/ui/alias_controller.dart';
import 'features/avisos/services/navegacion_avisos.dart';
import 'features/avisos/services/notificaciones_locales.dart';
import 'features/avisos/ui/avisos_controller.dart';
import 'features/cercanas/ui/buscar_controller.dart';
import 'features/cercanas/ui/cercanas_controller.dart';
import 'features/cercanas/ui/historial_controller.dart';
import 'features/cercanas/ui/mas_economicas_controller.dart';
import 'features/configuracion/ui/configuracion_controller.dart';
import 'features/favoritos/ui/favoritos_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificaciones = NotificacionesLocales();
  final navegacionAvisos = NavegacionAvisosController();
  await notificaciones.inicializar(
    alTocar: (payload) {
      final estacion = parsearEstacionAviso(payload);
      if (estacion != null) navegacionAvisos.abrir(estacion);
    },
  );
  final estacionInicial = parsearEstacionAviso(
    await notificaciones.lanzamientoInicial(),
  );
  if (estacionInicial != null) navegacionAvisos.abrir(estacionInicial);

  final favoritos = FavoritosController();
  final configuracion = ConfiguracionController();
  final alias = AliasController();
  await Future.wait([
    favoritos.cargar(),
    configuracion.cargar(),
    alias.cargar(),
  ]);
  final avisos = AvisosController(
    favoritos: favoritos,
    notificaciones: notificaciones,
  );
  await avisos.reconciliar();
  runApp(
    TolochaFuelApp(
      favoritos: favoritos,
      configuracion: configuracion,
      alias: alias,
      avisos: avisos,
      navegacionAvisos: navegacionAvisos,
    ),
  );
}

class TolochaFuelApp extends StatelessWidget {
  const TolochaFuelApp({
    super.key,
    required this.favoritos,
    required this.configuracion,
    required this.alias,
    this.avisos,
    this.navegacionAvisos,
  });

  final FavoritosController favoritos;
  final ConfiguracionController configuracion;
  final AliasController alias;
  final AvisosController? avisos;
  final NavegacionAvisosController? navegacionAvisos;

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
        if (avisos != null) ChangeNotifierProvider.value(value: avisos!),
        if (navegacionAvisos != null)
          ChangeNotifierProvider.value(value: navegacionAvisos!),
      ],
      child: Consumer<ConfiguracionController>(
        builder: (context, config, _) => MaterialApp(
          title: 'TolochaFuel',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.claro,
          darkTheme: AppTheme.oscuro,
          themeMode: config.tema,
          home: const ShellPantalla(),
        ),
      ),
    );
  }
}
