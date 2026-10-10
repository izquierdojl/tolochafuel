# Proposal

## Why

El APK de release publicado en GitHub Releases no puede consultar la API: la app se
comporta como si no tuviera conexión y no lista ninguna gasolinera, mientras que en web y
en depuración sí funciona. La causa es que `android.permission.INTERNET` solo aparece en
los manifiestos de `android/app/src/debug` y `android/app/src/profile` (los inyecta Flutter
para hot reload); el manifiesto principal (`src/main`) que usa la compilación de release no
lo declara. Sin ese permiso, Android bloquea todas las conexiones del APK firmado, dejando
inservible el caso de uso principal (Android).

## What Changes

- Declarar `android.permission.INTERNET` en `android/app/src/main/AndroidManifest.xml`.
- Verificar en un APK de release que la app carga las gasolineras cercanas con red
  disponible y que, sin red, muestra el estado de error existente con reintento.
- Dejar constancia de por qué el permiso vive en el manifiesto principal, para que una
  limpieza futura no lo elimine de nuevo.

No cambia ningún comportamiento especificado: la capacidad `gasolineras-cercanas` ya exige
cargar los datos de la API; este change repara la configuración de empaquetado que lo
impedía en Android.

## Capabilities

### New Capabilities

_(ninguna: es una corrección de configuración de build, no una capacidad nueva)_

### Modified Capabilities

_(ninguna: el comportamiento especificado no cambia; solo se corrige el manifiesto que
impedía cumplirlo en el APK de release. El change declara `skip_specs: true`)_

## Impact

- `android/app/src/main/AndroidManifest.xml` (permiso `INTERNET` nuevo).
- Sin cambios en Dart, en el cliente API ni en la API pública.
- Plataformas afectadas: **Android** (principal). Windows y web no usan el manifiesto
  Android y no se tocan.
- Sin dependencias nuevas.

## Fuera de alcance

- Otros permisos (notificaciones, ubicación en segundo plano): solo se añade `INTERNET`.
- Cambios en el manejo de errores de red del cliente API (ya existe y es correcto).
- Firma de producción del APK (sigue aplazada según AGENTS.md).
- Publicación en Play Store.
