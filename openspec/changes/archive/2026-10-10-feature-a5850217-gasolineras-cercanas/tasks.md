# Tasks

## 1. Cliente de la API y modelos

- [x] 1.1 Añadir dependencias `http`, `provider` y `geolocator` a `pubspec.yaml` (y `url_launcher` para el enlace de atribución; `flutter_svg` para el emblema)
- [x] 1.2 Crear `lib/core/api/api_client.dart`: sobre `{data, meta}`, errores RFC 9457 y `ApiException`
- [x] 1.3 Crear `lib/core/api/precios_gasolina_api.dart` con `nearby` y `buscarLugar` respetando límites
- [x] 1.4 Crear modelos inmutables `Gasolinera`, `Carburante` y `MetaDatos` con parseo tolerante (coma decimal)
- [x] 1.5 Tests de modelos y cliente con respuestas de ejemplo (incluido `stale`)

## 2. Ubicación y modo manual

- [x] 2.1 Servicio de ubicación sobre `geolocator` con permiso bajo demanda y estados
- [x] 2.2 Modo manual: búsqueda por municipio/provincia y carga de las más baratas del territorio (`level`+`code`, sin coordenadas ni distancias)
- [x] 2.3 Permisos de Android (`ACCESS_COARSE_LOCATION`/`ACCESS_FINE_LOCATION`) en `AndroidManifest.xml`

## 3. Pantalla principal

- [x] 3.1 `CercanasController` (provider) con estados y caché en memoria
- [x] 3.2 Ficha de estación en la API (`detalle(id)`): `ProductoPrecio`, `DetalleEstacion` y fusión con caché por id y concurrencia limitada
- [x] 3.3 Tarjeta de gasolinera: nombre, dirección, distancia y **todos los productos con sus precios** («Precios no disponibles» si falla la ficha); retirar el selector de carburante
- [x] 3.4 Cabecera con el emblema Tolocha (SVG de tolocharadio) y la marca «TolochaFuel» con **Inter** empaquetada (400/500/600/700)
- [x] 3.5 Pie con antigüedad de datos y atribución CC BY 4.0 con enlace
- [x] 3.6 Estados de carga, error con reintento y vacío, con mensajes en español
- [x] 3.7 Tests: modelos de ficha, repositorio (caché de fichas y fallo parcial) y widgets (productos, sin selector, cabecera)
- [x] 3.8 `flutter analyze` + `flutter test` en verde y `dart format` aplicado
