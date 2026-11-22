# Tasks

## 1. Licencia y pantalla «Acerca de»

- [x] 1.1 Crear `LICENSE` con el texto MIT estándar («Copyright (c) 2026 TolochaFuel»)
  y actualizar `AGENTS.md` §4 y §11 para separar la licencia MIT del código de la
  CC BY 4.0 de los datos; verificar que el texto coincide con la plantilla MIT y que
  `grep -n "MIT" AGENTS.md LICENSE` muestra ambas referencias
- [x] 1.2 Añadir a `acerca_de_pantalla.dart` el tile «Licencia MIT del código» después
  del de CC BY 4.0, con enlace a `https://opensource.org/license/mit` y subtítulo que
  aclare que cubre el código; ampliar el test de «Acerca de» para exigir «Licencia MIT»
  y «CC BY 4.0»; verificar con `dart format`, `flutter analyze` y `flutter test` en verde

## 2. Índice, licencia y datos

- [x] 2.1 Crear `docs/licencia.md` con la separación MIT (código) / CC BY 4.0 (datos) y
  enlaces a `LICENSE`, Creative Commons y la fuente; verificar que los enlaces relativos
  resuelven y que la atribución coincide con `MetaDatos.atribucionPorDefecto`
- [x] 2.2 Crear `docs/datos.md` con la fuente (Ministerio y Gasolina hoy), frescura
  (dos veces al día, no tiempo real), límites (120/min, 30/min en consultas pesadas,
  radio 50 km, límite 50) y atribución CC BY 4.0; contrastar cada endpoint y campo con
  `lib/core/api/precios_gasolina_api.dart` y `lib/core/models/meta_datos.dart`, sin
  inventar campos
- [x] 2.3 Crear `docs/instalacion.md` con la descarga y los pasos por plataforma
  (Android APK, Windows ZIP portable y aviso de SmartScreen, Linux tar.gz/AppImage/
  Flatpak); verificar que los enlaces `releases/latest/download/...` y los nombres de
  los artefactos coinciden con `.github/workflows/release.yml`

## 3. Arquitectura y desarrollo

- [x] 3.1 Crear `docs/arquitectura.md` con la estructura `lib/app`, `lib/core` y
  `lib/features/<feature>`, el flujo API → repositorio → controlador → pantalla, la
  caché en memoria y el estado con `provider`; verificar que cada ruta mencionada existe
  con `find lib -type f`
- [x] 3.2 Crear `docs/desarrollo.md` con requisitos (Flutter 3.50.1, JDK 21, Android
  SDK), comandos (`flutter pub get`, `flutter run`, `npm run verify`), CI, versionado y
  el procedimiento reproducible de capturas del diseño; verificar que los comandos
  documentados existen en `package.json`/`scripts/verificar.sh` y que `flutter analyze`
  sigue en verde

## 4. Capturas de la app

- [x] 4.1 Preparar el AVD `Medium_Phone_API_37.0`, arrancarlo, fijar Madrid
  (`adb emu geo fix -3.7038 40.4168`) y conceder los permisos de ubicación a
  `com.izquierdojl.tolochafuel`; abrir la app y verificar que Cercanas muestra
  gasolineras con precios y distancias, sin errores ni estado vacío
- [x] 4.2 Capturar en tema claro Cercanas, histórico, Más económicas, Favoritas (con tres
  marcadas), Buscar, Configuración y Acerca de; verificar que existen las siete capturas
  y que cada una muestra el estado esperado, sin diálogos del sistema ni datos personales
- [x] 4.3 Capturar Cercanas y Más económicas en tema oscuro; verificar que el tema se
  aplica de verdad (fondos oscuros) y que las dos capturas existen
- [x] 4.4 Optimizar las nueve capturas a 540 px de ancho con ImageMagick y `optipng`,
  guardarlas en `docs/assets/capturas/` con los nombres del diseño y verificar con
  `identify` que miden 540 px de ancho, no conservan metadatos y que el total no supera
  ~1,5 MB

## 5. README divulgativo y guía de uso

- [x] 5.1 Crear `docs/uso.md` con las funciones explicadas para el usuario y las capturas
  por pantalla; verificar que todas las rutas de imagen existen y que el tono no usa
  jerga técnica sin explicarla
- [x] 5.2 Reescribir `README.md` con presentación, características, galería de capturas,
  descarga, nota de datos y atribución, tabla de documentación y licencia; verificar que
  no quedan comandos de desarrollo, que los enlaces a `docs/` y a las capturas existen y
  que el README renderiza la galería con rutas relativas
- [x] 5.3 Crear `docs/README.md` como índice de las páginas interiores ya escritas
  (para quién es cada una); verificar que cada enlace relativo resuelve y que el índice
  no incluye documentos planificados que no se hayan creado

## 6. Verificación final

- [x] 6.1 Comprobar todos los enlaces relativos de README y `docs/` con un script puntual
  que extraiga destinos Markdown y confirme que los ficheros existen; revisar que la
  atribución CC BY 4.0 aparece en README, `docs/datos.md`, `docs/licencia.md` y «Acerca
  de»
- [x] 6.2 Ejecutar `npm run verify` completo y `openspec validate
  docs-970cde25-renovar-el-readme-con-capturas-documentacion-tecnica-y-licencia-mit
  --strict`; verificar que formato, análisis, tests, checks de OpenSpec y validación
  estricta quedan en verde
- [x] 6.3 Revisar las capturas y el README renderizados (por ejemplo con un visor
  Markdown) para confirmar que no hay imágenes rotas, texto técnico residual ni
  discrepancias entre la captura y el pie de foto

## Workflow follow-up

- Commitear el change completo en `dev` con un mensaje `docs:` y comprobar con
  `git status` que no queda nada sin commitear (código, docs, capturas y specs).
- Archivar el change con `openspec archive` y verificar que `openspec/specs/configuracion`
  incorpora el requisito modificado.
- Hacer push a `dev`, vigilar la CI y, al fusionar en `main`, el bump automático de patch
  y la publicación del release.
