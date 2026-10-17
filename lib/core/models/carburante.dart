enum Carburante {
  gasolina95('gasoline_95', 'Gasolina 95'),
  gasolina98('gasoline_98', 'Gasolina 98'),
  gasoleoA('diesel', 'Gasóleo A'),
  gasoleoPremium('diesel_premium', 'Gasóleo premium'),
  glp('lpg', 'GLP'),
  gnc('cng', 'GNC');

  const Carburante(this.idApi, this.etiqueta);

  final String idApi;
  final String etiqueta;

  static Carburante? desdeIdApi(String? id) {
    for (final carburante in Carburante.values) {
      if (carburante.idApi == id) return carburante;
    }
    return null;
  }
}
