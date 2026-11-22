import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../features/avisos/data/aviso_notificacion.dart';
import '../../features/avisos/services/navegacion_avisos.dart';
import '../../features/avisos/ui/avisos_controller.dart';
import '../../features/avisos/ui/ficha_estacion_sheet.dart';
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

class _ShellPantallaState extends State<ShellPantalla>
    with WidgetsBindingObserver {
  late final ShellController _shell;
  bool _fichaAbierta = false;
  bool _fichaProgramada = false;
  bool _avisoAppProgramado = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _shell = ShellController(
      context.read<ConfiguracionController>().pantallaInicial,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AvisosController?>()?.comprobarSiToca();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final avisos = context.read<AvisosController?>();
    if (avisos == null) return;
    unawaited(avisos.reconciliar());
    unawaited(avisos.comprobarSiToca());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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

  Future<void> _abrirFicha(EstacionAviso estacion) async {
    if (_fichaAbierta) return;
    _fichaAbierta = true;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => FichaEstacionSheet(estacion: estacion),
    );
    _fichaAbierta = false;
    if (!mounted) return;
    final siguiente = context.read<NavegacionAvisosController?>()?.consumir();
    if (siguiente != null) await _abrirFicha(siguiente);
  }

  void _programarFicha(NavegacionAvisosController? navegacion) {
    final pendiente = navegacion?.pendiente;
    if (pendiente == null || _fichaProgramada || _fichaAbierta) return;
    _fichaProgramada = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fichaProgramada = false;
      if (!mounted) return;
      final estacion = navegacion?.consumir();
      if (estacion != null) _abrirFicha(estacion);
    });
  }

  void _programarAvisoEnApp(
    AvisosController? avisos,
    AvisoNotificacion? aviso,
  ) {
    if (aviso == null || _avisoAppProgramado) return;
    _avisoAppProgramado = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _avisoAppProgramado = false;
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text('${aviso.titulo}: ${aviso.cuerpo}'),
          action: SnackBarAction(
            label: 'Ver',
            onPressed: () {
              final estacion = parsearEstacionAviso(aviso.payload);
              if (estacion != null) _abrirFicha(estacion);
            },
          ),
        ),
      );
      avisos?.olvidarAvisoEnApp(aviso);
    });
  }

  @override
  Widget build(BuildContext context) {
    final avisos = context.watch<AvisosController?>();
    final navegacion = context.watch<NavegacionAvisosController?>();
    _programarFicha(navegacion);
    _programarAvisoEnApp(
      avisos,
      avisos?.avisosEnApp.isNotEmpty == true ? avisos!.avisosEnApp.first : null,
    );
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
