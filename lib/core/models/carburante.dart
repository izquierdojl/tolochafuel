enum Carburante {
  gasolina95('gasoline_95', 'Gasolina 95'),
  gasoleoA('diesel', 'Gasóleo A');

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
