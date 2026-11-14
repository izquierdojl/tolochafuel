# Design

## Context

- `Ajustes.temaOscuro` (bool, defecto `true`) se guarda con la clave `config.temaOscuro`
  mediante `setBool`; `main.dart` lo traduce a `ThemeMode.dark|light`. `MaterialApp` ya
  recibe `theme: AppTheme.claro` y `darkTheme: AppTheme.oscuro`, así que `ThemeMode.system`
  funciona sin tocar `lib/app/theme`.
- `ConfiguracionRepositorio.guardar` escribe **todas** las claves en cada cambio, de modo
  que cualquier ajuste (p. ej. el radio) fija también la preferencia de tema en disco.
- Ver `proposal.md` para motivación y alcance.

## Goals / Non-Goals

**Goals:**
- Modelar el tema como tres modos y mapearlo directamente a `ThemeMode`.
- Migrar la clave booleana existente sin cambiar lo que ven los usuarios actuales.

**Non-Goals:**
- Detectar el brillo del sistema por código propio: lo resuelve Flutter con
  `ThemeMode.system` (`MediaQuery.platformBrightness`).
- Tocar la paleta, tipografía o `AppTheme`.

## Decisions

1. **Usar `ThemeMode` de Flutter como tipo del ajuste** (`Ajustes.tema`, defecto
   `ThemeMode.system`) en lugar de un enum propio. Es el tipo que consume `MaterialApp`,
   no requiere mapeo en `main.dart` y los tres valores coinciden con la spec. Alternativa
   descartada: enum propio (`ModoTema`) → duplicaría el tipo sin aportar nada.
2. **Clave nueva `config.tema` de tipo texto** (`sistema|claro|oscuro`, mapeadas
   explícitamente en el repositorio para no depender del nombre del enum de Flutter).
   Alternativa descartada: reutilizar `config.temaOscuro` con otro tipo → un `prefs.get`
   no distinguiría el valor antiguo del nuevo y la migración sería ambigua.
3. **Migración en lectura (`cargar`)**: si existe `config.tema` válido, manda; si no, y
   `config.temaOscuro` es bool, `true → oscuro` y `false → claro`; si no hay ninguno (o
   no son válidos), `sistema`. La clave antigua no se borra ni se vuelve a escribir: en
   el siguiente `guardar` se escribe `config.tema` y desde entonces la antigua se ignora.
   Así un downgrade sigue leyendo su bool intacto y no hay paso de migración separado.
4. **API del controlador**: `cambiarTema(ThemeMode modo)` y getter `tema`; se elimina
   `temaOscuro` (sin consumidores salvo `main.dart` y la pantalla). `main.dart` pasa
   `themeMode: config.tema`.
5. **UI**: `SegmentedButton<ThemeMode>` de tres segmentos (Sistema, Claro, Oscuro, con
   iconos) bajo un `ListTile` «Tema» en `configuracion_pantalla.dart`, con selección
   única obligatoria. Alternativa descartada: radios en tres filas → ocupa más espacio
   en una pantalla que ya tiene slider y desplegable. En pantallas estrechas el
   `SegmentedButton` debe caber en una línea con etiquetas cortas; si no cabe, se
   coloca debajo del título en vez de en `trailing`.
6. **Persistencia y fallos**: se reutiliza `_aplicar` del controlador; el fallo al
   guardar mantiene el tema aplicado en la sesión y muestra el aviso en español existente.

## Risks / Trade-offs

- [Usuarios actuales que nunca tocaron el tema pero cambiaron otro ajuste ya tienen
  `config.temaOscuro = true` en disco y se quedarán en «Oscuro», no en «Sistema»] →
  Inevitable sin distinguir «elegido» de «por defecto»; es consistente con «conservar lo
  que ven hoy» y pueden cambiarlo en un toque. Se documenta en la spec.
- [`ThemeMode.system` en escritorio depende de que el SO exponga su brillo a Flutter; en
  algunas configuraciones de Linux/KDE puede resolverse siempre como claro] →
  Comportamiento estándar de Flutter; el usuario puede fijar claro u oscuro. No se
  añade detección propia.
- [Cambiar el defecto de oscuro a sistema altera la primera impresión en móviles con modo
  claro] → Decisión explícita del usuario (alinea la app con el sistema).
- [Cambio de nombre de API (`cambiarTema(oscuro:)` → `cambiarTema(modo)`) rompe tests
  existentes] → Se actualizan en el mismo change (ver tareas).

## Migration Plan

Sin paso explícito: la lectura con fallback a la clave antigua (decisión 3) migra
silenciosamente en el primer arranque tras actualizar. Rollback: volver a la versión
anterior sigue leyendo `config.temaOscuro`, aunque ignora los cambios hechos con la
nueva clave.
