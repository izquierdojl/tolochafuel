# Proposal

## Why

Hoy Configuración solo ofrece un switch «Tema oscuro»: quien quiere que la app cambie
sola entre claro y oscuro según el sistema (modo día/noche del móvil o del escritorio)
tiene que cambiarlo a mano cada vez. Flutter ya soporta `ThemeMode.system`, y la app ya
declara `theme` y `darkTheme`, así que falta poder elegirlo.

## What Changes

- El switch «Tema oscuro» se sustituye por un selector de tres opciones —**Sistema**,
  **Claro** y **Oscuro**— en Configuración.
- Nueva opción «Sistema»: la app sigue el brillo del sistema operativo y reacciona al
  instante si este cambia mientras la app está abierta.
- **Cambia el valor por defecto**: una instalación nueva arranca en «Sistema» (antes,
  oscuro).
- Migración sin pérdida: quien ya eligió claro u oscuro (clave local `config.temaOscuro`
  de tipo booleano) conserva su elección; solo quien nunca la cambió pasa a «Sistema».
- La elección se persiste con una clave nueva de tipo texto (`sistema|claro|oscuro`); si
  el valor guardado es inválido se usa el valor por defecto sin avisar de error.
- Sin cambios en la paleta ni en `AppTheme`: `claro` y `oscuro` ya existen.

## Capabilities

### New Capabilities

_(ninguna)_

### Modified Capabilities

- `configuracion`: el requisito «Tema claro y oscuro» pasa a «Tema de la app» con tres
  modos (sistema, claro, oscuro), «sistema» como valor por defecto y migración de la
  preferencia booleana anterior.

## Impact

- `lib/features/configuracion/data/configuracion_repositorio.dart`: `Ajustes.temaOscuro`
  (bool) pasa a un modo de tema de tres valores; lectura con migración de la clave
  antigua y escritura de la nueva.
- `lib/features/configuracion/ui/configuracion_controller.dart`: `cambiarTema` recibe el
  modo en vez del bool.
- `lib/features/configuracion/ui/configuracion_pantalla.dart`: selector de tres opciones
  en lugar del switch.
- `lib/main.dart`: `themeMode` se alimenta del modo guardado.
- Tests: repositorio (valor por defecto, migración, valor inválido), controlador,
  `tema_inicial_test.dart`, `cercanas_radio_test.dart`, `configuracion_controller_test.dart`
  y `shell_pantalla_test.dart` (texto del control), más un widget test del selector.
- Sin dependencias nuevas ni cambios de API. Plataformas: todas; en escritorio (Windows y
  Linux) «Sistema» depende de que el SO exponga su brillo a Flutter, y si no, se
  comporta como claro (comportamiento estándar de `ThemeMode.system`).

## Fuera de alcance

- Programar el tema por horario o por puesta de sol.
- Temas adicionales, paleta personalizable o color dinámico (Material You).
- Cambiar los colores de `AppTheme.claro` / `AppTheme.oscuro`.
- Sincronizar el ajuste entre dispositivos (las preferencias son locales).
