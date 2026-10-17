# Proposal

## Why

Los rótulos que llegan de la API son a menudo genéricos o se repiten: varias estaciones
«REPSOL» en la misma zona que solo se distinguen por la dirección, o estaciones sin
rótulo («Sin rótulo»). El usuario quiere ponerles un nombre propio —«la de la rotonda»,
«la del polígono»— que sobreviva a las nuevas consultas y a los reinicios, sin depender
de la API ni de marcar la estación como favorita. La persistencia local ya está probada
con favoritos y este cambio no toca la API.

## What Changes

- Menú de acciones (⋮) en la tarjeta de gasolinera con «Poner alias…» o «Editar alias…»,
  disponible en las cuatro listas (Cercanas, Más económicas, Buscar y Favoritos) y sin
  necesidad de marcar la estación como favorita.
- Diálogo para poner, cambiar o quitar el alias: se recortan los espacios, el texto vacío
  equivale a quitar, máximo 40 caracteres y sin comprobación de duplicados.
- El alias pasa a ser el nombre principal de la estación donde se muestre (título de la
  tarjeta y encabezado del histórico de precios) y el rótulo original de la API queda en
  la línea secundaria junto a la dirección. Sin alias, la presentación es la de hoy.
- Persistencia local (`shared_preferences`, clave nueva con el alias por id de estación):
  el alias se aplica en las siguientes consultas y sobrevive a los reinicios; se mantiene
  aunque la API renombre la estación y desmarcar una favorita no lo borra.
- Casos borde: una estación sin rótulo con alias deja de mostrar «Sin rótulo»; si el
  alias coincide con el rótulo no se duplica; si falla el guardado se muestra un aviso en
  español y la sesión continúa.
- Nada de red ni de caché: el alias se resuelve en la interfaz por `id`, así que las
  consultas a api.preciosgasolina.es y sus límites no cambian.

## Capabilities

### New Capabilities

- `alias-gasolineras`: nombres locales y persistentes para las estaciones, independientes
  de favoritos y aplicados a la presentación del nombre en toda la app.

### Modified Capabilities

_(ninguna)_

## Impact

- Código nuevo: `lib/features/alias/{data,ui}` (repositorio, controlador y diálogo).
- `lib/main.dart`: carga de alias al arranque junto a favoritos y configuración
  (provider).
- `lib/features/cercanas/ui/widgets/tarjeta_gasolinera.dart`: menú de acciones y
  resolución del nombre y del subtítulo.
- `lib/features/cercanas/ui/widgets/detalle_historico.dart`: encabezado con el alias
  cuando exista.
- Tests: repositorio y controlador de alias, diálogo y tarjeta (widget tests).
- Sin dependencias nuevas (`shared_preferences` ya está), sin cambios de API ni de
  modelo (`Gasolinera` y `Favorito` no cambian). Mismo comportamiento en Android, Windows
  y Linux.

## Fuera de alcance

- Sincronización entre dispositivos o cuentas de usuario: los alias son locales, como los
  favoritos.
- Renombrar la estación en la API o para otros usuarios.
- Buscar u ordenar por alias; el orden por distancia o precio no cambia.
- Usar el alias en la navegación externa o en textos para compartir.
- Exportar/importar alias y notificaciones.
- Una pantalla propia de gestión: la puesta y edición del alias viven en la tarjeta.
