# Tasks

## 1. Repositorio y controlador de alias

- [x] 1.1 Crear `lib/features/alias/data/alias_repositorio.dart` con la clave
  `alias_estaciones` (objeto JSON `id -> alias`): `cargar` tolerante (clave ausente, JSON
  inválido, entradas no textuales o vacías se ignoran), `guardar` y `quitar`; tests de
  repositorio de ida y vuelta y de los casos inválidos (`flutter analyze` + `flutter test`
  en verde)
- [x] 1.2 Crear `lib/features/alias/ui/alias_controller.dart` (`ChangeNotifier` con mapa
  en memoria, `aliasDe`, `guardar`/`quitar` que notifican antes de persistir y devuelven
  `false` si la escritura falla); tests de controlador: asignar y quitar notifican y
  persisten, y guardado fallido devuelve `false` dejando el alias aplicado en memoria
  (`flutter analyze` + `flutter test` en verde)

## 2. Resolución del nombre y arranque

- [x] 2.1 Añadir la función pura de presentación en `lib/features/alias/ui/` (título y
  partes del subtítulo: alias como título, rótulo original en la línea secundaria, rótulo
  idéntico sin duplicar y «Sin rótulo» oculto cuando hay alias) con tests unitarios de
  todas las reglas (`flutter analyze` + `flutter test` en verde)
- [x] 2.2 Registrar `AliasController` en `lib/main.dart` y cargarlo con `Future.wait`
  junto a favoritos y configuración, antes de `runApp` (`flutter analyze` + `flutter test`
  en verde)

## 3. Menú, diálogo y presentación en las pantallas

- [x] 3.1 Crear `DialogoAlias` en `lib/features/alias/ui/dialogo_alias.dart` (precargado
  con el alias actual, máximo 40 caracteres, ayudas «Sustituye a: …» y «Solo se guarda en
  este dispositivo», acciones Guardar, Cancelar y Quitar alias); widget tests del diálogo:
  precarga, guardar texto, quitar alias y límite de 40 caracteres (`flutter analyze` +
  `flutter test` en verde)
- [x] 3.2 Añadir el menú de acciones (⋮) a `TarjetaGasolinera` («Poner alias…» /
  «Editar alias…»), conectar el diálogo y el controlador (aviso en español si falla el
  guardado) y aplicar la presentación con alias y rótulo; widget tests: tarjeta con alias,
  sin alias, alias igual al rótulo, estación sin rótulo, menú y aviso de fallo (`flutter
  analyze` + `flutter test` en verde)
- [x] 3.3 Usar el alias en el encabezado de `DetalleHistorico` cuando exista; widget test
  del encabezado con y sin alias (`flutter analyze` + `flutter test` en verde)

## 4. Verificación

- [x] 4.1 Verificación final: `dart format .` aplicado, `flutter analyze` +
  `flutter test` en verde, `bash scripts/check_changes.sh` correcto y revisión manual del
  menú, el diálogo y la presentación con alias en tema claro y oscuro en Android y
  escritorio (sin colores literales en widgets)

## Workflow follow-up

- Commit en `dev` (código + specs) y archivar el change cuando esté verificado, con
  `git status` limpio.
