import 'dart:math';

import '../../../core/api/api_client.dart';
import '../../../core/api/precios_gasolina_api.dart';
import '../../../core/models/detalle_estacion.dart';
import '../../../core/models/meta_datos.dart';
import '../../alias/data/alias_repositorio.dart';
import '../../favoritos/data/favorito.dart';
import '../../favoritos/data/favoritos_repositorio.dart';
import '../data/aviso_notificacion.dart';
import '../data/aviso_precio.dart';
import '../data/avisos_repositorio.dart';
import '../data/estado_avisos.dart';
import 'diferencia_precios.dart';
import 'formato_aviso.dart';
import 'notificaciones_servicio.dart';
import 'programador_avisos.dart';

enum ResultadoBase { creada, sinPrecios, error }

abstract class ComprobadorAvisos {
  Future<ResultadoComprobacion> comprobar();

  Future<ResultadoBase> crearBase(int estacionId);
}

class ComprobadorAvisosApi implements ComprobadorAvisos {
  ComprobadorAvisosApi({
    PreciosGasolinaApi? api,
    FavoritosRepositorio? favoritos,
    AvisosRepositorio? avisos,
    AliasRepositorio? alias,
    NotificacionesServicio? notificaciones,
    ProgramadorAvisos? programador,
    DateTime Function()? ahora,
  }) : _api = api ?? PreciosGasolinaApi(),
       _favoritos = favoritos ?? FavoritosRepositorio(),
       _avisos = avisos ?? AvisosRepositorio(),
       _alias = alias ?? AliasRepositorio(),
       _notificaciones = notificaciones ?? const NotificacionesNulas(),
       _programador = programador ?? ProgramadorPrimerPlano(),
       _ahora = ahora ?? (() => DateTime.now().toUtc());

  static const concurrencia = 4;

  final PreciosGasolinaApi _api;
  final FavoritosRepositorio _favoritos;
  final AvisosRepositorio _avisos;
  final AliasRepositorio _alias;
  final NotificacionesServicio _notificaciones;
  final ProgramadorAvisos _programador;
  final DateTime Function() _ahora;

  @override
  Future<ResultadoComprobacion> comprobar() async {
    final ahora = _ahora().toUtc();
    final favoritos = await _favoritos.cargarAsync();
    final avisados = favoritos
        .where((favorito) => favorito.avisosPrecio)
        .toList();
    if (avisados.isEmpty) {
      await _programador.cancelar();
      return ResultadoComprobacion.vacio;
    }

    var estado = await _avisos.cargar();
    final faltaBase = avisados.any(
      (favorito) => estado.estaciones[favorito.id] == null,
    );
    final proxima = estado.proximaComprobacion?.toUtc();
    if (!faltaBase && proxima != null && ahora.isBefore(proxima)) {
      await _programador.programar(proxima);
      return ResultadoComprobacion.vacio;
    }

    if (!await _avisos.adquirirBloqueo(ahora)) {
      await _programador.programar(ahora.add(const Duration(minutes: 15)));
      return ResultadoComprobacion.vacio;
    }

    var peticiones = 0;
    void contar() => peticiones++;

    try {
      final primera = await _primeraFicha(avisados, contar);
      if (primera == null) {
        final siguiente = ahora.add(const Duration(hours: 1));
        await _guardarYProgramar(
          estado.copyWith(proximaComprobacion: siguiente),
          siguiente,
        );
        return ResultadoComprobacion(
          peticiones: peticiones,
          error: 'No se pudieron consultar los precios de las favoritas.',
        );
      }

      final detalle = primera.detalle;
      final meta = detalle.meta;
      final lastUpdated = meta?.ultimaActualizacion?.toUtc();
      final baseFaltante = avisados
          .where((favorito) => estado.estaciones[favorito.id] == null)
          .toList();

      if (baseFaltante.isEmpty &&
          lastUpdated != null &&
          estado.ultimoLastUpdated?.toUtc() == lastUpdated) {
        final siguiente = _siguiente(meta, ahora);
        estado = estado.copyWith(
          ultimaComprobacion: ahora,
          ultimoLastUpdated: lastUpdated,
          proximaComprobacion: siguiente,
          limpiarBloqueo: true,
        );
        await _guardarYProgramar(estado, siguiente);
        return ResultadoComprobacion(peticiones: peticiones);
      }

      if (lastUpdated != null &&
          estado.ultimoLastUpdated?.toUtc() == lastUpdated) {
        final detalles = await _descargar(
          baseFaltante,
          yaDescargada: primera.id,
          detalle: detalle,
          contar: contar,
        );
        for (final entrada in detalles.entries) {
          final precios = preciosDesdeProductos(entrada.value.productos);
          if (precios.isEmpty) continue;
          estado = estado.conBase(
            entrada.key,
            BasePrecios(
              precios: precios,
              actualizadoEn: ahora,
              lastUpdated: entrada.value.meta?.ultimaActualizacion?.toUtc(),
            ),
          );
        }
        final siguiente = _siguiente(meta, ahora);
        estado = estado.copyWith(
          ultimaComprobacion: ahora,
          ultimoLastUpdated: lastUpdated,
          proximaComprobacion: siguiente,
          limpiarBloqueo: true,
        );
        await _guardarYProgramar(estado, siguiente);
        return ResultadoComprobacion(peticiones: peticiones);
      }

      final detalles = await _descargar(
        avisados,
        yaDescargada: primera.id,
        detalle: detalle,
        contar: contar,
      );
      final pendientes = <AvisoPrecio>[];
      for (final favorito in avisados) {
        final detalleActual = detalles[favorito.id];
        if (detalleActual == null) continue;
        final precios = preciosDesdeProductos(detalleActual.productos);
        if (precios.isEmpty) continue;
        final base = estado.estaciones[favorito.id];
        if (base == null) {
          estado = estado.conBase(
            favorito.id,
            BasePrecios(
              precios: precios,
              actualizadoEn: ahora,
              lastUpdated: detalleActual.meta?.ultimaActualizacion?.toUtc(),
            ),
          );
          continue;
        }
        final cambios = calcularCambios(
          base: base.precios,
          productos: detalleActual.productos,
        );
        estado = estado.conBase(
          favorito.id,
          BasePrecios(
            precios: precios,
            actualizadoEn: ahora,
            lastUpdated: detalleActual.meta?.ultimaActualizacion?.toUtc(),
          ),
        );
        if (cambios.isEmpty) continue;
        pendientes.add(
          AvisoPrecio(
            estacionId: favorito.id,
            nombre: favorito.nombre,
            cambios: cambios,
            lastUpdated: detalleActual.meta?.ultimaActualizacion?.toUtc(),
            stale: detalleActual.meta?.stale ?? false,
          ),
        );
      }

      final actuales = await _favoritos.cargarAsync();
      final porId = {for (final favorito in actuales) favorito.id: favorito};
      final alias = await _alias.cargarAsync();
      final publicados = <AvisoNotificacion>[];
      final enApp = <AvisoNotificacion>[];
      for (final aviso in pendientes) {
        final favorito = porId[aviso.estacionId];
        if (favorito == null || !favorito.avisosPrecio) continue;
        final notificacion = formatearAviso(
          aviso: aviso,
          alias: alias[aviso.estacionId],
        );
        if (await _notificaciones.mostrar(notificacion)) {
          publicados.add(notificacion);
        } else {
          enApp.add(notificacion);
        }
      }

      final siguiente = _siguiente(meta, ahora);
      estado = estado.copyWith(
        ultimaComprobacion: ahora,
        ultimoLastUpdated: lastUpdated ?? estado.ultimoLastUpdated,
        proximaComprobacion: siguiente,
        limpiarBloqueo: true,
      );
      await _guardarYProgramar(estado, siguiente);
      return ResultadoComprobacion(
        avisos: publicados,
        avisosEnApp: enApp,
        peticiones: peticiones,
      );
    } on ApiException catch (error) {
      final siguiente = ahora.add(const Duration(hours: 1));
      await _guardarYProgramar(
        estado.copyWith(proximaComprobacion: siguiente, limpiarBloqueo: true),
        siguiente,
      );
      return ResultadoComprobacion(
        peticiones: peticiones,
        error: error.mensaje,
      );
    } catch (_) {
      final siguiente = ahora.add(const Duration(hours: 1));
      await _guardarYProgramar(
        estado.copyWith(proximaComprobacion: siguiente, limpiarBloqueo: true),
        siguiente,
      );
      return ResultadoComprobacion(
        peticiones: peticiones,
        error: 'No se pudieron comprobar los avisos.',
      );
    } finally {
      await _avisos.liberarBloqueo();
    }
  }

  @override
  Future<ResultadoBase> crearBase(int estacionId) async {
    final ahora = _ahora().toUtc();
    if (!await _avisos.adquirirBloqueo(ahora)) return ResultadoBase.error;
    try {
      final detalle = await _api.detalle(estacionId);
      final precios = preciosDesdeProductos(detalle.productos);
      if (precios.isEmpty) return ResultadoBase.sinPrecios;
      var estado = await _avisos.cargar();
      final meta = detalle.meta;
      final lastUpdated = meta?.ultimaActualizacion?.toUtc();
      final siguiente = _siguiente(meta, ahora);
      estado = estado.conBase(
        estacionId,
        BasePrecios(
          precios: precios,
          actualizadoEn: ahora,
          lastUpdated: lastUpdated,
        ),
      );
      estado = estado.copyWith(
        ultimaComprobacion: ahora,
        ultimoLastUpdated: lastUpdated,
        proximaComprobacion: siguiente,
        limpiarBloqueo: true,
      );
      await _guardarYProgramar(estado, siguiente);
      return ResultadoBase.creada;
    } on ApiException {
      return ResultadoBase.error;
    } catch (_) {
      return ResultadoBase.error;
    } finally {
      await _avisos.liberarBloqueo();
    }
  }

  Future<_Ficha?> _primeraFicha(
    List<Favorito> favoritos,
    void Function() contar,
  ) async {
    for (final favorito in favoritos.take(3)) {
      contar();
      try {
        return _Ficha(
          id: favorito.id,
          detalle: await _api.detalle(favorito.id),
        );
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  Future<Map<int, DetalleEstacion>> _descargar(
    List<Favorito> favoritos, {
    required int? yaDescargada,
    required DetalleEstacion? detalle,
    required void Function() contar,
  }) async {
    final detalles = <int, DetalleEstacion>{};
    if (yaDescargada != null &&
        detalle != null &&
        favoritos.any((favorito) => favorito.id == yaDescargada)) {
      detalles[yaDescargada] = detalle;
    }
    final resto = favoritos
        .where((favorito) => favorito.id != yaDescargada)
        .toList();
    for (var i = 0; i < resto.length; i += concurrencia) {
      final lote = resto.sublist(i, min(i + concurrencia, resto.length));
      await Future.wait(
        lote.map((favorito) async {
          contar();
          try {
            detalles[favorito.id] = await _api.detalle(favorito.id);
          } catch (_) {
            return;
          }
        }),
      );
    }
    return detalles;
  }

  DateTime _siguiente(MetaDatos? meta, DateTime ahora) =>
      meta?.proximaActualizacion?.toUtc() ??
      ahora.add(const Duration(hours: 12));

  Future<void> _guardarYProgramar(
    EstadoAvisos estado,
    DateTime siguiente,
  ) async {
    await _avisos.guardar(estado);
    await _programador.programar(siguiente);
  }
}

class _Ficha {
  const _Ficha({required this.id, required this.detalle});

  final int id;
  final DetalleEstacion detalle;
}
