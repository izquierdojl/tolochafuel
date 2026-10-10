# Tasks

## 1. Configuración y persistencia

- [x] 1.1 Añadir `shared_preferences` a `pubspec.yaml` (si no estuviera) y verificar `flutter pub get` sin errores
- [x] 1.2 Crear `ConfiguracionRepositorio` en `lib/features/configuracion/data/` con las claves `tema`, `radioKm` y `pantallaInicial`, valores por defecto (oscuro, 25 km, Cercanas) y fallo tolerante; tests unitarios de ida y vuelta con `SharedPreferences.setMockInitialValues`
- [x] 1.3 Crear `ConfiguracionController` (provider) con setters que persisten y notifican; tests unitarios de cambio de cada preferencia y de fallo al guardar (sigue con valores por defecto y aviso)
- [x] 1.4 Cargar las preferencias en `main()` antes de `runApp` y conectar `themeMode` al controlador; verificación: widget test del tema inicial con una preferencia simulada
- [x] 1.5 Pantalla Configuración con el selector de tema claro/oscuro; widget test: cambio instantáneo y persistencia simulada
- [x] 1.6 Selector de radio 10–50 km (25 por defecto) con la nota del máximo de la API; widget test del rango, el valor por defecto y la nota
- [x] 1.7 Selector de pantalla inicial (Cercanas, Favoritas, Buscar y Más económicas; sin Configuración); widget test de las opciones y del valor por defecto
- [x] 1.8 Sección «Acerca de…» con nombre, explicación de la fuente, atribución completa y enlace a la licencia CC BY 4.0; widget test del contenido
- [x] 1.9 `flutter analyze` + `flutter test` en verde y `dart format` aplicado

## 2. Shell de navegación

- [x] 2.1 Crear `SeccionApp` y `ShellPantalla` en `lib/app/shell/` con AppBar (cabecera Tolocha + botón de menú), `NavigationDrawer` e `IndexedStack` perezoso; widget test: abrir el menú, ver las cinco secciones, sección activa resaltada y cierre al elegir
- [x] 2.2 Sección inicial tomada de `ConfiguracionController`; widget test con preferencia simulada (arranca en «Más económicas» sin mover la sección actual al cambiarla)
- [x] 2.3 Conservación del estado: mantener montadas las secciones visitadas; widget test Cercanas→Buscar→Cercanas con repositorio contador que comprueba que no se repiten peticiones
- [x] 2.4 Integrar en el shell las pantallas de Cercanas, Configuración y Favoritas (`FavoritosPantalla` del change `feature-de2139cb-favoritos`); verificar compilación y widget test de navegación a Favoritas
- [x] 2.5 `flutter analyze` + `flutter test` en verde y `dart format` aplicado

## 3. Cercanas con radio configurado

- [x] 3.1 `CercanasController` usa `ConfiguracionController.radioKm` y recarga cuando el radio cambia; tests unitarios de recarga al cambiar el radio y de reutilización sin cambio
- [x] 3.2 Adaptar `CercanasPantalla` al shell, sin panel manual embebido: aviso sin ubicación con botón «Ir a Buscar»; widget tests de carga, error, vacío y datos
- [x] 3.3 Actualizar `test/features/cercanas_pantalla_test.dart` al nuevo shell y al aviso con enlace a Buscar; `flutter test` en verde
- [x] 3.4 `flutter analyze` + `flutter test` en verde y `dart format` aplicado

## 4. Sección Buscar

- [x] 4.1 `BuscarController` (búsqueda de lugares, selección, estados y reintento) reutilizando `buscarLugar` y `masBaratas`; tests unitarios de coincidencias, sin coincidencias y error
- [x] 4.2 `BuscarPantalla` con campo de municipio/provincia, lista de coincidencias y «Orden por Gasolina 95»; widget tests de carga, error, vacío y datos
- [x] 4.3 Retirar `PanelBusquedaManual` y el modo manual de `CercanasController`/pantalla; `flutter analyze` sin referencias muertas
- [x] 4.4 `flutter analyze` + `flutter test` en verde y `dart format` aplicado

## 5. Sección Más económicas

- [x] 5.1 `CercanasRepositorio.masEconomicas({lat, lng, radioKm})` con `/v1/stations/cheapest` (`fuel=gasoline_95`, `limit` 20) y caché por clave; test unitario con API simulada (mismo radio reutiliza caché; radio distinto vuelve a consultar)
- [x] 5.2 `MasEconomicasController` (ubicación, radio, estados y sin ubicación → acceso a Buscar); tests unitarios de cada estado
- [x] 5.3 `MasEconomicasPantalla` con la indicación del orden por Gasolina 95 y distancia; widget tests de carga, error, vacío y datos
- [x] 5.4 `flutter analyze` + `flutter test` en verde y `dart format` aplicado

## 6. Verificación integrada

- [x] 6.1 `flutter analyze && flutter test` y `dart format --set-exit-if-changed .` en verde
- [x] 6.2 Prueba manual en Android (menú, tema, radio, pantalla inicial, atribución) y en Windows (`flutter build windows` y fallback de Cercanas a Buscar)

## 7. Atribución solo en «Acerca de» (decisión del usuario)

- [x] 7.1 Retirar `PieAtribucion` de Cercanas, Buscar, Más económicas y Favoritos, eliminar el widget y ajustar los tests sin aserciones de atribución
- [x] 7.2 Actualizar AGENTS.md (§4 y advisory 2), proposal, design y specs delta (gasolineras REMOVED y favoritos MODIFIED), y enlace a GitHub en «Acerca de»
- [x] 7.3 `flutter analyze` + `flutter test` en verde y `dart format` aplicado

## Workflow follow-up

- Prerrequisito: actualizar el plan del change `feature-de2139cb-favoritos` (su tarea de barra inferior pasa a ser el destino del menú) y aplicarlo antes de implementar la sección Favoritas.
- Archivar el change tras el merge en `dev`, con `git status` limpio (código + specs incluidos).
- El versionado lo dispara la fusión en `main`; no tocar la versión a mano.
