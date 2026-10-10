# AGENTS.md — TolochaFuel

Constitución del proyecto. Estas reglas gobiernan todo el desarrollo de este repositorio
y **prevalecen sobre costumbres externas**. Si una instrucción puntual contradice este
documento, se detiene y se consulta al usuario.

## 1. Proyecto

TolochaFuel es una app móvil y de escritorio, en Flutter/Dart, para consultar los precios
de los carburantes de las gasolineras cercanas en España: lista ordenada por cercanía con
distancia, navegación a la gasolinera y favoritos. Nace como proyecto de práctica de
Flutter y del flujo spec-driven con OpenSpec: ninguna funcionalidad se implementa sin un
change propuesto.

- Idioma de UI, documentación, commits y conversación: **español**.
- Referencia de estilo, estructura y lecciones aprendidas: `izquierdojl/tolocharadio`
  (paleta pine/ochre/moss, tipografía Inter, tema oscuro por defecto + claro).
- Versión inicial en `0.x` hasta que la app sea usable; `1.0.0` lo decide el usuario.

## 2. Stack tecnológico

| Capa | Decisión |
|---|---|
| Framework | Flutter estable (versión fijada en CI; SDK local en `~/flutter`). |
| Lenguaje | Dart estricto con `flutter_lints`; `dart format` como formateador. |
| Datos | API pública `https://api.preciosgasolina.es/v1` — **sin backend propio**. HTTP con el paquete `http`. |
| Ubicación | `geolocator` en Android; en escritorio *fallback* a búsqueda manual por municipio/provincia. |
| Estado | `provider` (suficiente para el alcance; sin gestores complejos). |
| Navegación externa | `url_launcher`: intents `geo:`/Google Maps en Android; Maps web en escritorio. |
| Persistencia local | `shared_preferences` (favoritos y ajustes). |
| Calidad | `flutter analyze` + `flutter test` + `dart format`; widget tests de los estados clave. |
| Entorno | WSL2 (Ubuntu). Código en `~/dev`, nunca en `/mnt/c`. Flutter, JDK 17 y Android SDK en rutas de usuario. |
| Distribución | GitHub Releases: **APK** (Android), **ZIP portable** (Windows) y **tar.gz/AppImage/Flatpak** (Linux); iOS, web/PWA y Play Store aplazados; **sin Docker**. |

Stack cerrado: **no se cambia de framework, librerías base ni gestor de paquetes** sin
decisión explícita del usuario y actualización de este documento.

## 3. Arquitectura

- **Estructura**: `lib/app` (arranque, tema, rutas) · `lib/core` (cliente API, modelos,
  utilidades) · `lib/features/<feature>/` (`data/` repositorio + `ui/` pantallas y widgets).
- El **único** punto que habla con la API es el cliente de `lib/core/api`; los
  repositorios de cada feature lo consumen.
- **Sin lógica de negocio en widgets**: las pantallas llaman a repositorios/servicios.
- **Tema centralizado** en `lib/app/theme` con la paleta de tolocharadio; nunca colores
  literales en widgets.
- Modelos inmutables con parseo tolerante (la API devuelve algunos campos como texto con
  coma decimal; normalizar en el parseo).
- **Caché en memoria** con TTL alineada con la frescura real de la API (se actualiza 2
  veces al día): no se hace polling; las peticiones pesadas se minimizan.

## 4. Datos, límites y licencia

- Fuente: precios oficiales que las gasolineras comunican al **Ministerio para la
  Transición Ecológica y el Reto Demográfico**, servidos por **Gasolina hoy**
  (`api.preciosgasolina.es`, sin clave, solo lectura).
- Límites de la API: 120 peticiones/min por IP (30/min en consultas pesadas), `limit`
  ≤ 50, radio ≤ 50 km, histórico ≤ 90 días.
- **Atribución obligatoria y visible** (CC BY 4.0): «Gasolina hoy (preciosgasolina.es),
  con datos del Ministerio para la Transición Ecológica y el Reto Demográfico».
- La atribución y la frescura de los datos viven en Configuración → Acerca de, no junto
  a los precios (decisión del usuario, 2026-10-10); los precios se actualizan 2 veces al
  día y no son tiempo real.

## 5. Plataformas

- **Android**: plataforma principal. El permiso de ubicación se pide solo al usarlo y
  nunca se añaden permisos innecesarios.
- **Windows**: plataforma secundaria; debe mantenerse compilando (`flutter build windows`
  en CI). Ubicación con fallback manual; «navegar» abre Google Maps en el navegador.
- **Linux**: plataforma secundaria de escritorio; se publican tar.gz, AppImage y Flatpak
  en GitHub Releases. Sin ubicación nativa (`geolocator` no soporta Linux): se muestra el
  aviso y se usa la búsqueda manual (Buscar).
- **iOS**: aplazado hasta que el usuario decida pagar la cuenta Apple Developer
  (TestFlight). El código no debe depender de APIs solo-Android.
- **Web**: aplazado (posible PWA en GitHub Pages como change futuro).

## 6. Reglas de código

- Dart estricto; errores de análisis = tarea no terminada.
- Commits **convencionales** en español (`feat:`, `fix:`, `docs:`, `infra:`, `refactor:`,
  `test:`, `chore:`; `BREAKING CHANGE` o `!` para major). Commitlint en CI.
- Antes de dar una tarea por terminada: `flutter analyze && flutter test` en verde (y
  `dart format` aplicado).
- **Nunca** se commitean secretos: keystores y tokens viven en GitHub Secrets o fuera del
  repo; existe `.gitignore` para artefactos de build.
- Textos de UI, documentación y mensajes de error para el usuario: español.
- Sin comentarios en el código salvo que se pidan explícitamente.

## 7. Flujo de trabajo OpenSpec

- Toda funcionalidad empieza como change en `openspec/changes/` creado con
  `scripts/new_change.sh <tipo> "<título>" [rama]`. El flujo de `/opsx-propose` lo hace
  él mismo: pregunta tipo, título y rama si faltan (al inicio o tras explorar) y ejecuta
  el script; no hace falta correrlo antes de proponer.
- **Tipos** (clasificación del change): `feature | bug | docs | infra | refactor | test | chore`.
- **Nombre del change**: `<tipo>-<id8>-<slug>`, p. ej. `feature-a3f9c21b-alta-empresas`.
  El `id8` son 8 hex únicos estilo git, generados por `scripts/spec_id.py`.
- **Metadata obligatoria** en `meta.yaml` dentro del change: `tipo`, `id`, `titulo`,
  `autor` (git user), `fecha` (ISO 8601 con zona horaria), `branch`. La valida
  `scripts/check_changes.sh` (se ejecuta en CI).
- **Ramas**: `main` = producción; `dev` = integración y **destino de todos los PR**.
  Cada change declara `branch: dev` (trabajo directo sobre `dev`) o `branch: feature`
  (rama `feature/<tipo>-<id8>-<slug>` con PR a `dev`). El usuario lo define por change;
  el defecto es `dev` y se configura en `scripts/new_change.sh` (`DEFAULT_BRANCH`).
  `main` se actualiza con un PR `dev → main`; **fusionar en `main` es lo que dispara el
  versionado y el release** (§8).
- Archivar un change = commitear TODO (código + specs) en la rama de trabajo antes del
  merge. Verificar con `git status` que no queda nada sin commitear.
- **Sincronizar `todowrite` con el plan**: el panel lateral "Todo" solo refleja la
  herramienta `todowrite` y no se actualiza solo. Al aplicar un change, inicializar
  `todowrite` con las tareas del `tasks.md` y actualizarla tras completar cada tarea
  (mismo estado que el checkbox `- [ ]` → `- [x]`; la tarea en curso como
  `in_progress`). Nunca dejar la lista en el estado de llamadas anteriores.
- Los cambios pequeños se archivan pronto: un change = una capacidad.

## 8. Versionado y releases

- Formato semver `X.Y.Z` (+ número de build `+N` en `pubspec.yaml`). **Automático al
  fusionar en `main`**:
  - `feat` o tipo `feature` → **minor**; `fix`/`bug` → **patch**; `BREAKING CHANGE`/`!` → **major**.
  - `infra`/`docs`/`refactor`/`test`/`chore` → **patch** salvo `BREAKING`.
- Flujo: merge a `main` → `version.yml` analiza commits desde el último tag →
  `node scripts/bump.js <bump>` (sincroniza la versión en `pubspec.yaml` + `package.json`,
  commit `chore(release): vX.Y.Z`, tag `vX.Y.Z`) → `release.yml` construye y publica el
  APK en GitHub Releases (el ZIP de Windows se añade con su change).
- Los assets usan nombres estables (`tolochafuel.apk`, `tolochafuel-windows-x64.zip`,
`tolochafuel-linux-x64.tar.gz`, `tolochafuel-linux-x64.AppImage`,
`tolochafuel-linux-x64.flatpak`)
  para permitir enlaces de descarga directa tipo
  `https://github.com/izquierdojl/tolochafuel/releases/latest/download/tolochafuel.apk`.
- Los skills de OpenSpec se regeneran con `openspec update`: **las reglas de release
  viven aquí, en AGENTS.md**, y se re-aplican a mano si un update las borra de algún skill.

## 9. CI/CD y distribución

- `ci.yml`: `check_changes.sh` + `dart format` + `flutter analyze` + `flutter test` +
  commitlint en PRs. Corre en PRs a `dev`/`main` y en push a `main` (no en push a `dev`).
- `version.yml` (push a `main`) → bump + tag + llama a `release.yml`.
- `release.yml`: job `android` (ubuntu, `flutter build apk --release`) y publicador de
  GitHub Releases. El APK se firma con el keystore de release, materializado desde los
  secretos `ANDROID_KEYSTORE_*` (nunca en el repo; copia de seguridad local en
  `~/keystores/tolochafuel/`), de modo que las actualizaciones se instalan encima sin
  desinstalar; Play Store sigue aplazado como change futuro.
- **Sin Docker**: la app no tiene servidor; los datos se consumen directamente de la API
  pública. Esta decisión es cerrada (revisable solo con decisión explícita del usuario).

## 10. Entorno de desarrollo

- **WSL2 (Ubuntu)**. Código en `~/dev/tolochafuel` (ext4), nunca en `/mnt/c`.
- SDKs en rutas de usuario: Flutter (`~/flutter`), JDK 17 y Android SDK (`~/Android/Sdk`).
- Comandos habituales: `flutter pub get`, `flutter run -d <dispositivo>`,
  `flutter analyze`, `flutter test`, `dart format .`, `bash scripts/check_changes.sh`,
  `npm run check:changes` y `npm run release:patch|minor|major` (manual y excepcional).
- Emulador Android en Windows y `adb` desde WSL (`ADB_SERVER_SOCKET`); dispositivos USB
  con `usbipd-win`.

## 11. Advisories (acuerdos que no se renegocian)

1. Sin backend propio ni Docker mientras la API pública cubra el caso; cualquier caché
   propia sería un change nuevo con decisión del usuario.
2. Atribución CC BY 4.0 en Configuración → Acerca de (decisión del usuario, 2026-10-10;
   sustituye a la regla anterior de mostrarla junto a los precios, con el riesgo de
   licencia asumido por el usuario).
3. Android-first: ninguna funcionalidad puede romper Android; Windows es secundario pero
   debe mantenerse verde en CI.
4. iOS no se paga ni se publica hasta decisión explícita del usuario.
5. Favoritos siempre locales; sin cuentas de usuario ni sincronización.
6. Un change = una capacidad; changes pequeños y archivados pronto.
7. La gobernanza (`scripts/`, `AGENTS.md`, `openspec/config.yaml`) prevalece sobre los
   skills regenerados por `openspec update`; si un update pisa una regla, se re-aplica aquí.
8. Versión `0.x` hasta que el usuario decida `1.0.0`.

## 12. Hoja de ruta inmediata

1. `feature-…-gasolineras-cercanas` — cliente de la API, ubicación con fallback, lista
   ordenada por distancia con precios y selector de carburante, atribución y estados.
2. `feature-…-navegacion-a-gasolinera` — botón «navegar» desde la lista (intents en
   Android; Maps web en escritorio).
3. `feature-…-favoritos` — marcado local persistente y pantalla de favoritos.
4. `infra-…-release-windows` — job de Windows en `release.yml` (ZIP portable) y metadatos
   del ejecutable.
