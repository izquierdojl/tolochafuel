import 'carburante.dart';

enum CriterioEconomicas {
  gasolina95(Carburante.gasolina95),
  gasolina98(Carburante.gasolina98),
  gasoleoA(Carburante.gasoleoA),
  gasoleoPremium(Carburante.gasoleoPremium),
  glp(Carburante.glp),
  gnc(Carburante.gnc),
  media(null);

  const CriterioEconomicas(this.carburante);

  final Carburante? carburante;

  bool get esMedia => carburante == null;

  String get clave => carburante?.idApi ?? 'media';

  String get etiqueta => carburante?.etiqueta ?? 'Media de carburantes';

  static CriterioEconomicas desdeClave(String? clave) {
    if (clave == null) return CriterioEconomicas.gasolina95;
    if (clave == 'media') return CriterioEconomicas.media;
    for (final criterio in CriterioEconomicas.values) {
      if (criterio.carburante?.idApi == clave) return criterio;
    }
    return CriterioEconomicas.gasolina95;
  }
}
