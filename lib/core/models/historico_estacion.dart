import '../utilidades/parseo.dart';

enum Tendencia { baja, sube, igual, desconocida }

class PuntoPrecio {
  const PuntoPrecio({required this.fecha, required this.precio});

  final DateTime fecha;
  final double precio;
}

class CambioPrecio {
  const CambioPrecio({
    required this.punto,
    required this.tendencia,
    required this.delta,
  });

  final PuntoPrecio punto;
  final Tendencia tendencia;
  final double delta;
}

class Variacion {
  const Variacion({required this.tendencia, this.delta, this.desde});

  final Tendencia tendencia;
  final double? delta;
  final DateTime? desde;
}

class SerieCarburante {
  const SerieCarburante({required this.idApi, required this.puntos});

  final String idApi;
  final List<PuntoPrecio> puntos;

  Tendencia get tendencia => variacion.tendencia;

  List<CambioPrecio> cambios({int maximo = 5}) {
    final cambios = <CambioPrecio>[];
    for (var i = 1; i < puntos.length; i++) {
      if (_milesimas(puntos[i].precio) != _milesimas(puntos[i - 1].precio)) {
        final delta = puntos[i].precio - puntos[i - 1].precio;
        cambios.add(
          CambioPrecio(
            punto: puntos[i],
            tendencia: delta < 0 ? Tendencia.baja : Tendencia.sube,
            delta: delta,
          ),
        );
      }
    }
    if (cambios.length <= maximo) return cambios;
    return cambios.sublist(cambios.length - maximo);
  }

  double? media(int registros) {
    if (registros < 1 || puntos.length < registros) return null;
    return _mediaDe(puntos.length - registros, registros);
  }

  Tendencia tendenciaMedia(int registros) {
    if (registros < 1 || puntos.length < registros * 2) {
      return Tendencia.desconocida;
    }
    final actual = _milesimas(_mediaDe(puntos.length - registros, registros));
    final anterior = _milesimas(
      _mediaDe(puntos.length - registros * 2, registros),
    );
    if (actual == anterior) return Tendencia.igual;
    return actual < anterior ? Tendencia.baja : Tendencia.sube;
  }

  double _mediaDe(int inicio, int registros) {
    var suma = 0.0;
    for (var i = inicio; i < inicio + registros; i++) {
      suma += puntos[i].precio;
    }
    return suma / registros;
  }

  int _milesimas(double precio) => (precio * 1000).round();

  Variacion get variacion {
    if (puntos.length < 2) {
      return const Variacion(tendencia: Tendencia.desconocida);
    }
    final precioActual = (puntos.last.precio * 1000).round();
    var inicio = puntos.length - 1;
    while (inicio > 0 &&
        (puntos[inicio - 1].precio * 1000).round() == precioActual) {
      inicio--;
    }
    for (var i = inicio - 1; i >= 0; i--) {
      if ((puntos[i].precio * 1000).round() == precioActual) continue;
      final delta = puntos.last.precio - puntos[i].precio;
      return Variacion(
        tendencia: delta < 0 ? Tendencia.baja : Tendencia.sube,
        delta: delta,
        desde: puntos[inicio].fecha,
      );
    }
    return Variacion(
      tendencia: Tendencia.igual,
      delta: 0.0,
      desde: puntos[inicio].fecha,
    );
  }
}

class HistoricoEstacion {
  const HistoricoEstacion({required this.series, this.proximaActualizacion});

  final List<SerieCarburante> series;
  final DateTime? proximaActualizacion;

  SerieCarburante? serie(String idApi) {
    for (final serie in series) {
      if (serie.idApi == idApi) return serie;
    }
    return null;
  }

  factory HistoricoEstacion.fromJson(
    Map<String, dynamic> data, {
    DateTime? proximaActualizacion,
  }) {
    final series = <SerieCarburante>[];
    final crudas = data['series'];
    if (crudas is List) {
      for (final item in crudas) {
        if (item is! Map<String, dynamic>) continue;
        final idApi = (item['fuel'] ?? '').toString();
        final puntos = <PuntoPrecio>[];
        final crudos = item['points'];
        if (crudos is List) {
          for (final punto in crudos) {
            if (punto is! Map<String, dynamic>) continue;
            final fecha = aFecha(punto['date']);
            final precio = aDouble(punto['price']);
            if (fecha == null || precio == null) continue;
            puntos.add(PuntoPrecio(fecha: fecha, precio: precio));
          }
        }
        if (idApi.isEmpty || puntos.isEmpty) continue;
        puntos.sort((a, b) => a.fecha.compareTo(b.fecha));
        series.add(SerieCarburante(idApi: idApi, puntos: puntos));
      }
    }
    return HistoricoEstacion(
      series: series,
      proximaActualizacion: proximaActualizacion,
    );
  }
}
