import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tolochafuel/app/theme/app_theme.dart';
import 'package:tolochafuel/core/api/api_client.dart';
import 'package:tolochafuel/core/api/precios_gasolina_api.dart';
import 'package:tolochafuel/core/models/detalle_estacion.dart';
import 'package:tolochafuel/core/models/gasolinera.dart';
import 'package:tolochafuel/core/models/historico_estacion.dart';
import 'package:tolochafuel/core/models/meta_datos.dart';
import 'package:tolochafuel/core/models/producto_precio.dart';
import 'package:tolochafuel/features/alias/ui/alias_controller.dart';
import 'package:tolochafuel/features/avisos/data/aviso_notificacion.dart';
import 'package:tolochafuel/features/avisos/data/avisos_repositorio.dart';
import 'package:tolochafuel/features/avisos/services/comprobador_avisos.dart';
import 'package:tolochafuel/features/avisos/services/notificaciones_servicio.dart';
import 'package:tolochafuel/features/avisos/services/programador_avisos.dart';
import 'package:tolochafuel/features/avisos/ui/avisos_controller.dart';
import 'package:tolochafuel/features/avisos/ui/ficha_estacion_sheet.dart';
import 'package:tolochafuel/features/cercanas/ui/historial_controller.dart';
import 'package:tolochafuel/features/favoritos/data/favorito.dart';
import 'package:tolochafuel/features/favoritos/data/favoritos_repositorio.dart';
import 'package:tolochafuel/features/favoritos/ui/favoritos_controller.dart';

import '../support/almacen_memoria.dart';

const _producto = ProductoPrecio(
  idApi: 'gasoline_95',
  etiqueta: 'Gasolina 95',
  unidad: 'L',
  precio: 1.729,
);

DetalleEstacion _detalle({List<ProductoPrecio>? productos}) => DetalleEstacion(
  productos: productos ?? const [_producto],
  nombre: 'Ballenoil',
  direccion: 'Calle Mayor, 1',
  lat: 40.4,
  lng: -3.7,
  urlWeb: '',
  meta: MetaDatos(
    atribucion: MetaDatos.atribucionPorDefecto,
    ultimaActualizacion: DateTime.utc(2026, 11, 22, 20),
  ),
);

class RepositorioFalso extends FavoritosRepositorio {
  RepositorioFalso({this.inicial = const []});

  final List<Favorito> inicial;

  @override
  Future<List<Favorito>> cargar() async => inicial;

  @override
  Future<List<Favorito>> cargarAsync() async => inicial;

  @override
  Future<void> guardar(List<Favorito> favoritos) async {}
}

class ApiFalsa extends PreciosGasolinaApi {
  ApiFalsa({this.detalles = const {}, this.errores = const {}, this.completer});

  final Map<int, DetalleEstacion> detalles;
  final Map<int, Object> errores;
  final Completer<DetalleEstacion>? completer;

  @override
  Future<DetalleEstacion> detalle(int id) async {
    if (completer != null) return completer!.future;
    final error = errores[id];
    if (error != null) throw error;
    return detalles[id] ?? const DetalleEstacion(productos: []);
  }
}

class ApiHistoricoFalsa extends PreciosGasolinaApi {
  @override
  Future<HistoricoEstacion> historico(int id, {int days = 5}) async =>
      HistoricoEstacion(
        series: [
          SerieCarburante(
            idApi: 'gasoline_95',
            puntos: [
              PuntoPrecio(fecha: DateTime(2026, 11, 21), precio: 1.729),
              PuntoPrecio(fecha: DateTime(2026, 11, 22), precio: 1.729),
            ],
          ),
        ],
      );
}

class ComprobadorFalso implements ComprobadorAvisos {
  @override
  Future<ResultadoComprobacion> comprobar() async =>
      const ResultadoComprobacion();

  @override
  Future<ResultadoBase> crearBase(int estacionId) async => ResultadoBase.creada;
}

class NotificacionesFalsas implements NotificacionesServicio {
  @override
  Future<void> cancelar(int id) async {}

  @override
  Future<void> cancelarTodas() async {}

  @override
  Future<bool> estanHabilitadas() async => true;

  @override
  Future<void> inicializar({
    required void Function(String? payload) alTocar,
  }) async {}

  @override
  Future<String?> lanzamientoInicial() async => null;

  @override
  Future<bool> mostrar(AvisoNotificacion aviso) async => true;

  @override
  Future<bool> solicitarPermiso() async => true;
}

class ProgramadorFalso implements ProgramadorAvisos {
  @override
  Future<void> programar(DateTime? proxima) async {}

  @override
  Future<void> cancelar() async {}
}

Gasolinera _gasolinera() => const Gasolinera(
  id: 7,
  nombre: 'Ballenoil',
  lat: 40.4,
  lng: -3.7,
  urlWeb: '',
  direccion: 'Calle Mayor, 1',
);

AvisosController _crearAvisos(FavoritosController favoritos) =>
    AvisosController(
      favoritos: favoritos,
      comprobador: ComprobadorFalso(),
      repositorio: AvisosRepositorio(almacen: AlmacenMemoria()),
      notificaciones: NotificacionesFalsas(),
      programador: ProgramadorFalso(),
    );

Widget _pantalla({
  required FavoritosController favoritos,
  HistorialController? historial,
  AvisosController? avisos,
}) => MultiProvider(
  providers: [
    ChangeNotifierProvider.value(value: favoritos),
    ChangeNotifierProvider(create: (_) => AliasController()),
    ChangeNotifierProvider.value(
      value: historial ?? HistorialController(api: ApiHistoricoFalsa()),
    ),
    if (avisos != null) ChangeNotifierProvider.value(value: avisos),
  ],
  child: MaterialApp(
    theme: AppTheme.oscuro,
    home: const Scaffold(
      body: FichaEstacionSheet(
        estacion: EstacionAviso(id: 7, nombre: 'Ballenoil'),
      ),
    ),
  ),
);

void main() {
  testWidgets('muestra los datos de una estación no favorita', (tester) async {
    final favoritos = FavoritosController(
      repositorio: RepositorioFalso(),
      api: ApiFalsa(detalles: {7: _detalle()}),
    );
    await favoritos.cargar();

    await tester.pumpWidget(_pantalla(favoritos: favoritos));
    await tester.pumpAndSettle();

    expect(find.text('Ballenoil'), findsWidgets);
    expect(find.text('Calle Mayor, 1'), findsOneWidget);
    expect(find.text('Gasolina 95'), findsWidgets);
    expect(find.text('1,729 €/L'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byIcon(Icons.notifications_none), findsNothing);
  });

  testWidgets('muestra la campana y la activa en una favorita', (tester) async {
    final favoritos = FavoritosController(
      repositorio: RepositorioFalso(),
      api: ApiFalsa(detalles: {7: _detalle()}),
    );
    await favoritos.cargar();
    await favoritos.alternar(_gasolinera());
    final avisos = _crearAvisos(favoritos);
    addTearDown(avisos.dispose);

    await tester.pumpWidget(_pantalla(favoritos: favoritos, avisos: avisos));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.notifications_none), findsOneWidget);

    await tester.tap(find.byIcon(Icons.notifications_none));
    await tester.pumpAndSettle();

    expect(find.text('Avisos activados'), findsOneWidget);
    expect(
      find.textContaining('Los datos se actualizan 2 veces al día'),
      findsOneWidget,
    );

    await tester.tap(find.text('Entendido'));
    await tester.pumpAndSettle();

    expect(favoritos.avisosActivos(7), isTrue);
    expect(find.byIcon(Icons.notifications_active_outlined), findsOneWidget);
  });

  testWidgets('muestra la carga mientras llega la ficha', (tester) async {
    final completer = Completer<DetalleEstacion>();
    final favoritos = FavoritosController(
      repositorio: RepositorioFalso(),
      api: ApiFalsa(completer: completer),
    );
    await favoritos.cargar();

    await tester.pumpWidget(_pantalla(favoritos: favoritos));
    await tester.pump();
    await tester.pump();

    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    completer.complete(_detalle());
    await tester.pumpAndSettle();

    expect(find.text('1,729 €/L'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('muestra el error y permite reintentar', (tester) async {
    final api = ApiFalsa(
      detalles: {},
      errores: {7: const ApiException(mensaje: 'Sin conexión.')},
    );
    final favoritos = FavoritosController(
      repositorio: RepositorioFalso(),
      api: api,
    );
    await favoritos.cargar();

    await tester.pumpWidget(_pantalla(favoritos: favoritos));
    await tester.pumpAndSettle();

    expect(find.text('Sin conexión.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);

    api.errores.clear();
    api.detalles[7] = _detalle();
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('1,729 €/L'), findsOneWidget);
    expect(find.text('Reintentar'), findsNothing);
  });

  testWidgets('indica cuando no hay precios', (tester) async {
    final favoritos = FavoritosController(
      repositorio: RepositorioFalso(),
      api: ApiFalsa(detalles: {7: _detalle(productos: [])}),
    );
    await favoritos.cargar();

    await tester.pumpWidget(_pantalla(favoritos: favoritos));
    await tester.pumpAndSettle();

    expect(find.text('Precios no disponibles'), findsOneWidget);
  });

  testWidgets(
    'al desmarcar la favorita mantiene los precios y oculta la campana',
    (tester) async {
      final favoritos = FavoritosController(
        repositorio: RepositorioFalso(),
        api: ApiFalsa(detalles: {7: _detalle()}),
      );
      await favoritos.cargar();
      await favoritos.alternar(_gasolinera());
      final avisos = _crearAvisos(favoritos);
      addTearDown(avisos.dispose);

      await tester.pumpWidget(_pantalla(favoritos: favoritos, avisos: avisos));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.notifications_none), findsOneWidget);

      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();

      expect(favoritos.esFavorito(7), isFalse);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none), findsNothing);
      expect(find.text('1,729 €/L'), findsOneWidget);
    },
  );
}
