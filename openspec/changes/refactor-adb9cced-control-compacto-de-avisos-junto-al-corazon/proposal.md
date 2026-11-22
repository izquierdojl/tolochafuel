# Proposal

Tipo: refactor

## Why

El control de avisos actual es una fila `SwitchListTile` a todo el ancho con título y
subtítulo; ocupa demasiado alto y rompe el ritmo visual de la tarjeta de Favoritos. El
mensaje de activación se muestra en un SnackBar, que pasa desapercibido. Se quiere un
control compacto junto al corazón y un diálogo emergente al activar.

## What Changes

- Mover el control de avisos a la cabecera de la tarjeta de Favoritos, como un icono de
  campana junto al corazón (relleno si está activo y contorneado si está apagado);
  eliminar la fila inferior.
- Mostrar el resultado de la activación en un diálogo emergente (éxito, base pendiente,
  permiso denegado o notificaciones desactivadas), con una acción para cerrarlo; no
  mostrar diálogo al desactivar.
- Mantener el control solo en Favoritos y solo para favoritas; sin cambios en el estado,
  la persistencia, la comprobación ni el contenido de las notificaciones.
- Actualizar tests y documentación.

Plataformas: Android, Windows y Linux; solo cambia la interfaz local.

## Capabilities

### New Capabilities

_(ninguna)_

### Modified Capabilities

- `favoritos`: el control de avisos pasa a un icono de campana junto al corazón y muestra
  un diálogo al activar.
- `avisos-precio`: se añade el diálogo emergente con el resultado de la activación.

## Impact

- `lib/features/cercanas/ui/widgets/tarjeta_gasolinera.dart`: parámetro `mostrarAviso` e
  icono de campana en la cabecera.
- `lib/features/favoritos/ui/favoritos_pantalla.dart`: quitar `_FilaAviso` y activar
  `mostrarAviso` en la tarjeta de Favoritos.
- `lib/features/avisos/ui/mensajes_avisos.dart`: sustituir el SnackBar por un diálogo.
- Tests de Favoritos y de la ficha; documentación de uso.
- Sin cambios en la API, dependencias ni migración de datos.

## Fuera de alcance

- Cambiar el contenido, la agrupación o la programación de las notificaciones.
- Mostrar el control en Cercanas, Buscar o Más económicas.
- Cambiar la campana de la ficha.
- Añadir selección de carburantes o silencio nocturno.
