# Design

## Context

Ver `proposal.md`. El proyecto compila con Flutter 3.50.1 / Dart 3.14.0, JDK 21 y el
toolchain Android actual (AGP 9.1.1, Gradle 9.3.1, Kotlin 2.4.0). Flutter 3.50.1 marca
AGP y Kotlin como «soon to be dropped» y recomienda al menos AGP 9.3.1 y Kotlin 2.4.20.
Las dependencias Dart y Node tienen actualizaciones pendientes, algunas de tipo major.

## Goals / Non-Goals

**Goals:**

- Dejar AGP, Gradle y Kotlin en las últimas versiones estables compatibles con Flutter
  3.50.1 y JDK 21.
- Actualizar todas las dependencias Dart directas y resolver las transitivas al máximo
  compatible sin cambiar comportamiento.
- Actualizar commitlint y dejar `npm ci` reproducible.
- Mantener Android, Linux y Windows compilando y los tests en verde.

**Non-Goals:**

- Subir Flutter/Dart (ya están al día).
- Usar versiones preview: AGP 9.6 alpha, Kotlin 2.5 beta/RC o Gradle nightly.
- Cambiar código funcional o el diseño visual.
- Tocar la estrategia de release o los secretos.

## Decisions

### 1. Latest stable, no preview, y una sola fuente de verdad

Se eligen AGP 9.5.2, Gradle 9.9.2 y Kotlin 2.4.21, las últimas estables publicadas.
AGP 9.5 corrige además deprecaciones que aparecían con Gradle 9.8+, así que la pareja
AGP 9.5.2 + Gradle 9.9.2 es coherente. Alternativa considerada: quedarse en AGP 9.3.1
(el mínimo que pide Flutter); se descarta porque el aviso indica que el soporte se
retirará pronto y obligaría a otro change en pocas semanas.

### 2. Actualizar el wrapper con Gradle, no solo la URL

Se cambia `distributionUrl` a `gradle-9.9.2-all.zip`. El wrapper jar de 9.3.1 puede
descargar y ejecutar 9.9.2; si el build detecta problemas del propio wrapper, se
regenera con `./gradlew wrapper --gradle-version 9.9.2`. Alternativa considerada:
instalar Gradle globalmente; se descarta porque rompe la reproducibilidad y el wrapper
es la práctica del proyecto.

### 3. Dart: subida major controlada por el resolutor

`flutter pub upgrade --major-versions` actualiza las restricciones directas a la última
estable y vuelve a resolver; después `flutter pub upgrade` sube las transitivas dentro
de lo que permitan sus padres. Alternativa considerada: fijar versiones a mano; se
descarta porque el resolutor conoce las incompatibilidades y evita combinaciones rotas.
Si alguna actualización major rompe la API usada, se corrige el código de forma mínima
o se revierte solo esa dependencia, dejando constancia en el change.

### 4. Node: commitlint 21 y lock regenerado

Se actualizan `@commitlint/cli` y `@commitlint/config-conventional` a 21.2.4 con
`npm install --save-dev`, se regenera `package-lock.json` y se valida con un commit real
del historial. Node 24.22.1 cumple los requisitos de commitlint 21.

### 5. Verificación completa, incluido build nativo

Además de `npm run verify` y commitlint, se compilan APK release y Linux release. Windows
no se puede compilar en Linux; la CI de PR y el release lo validan. Si AGP 9.5 exige un
`compileSdk` más alto, se sube al mínimo que pida y se anota; si exige migrar al DSL
nuevo o a Kotlin integrado, se evalúa y, si el alcance crece, se para y se consulta.

## Risks / Trade-offs

- **AGP 9.5 exige compileSdk 37 o cambios de DSL** → se ajusta lo mínimo; si obliga a
  reescribir la configuración Android, se para y se propone un change aparte.
- **Kotlin 2.4.21 incompatible con el plugin de Flutter 3.50.1** → el build lo detecta;
  se baja a la última versión que funcione y se documenta.
- **`cupertino_icons` 2.0.0 u otra major rompe imports** → `flutter analyze` y los tests
  lo detectan; se corrige o se revierte esa dependencia.
- **Gradle 9.9.2 descarga una distribución grande en CI** → la caché de Gradle de las
  acciones de Flutter/Android la reutiliza; el timeout de CI (15 min) tiene margen.
- **Commitlint 21 cambia reglas** → se valida con commits reales y con el job de CI.
- **Rollback**: revertir el commit del change; las versiones anteriores siguen fijadas
  en el historial y los artefactos publicados no se tocan.

## Migration Plan

1. Actualizar AGP, Gradle y Kotlin.
2. Actualizar dependencias Dart y Node; regenerar locks.
3. Ejecutar verificación completa, commitlint y builds release de Android y Linux.
4. Archivar el change, commitear en `dev` y hacer push.
5. Vigilar la CI; al fusionar en `main`, el flujo aplica el patch y publica artefactos.

## Open Questions

_(ninguna)_
