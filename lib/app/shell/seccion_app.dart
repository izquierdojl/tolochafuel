enum SeccionApp {
  cercanas('cercanas', 'Cercanas'),
  favoritas('favoritas', 'Favoritas'),
  buscar('buscar', 'Buscar'),
  masEconomicas('masEconomicas', 'Más económicas'),
  configuracion('configuracion', 'Configuración');

  const SeccionApp(this.clave, this.titulo);

  final String clave;
  final String titulo;

  static const iniciales = [cercanas, favoritas, buscar, masEconomicas];

  static SeccionApp desdeClave(String? clave) {
    for (final seccion in values) {
      if (seccion.clave == clave) return seccion;
    }
    return SeccionApp.cercanas;
  }
}
