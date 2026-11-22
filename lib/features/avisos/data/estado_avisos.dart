import '../../../core/utilidades/parseo.dart';

class BasePrecios {
  const BasePrecios({
    required this.precios,
    required this.actualizadoEn,
    this.lastUpdated,
  });

  final Map<String, int> precios;
  final DateTime actualizadoEn;
  final DateTime? lastUpdated;

  BasePrecios copyWith({
    Map<String, int>? precios,
    DateTime? actualizadoEn,
    DateTime? lastUpdated,
  }) => BasePrecios(
    precios: precios ?? this.precios,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );

  Map<String, dynamic> toJson() => {
    'precios': precios,
    'actualizado_en': actualizadoEn.toUtc().toIso8601String(),
    if (lastUpdated != null)
      'last_updated': lastUpdated!.toUtc().toIso8601String(),
  };

  static BasePrecios? fromJson(Map<String, dynamic> json) {
    final precios = <String, int>{};
    final crudos = json['precios'];
    if (crudos is Map<String, dynamic>) {
      for (final entrada in crudos.entries) {
        final valor = aEntero(entrada.value);
        if (valor != null && valor > 0) precios[entrada.key] = valor;
      }
    }
    final actualizado = aFecha(json['actualizado_en']);
    final lastUpdated = aFecha(json['last_updated']);
    if (precios.isEmpty && actualizado == null && lastUpdated == null) {
      return null;
    }
    return BasePrecios(
      precios: precios,
      actualizadoEn:
          actualizado ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      lastUpdated: lastUpdated,
    );
  }
}

class EstadoAvisos {
  const EstadoAvisos({
    this.estaciones = const {},
    this.ultimaComprobacion,
    this.ultimoLastUpdated,
    this.proximaComprobacion,
    this.lockHasta,
  });

  final Map<int, BasePrecios> estaciones;
  final DateTime? ultimaComprobacion;
  final DateTime? ultimoLastUpdated;
  final DateTime? proximaComprobacion;
  final DateTime? lockHasta;

  EstadoAvisos copyWith({
    Map<int, BasePrecios>? estaciones,
    DateTime? ultimaComprobacion,
    DateTime? ultimoLastUpdated,
    DateTime? proximaComprobacion,
    DateTime? lockHasta,
    bool limpiarBloqueo = false,
  }) => EstadoAvisos(
    estaciones: estaciones ?? this.estaciones,
    ultimaComprobacion: ultimaComprobacion ?? this.ultimaComprobacion,
    ultimoLastUpdated: ultimoLastUpdated ?? this.ultimoLastUpdated,
    proximaComprobacion: proximaComprobacion ?? this.proximaComprobacion,
    lockHasta: limpiarBloqueo ? null : (lockHasta ?? this.lockHasta),
  );

  EstadoAvisos conBase(int id, BasePrecios base) =>
      copyWith(estaciones: {...estaciones, id: base});

  EstadoAvisos sinBase(int id) => copyWith(
    estaciones: {
      for (final entrada in estaciones.entries)
        if (entrada.key != id) entrada.key: entrada.value,
    },
  );

  EstadoAvisos soloEstaciones(Set<int> ids) => copyWith(
    estaciones: {
      for (final entrada in estaciones.entries)
        if (ids.contains(entrada.key)) entrada.key: entrada.value,
    },
  );

  Map<String, dynamic> toJson() => {
    'estaciones': {
      for (final entrada in estaciones.entries)
        '${entrada.key}': entrada.value.toJson(),
    },
    if (ultimaComprobacion != null)
      'ultima_comprobacion': ultimaComprobacion!.toUtc().toIso8601String(),
    if (ultimoLastUpdated != null)
      'ultimo_last_updated': ultimoLastUpdated!.toUtc().toIso8601String(),
    if (proximaComprobacion != null)
      'proxima_comprobacion': proximaComprobacion!.toUtc().toIso8601String(),
    if (lockHasta != null) 'lock_hasta': lockHasta!.toUtc().toIso8601String(),
  };

  static EstadoAvisos fromJson(Map<String, dynamic> json) {
    final estaciones = <int, BasePrecios>{};
    final crudas = json['estaciones'];
    if (crudas is Map<String, dynamic>) {
      for (final entrada in crudas.entries) {
        final id = int.tryParse(entrada.key);
        final valor = entrada.value;
        if (id == null || valor is! Map<String, dynamic>) continue;
        final base = BasePrecios.fromJson(valor);
        if (base != null) estaciones[id] = base;
      }
    }
    return EstadoAvisos(
      estaciones: estaciones,
      ultimaComprobacion: aFecha(json['ultima_comprobacion']),
      ultimoLastUpdated: aFecha(json['ultimo_last_updated']),
      proximaComprobacion: aFecha(json['proxima_comprobacion']),
      lockHasta: aFecha(json['lock_hasta']),
    );
  }
}
