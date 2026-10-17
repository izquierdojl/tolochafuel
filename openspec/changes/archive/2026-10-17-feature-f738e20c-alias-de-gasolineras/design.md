# Design

## Context

Hoy `TarjetaGasolinera` es la única tarjeta y la comparten las cuatro listas (Cercanas,
Más económicas, Buscar y Favoritos): muestra `gasolinera.nombre` (el rótulo de la API, con
«Sin rótulo» como fallback) y un subtítulo «dirección · municipio»; su fila ya lleva
distancia, chapa 24h, navegar y favorito. `DetalleHistorico`, la hoja inferior de
histórico, repite el nombre en su encabezado. Ver `proposal.md` - Why.

Precedentes reutilizables: `FavoritosRepositorio`/`FavoritosController`
(`shared_preferences` con JSON, carga al arranque en `main()` con `Future.wait`, aviso en
español si falla el guardado) y el patrón «la tarjeta llama y muestra el resultado» del
botón navegar. No hay pantalla de detalle de estación ni usos previos de
`PopupMenuButton` o diálogos.

## Goals / Non-Goals

**Goals:**

- Alias por id de estación, independiente de favoritos, cargado al arranque y resuelto en
  el render (sin red ni caché).
- Gestión desde el menú de acciones de la tarjeta con diálogo (poner, cambiar, quitar) en
  las cuatro listas.
- Persistencia tolerante y aviso en español si falla el guardado.

**Non-Goals:**

- Cambios en `Gasolinera`, `Favorito`, la API o la caché.
- Buscar u ordenar por alias; alias en navegación externa o textos compartidos.
- Pantalla propia de gestión de alias o sincronización.

## Decisions

- **Carpeta `lib/features/alias/`**: `data/alias_repositorio.dart` (clave
  `alias_estaciones` en `shared_preferences`, un objeto JSON `{id: alias}`) y
  `ui/alias_controller.dart` (mapa en memoria `int -> String`, `aliasDe(id)`, `guardar`,
  `quitar`). El controlador debe estar disponible en las cuatro listas, así que se
  registra en `main()` y se carga antes de `runApp` junto a favoritos y configuración
  (sin parpadeo hacia el rótulo). Alternativas descartadas: campo `alias` en `Favorito`
  (ata el nombre a marcar como favorita y se pierde al desmarcar; decisión del usuario) y
  guardarlo en los ajustes de `ConfiguracionController` (es un dato por estación, no un
  ajuste global).

- **Resolución del nombre en una función pura**: `lib/features/alias/ui/` expone una
  función (p. ej. `nombreMostrado`) que, con la gasolinera y el alias, devuelve el título
  y las partes del subtítulo: título = alias o rótulo de la API; subtítulo = [rótulo si
  hay alias y no coincide y no es «Sin rótulo», dirección, municipio]. La usan la tarjeta
  y el encabezado del histórico; sus reglas (duplicado, «Sin rótulo») quedan cubiertas
  por tests unitarios. Alternativa descartada: repetir la lógica en cada widget.

- **Entrada por menú (⋮)**: `PopupMenuButton` compacto al final de la fila de la tarjeta,
  con una entrada «Poner alias…» o «Editar alias…» según el estado, que abre el diálogo.
  Alternativas descartadas: icono de lápiz permanente (tres iconos seguidos en una fila ya
  cargada y significado ambiguo) y pulsación larga (sin pista visual). El menú deja sitio
  a futuras acciones de la tarjeta sin tocar la fila otra vez; navegar y favorito no
  cambian.

- **Diálogo `DialogoAlias`**: `AlertDialog` con `TextField` precargado con el alias
  actual (máximo 40 caracteres), ayuda «Sustituye a: <rótulo>» y aviso «Solo se guarda en
  este dispositivo»; acciones Guardar, Cancelar y Quitar alias (esta última solo si hay
  alias). El diálogo solo recoge y devuelve el texto; el controlador recorta, interpreta
  el vacío como quitar y persiste. Sin comprobación de duplicados (decisión del usuario).

- **Persistencia tolerante**: `cargar()` devuelve el mapa ignorando claves o valores
  inválidos, sin aviso; `guardar`/`quitar` actualizan memoria y notifican primero y luego
  escriben, devolviendo `false` si la escritura falla; la tarjeta muestra entonces un
  aviso en español (patrón del fallo de navegación) y el alias queda aplicado en la
  sesión.

- **Histórico**: el encabezado de `DetalleHistorico` usa el alias cuando existe (mismo
  contexto de providers que ya usa para `HistorialController`).

- **Plataformas**: comportamiento idéntico en Android, Windows y Linux
  (`shared_preferences` sin ramas por plataforma).

## Risks / Trade-offs

- [Una fila de tarjeta con más controles en pantallas estrechas] → iconos compactos y
  título con elipsis ya existentes; la acción nueva no añade más controles que el menú.
- [Alias huérfanos de estaciones que no vuelves a ver] → inofensivos (texto por id) y sin
  pantalla de limpieza; el coste en `shared_preferences` es mínimo.
- [El alias oculta el rótulo real] → el rótulo original queda en la línea secundaria y el
  diálogo lo muestra como referencia («Sustituye a: …»); quitar el alias restaura el
  nombre de la API.
- [Fallo de guardado percibido como dato perdido] → aviso inmediato en español y alias
  aplicado en la sesión; al reiniciar vuelve el estado persistido.
- [Datos corruptos o de versiones futuras] → lectura tolerante que ignora lo inválido; la
  app arranca sin alias y el resto de secciones funciona.
