const margenAvisos = Duration(minutes: 5);
const reintentoAvisos = Duration(hours: 1);
const respaldoAvisos = Duration(hours: 12);
const demoraMinimaAvisos = Duration(minutes: 15);

Duration calcularDemoraAvisos({DateTime? proxima, required DateTime ahora}) {
  if (proxima == null) return respaldoAvisos;
  final objetivo = proxima.toUtc().add(margenAvisos);
  final diferencia = objetivo.difference(ahora.toUtc());
  if (diferencia <= Duration.zero) return reintentoAvisos;
  if (diferencia < demoraMinimaAvisos) return demoraMinimaAvisos;
  return diferencia;
}
