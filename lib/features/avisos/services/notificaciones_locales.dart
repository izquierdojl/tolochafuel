import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../data/aviso_notificacion.dart';
import 'notificaciones_servicio.dart';

class NotificacionesLocales implements NotificacionesServicio {
  NotificacionesLocales({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const canalId = 'avisos_precio';
  static const canalNombre = 'Avisos de precio';
  static const canalDescripcion =
      'Cambios de precio en tus gasolineras favoritas';
  static const grupo = 'avisos_precio';

  final FlutterLocalNotificationsPlugin _plugin;
  bool _inicializado = false;

  @override
  Future<void> inicializar({
    required void Function(String? payload) alTocar,
  }) async {
    if (_inicializado || kIsWeb) return;
    try {
      final settings = InitializationSettings(
        android: const AndroidInitializationSettings('ic_stat_tolocha'),
        iOS: const DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        macOS: const DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        linux: const LinuxInitializationSettings(defaultActionName: 'Abrir'),
        windows: const WindowsInitializationSettings(
          appName: 'TolochaFuel',
          appUserModelId: 'com.izquierdojl.tolochafuel',
          guid: '6f1c2f5e-3a4b-4c8d-9e2f-1a3b5c7d9e0f',
        ),
      );
      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (respuesta) {
          if (respuesta.notificationResponseType ==
              NotificationResponseType.selectedNotification) {
            alTocar(respuesta.payload);
          }
        },
      );
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        await android.createNotificationChannel(
          const AndroidNotificationChannel(
            canalId,
            canalNombre,
            description: canalDescripcion,
            importance: Importance.defaultImportance,
          ),
        );
      }
      _inicializado = true;
    } catch (_) {
      _inicializado = false;
    }
  }

  @override
  Future<String?> lanzamientoInicial() async {
    if (!_inicializado) return null;
    try {
      final detalles = await _plugin.getNotificationAppLaunchDetails();
      if (detalles == null || !detalles.didNotificationLaunchApp) return null;
      return detalles.notificationResponse?.payload;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> solicitarPermiso() async {
    if (!_inicializado) return true;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return true;
    try {
      if (await android.areNotificationsEnabled() ?? false) return true;
      final concedido = await android.requestNotificationsPermission();
      if (concedido == false) return false;
      return await android.areNotificationsEnabled() ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> estanHabilitadas() async {
    if (!_inicializado) return true;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return true;
    try {
      return await android.areNotificationsEnabled() ?? true;
    } catch (_) {
      return true;
    }
  }

  @override
  Future<bool> mostrar(AvisoNotificacion aviso) async {
    if (!_inicializado) return false;
    try {
      final android = AndroidNotificationDetails(
        canalId,
        canalNombre,
        channelDescription: canalDescripcion,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        groupKey: grupo,
        styleInformation: BigTextStyleInformation(aviso.textoLargo),
      );
      await _plugin.show(
        id: aviso.estacionId,
        title: aviso.titulo,
        body: aviso.cuerpo,
        notificationDetails: NotificationDetails(
          android: android,
          linux: const LinuxNotificationDetails(),
          windows: const WindowsNotificationDetails(),
        ),
        payload: aviso.payload,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> cancelar(int id) async {
    if (!_inicializado) return;
    try {
      await _plugin.cancel(id: id);
    } catch (_) {
      return;
    }
  }

  @override
  Future<void> cancelarTodas() async {
    if (!_inicializado) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {
      return;
    }
  }
}
