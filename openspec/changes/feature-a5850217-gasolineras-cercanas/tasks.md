# Tasks

## 1. Cliente de la API y modelos

- [ ] 1.1 Añadir dependencias `http`, `provider` y `geolocator` a `pubspec.yaml`
- [ ] 1.2 Crear `lib/core/api/api_client.dart`: sobre `{data, meta}`, errores RFC 9457 y `ApiException`
- [ ] 1.3 Crear `lib/core/api/precios_gasolina_api.dart` con `nearby` y `buscarLugar` respetando límites
- [ ] 1.4 Crear modelos inmutables `Gasolinera`, `Carburante` y `MetaDatos` con parseo tolerante (coma decimal)
- [ ] 1.5 Tests de modelos y cliente con respuestas de ejemplo (incluido `stale`)

## 2. Ubicación

- [ ] 2.1 Servicio de ubicación sobre `geolocator` con permiso bajo demanda y estados
- [ ] 2.2 Modo manual: búsqueda por municipio y uso de sus coordenadas
- [ ] 2.3 Permisos de Android (`ACCESS_COARSE_LOCATION`/`ACCESS_FINE_LOCATION`) en `AndroidManifest.xml`

## 3. Pantalla principal

- [ ] 3.1 `CercanasController` (provider) con estados, cambio de carburante y caché en memoria
- [ ] 3.2 Tarjeta de gasolinera (rótulo, dirección, distancia, precio) usando el tema
- [ ] 3.3 Selector de carburante Gasolina 95 / Gasóleo A
- [ ] 3.4 Pie con antigüedad de datos y atribución CC BY 4.0 con enlace
- [ ] 3.5 Estados de carga, error con reintento y vacío, con mensajes en español
- [ ] 3.6 Widget tests: carga, error, vacío y con datos
- [ ] 3.7 `flutter analyze` + `flutter test` en verde y `dart format` aplicado
