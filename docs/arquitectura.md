# Arquitectura

> [← Volver al README](../README.md)

## Vista general

TolochaFuel es una aplicación **Flutter** para Android, Windows y Linux. No tiene backend
propio: cada dispositivo consulta directamente la API pública de precios, guarda sus
favoritos y sus ajustes en local y funciona sin cuentas de usuario.

El código se organiza en tres capas:

```
lib/
├── app/        Arranque, tema, shell y menú de navegación
├── core/       API, modelos, servicios de plataforma y utilidades
└── features/   Una carpeta por capacidad: data/ (repositorio) y ui/ (pantallas)
```

## Estructura

### `lib/app`

- `main.dart`: inicializa las notificaciones locales, carga favoritos, ajustes y alias
  antes de arrancar; registra los controladores con `provider` y monta `MaterialApp` con
  el tema claro y oscuro.
- `shell/`: `ShellPantalla`, el menú lateral (`NavigationDrawer`) y las secciones
  Cercanas, Favoritas, Buscar, Más económicas y Configuración. También comprueba los
  avisos al reanudar y abre la ficha cuando se toca una notificación.
- `theme/`: paleta pine/ochre/moss, tipografía Inter y `ColoresTendencia`. Los widgets
  no usan colores literales: todo sale de `Theme`.

### `lib/core`

- `api/`: `ApiClient` (HTTP, tiempo de espera, errores en español) y
  `PreciosGasolinaApi` (endpoints y parseo). Es el **único** punto que habla con la API.
- `models/`: `Gasolinera`, `ProductoPrecio`, `Lugar`, `MetaDatos`, `HistoricoEstacion`,
  `DetalleEstacion` y los enums de carburante y criterio. Son inmutables y toleran
  formatos laxos de la API (números como texto, coma decimal).
- `services/`: `Ubicacion` (geolocator) y `Navegacion` (url_launcher).
- `utilidades/`: distancias, formato de precios y frescura, y parseo defensivo.

### `lib/features`

| Feature | Responsabilidad |
| --- | --- |
| `cercanas/data` | Repositorio de listados, fichas, histórico y búsqueda; caché en memoria |
| `cercanas/ui` | Cercanas, Buscar, Más económicas, histórico y widgets de tarjeta y estados |
| `favoritos` | Persistencia local de favoritos y su orden; pantalla Favoritas |
| `avisos` | Campana por favorito, base de precios, comprobador, notificaciones locales y ficha desde el aviso |
| `configuracion` | Tema, radio, pantalla inicial, criterio y «Acerca de» |
| `alias` | Nombres locales por estación y su diálogo |

## Flujo de una consulta

```
Ubicación o búsqueda
        ↓
Controlador (ChangeNotifier)
        ↓
Repositorio de la feature  ← caché en memoria
        ↓
PreciosGasolinaApi
        ↓
ApiClient (HTTP)
        ↓
api.preciosgasolina.es
```

Las pantallas no contienen lógica de negocio: leen el estado del controlador, llaman a
sus métodos y pintan. Los controladores gestionan los estados `inicial`, `cargando`,
`datos`, `vacio` y `error`, y exponen `reintentar` para que la UI pueda recuperarse.

## Estado y navegación

`provider` registra los controladores en `main.dart` y los comparte con el árbol de
widgets. `ShellPantalla` mantiene la sección activa y conserva las secciones visitadas en
un `IndexedStack`, de modo que volver a una pestaña no recarga los datos. La pantalla
inicial se puede cambiar en Configuración.

## Datos, caché y frescura

- `CercanasRepositorio` cachea listados y fichas en memoria por clave (coordenadas,
  radio, criterio). La caché caduca cuando llega `meta.next_update`; si la API no da
  fecha, se mantiene hasta reiniciar o hasta que el usuario reintente.
- `HistorialController` aplica la misma caducidad a las series históricas.
- Las fichas se piden en lotes de seis para no disparar el límite de peticiones.
- No hay *polling*: la fuente se actualiza dos veces al día y la app muestra un pie de
  frescura con la última actualización y aviso si `stale` es verdadero. Más detalle en
  [datos](datos.md).

## Persistencia local

`shared_preferences` guarda, solo en el dispositivo:

- los favoritos, su orden y el estado de la campana (`favoritos`),
- la base de precios de los avisos y su programación (`avisos_precios_v1`),
- los ajustes de tema, radio, pantalla inicial y criterio (`config.*`),
- los alias de estación (`alias_estaciones`).

No hay cuentas ni sincronización. Si el almacenamiento falla, la app sigue funcionando con
valores por defecto y avisa en español.

## Avisos de precio

`ComprobadorAvisos` lee las favoritas con campana, corta con una sola petición cuando
`meta.last_updated` no cambió y, solo si cambió, consulta las fichas con concurrencia
limitada. La base se guarda en milésimas enteras y la comprobación vuelve a leer el
favorito y la campana antes de publicar. `NotificacionesServicio` envuelve
`flutter_local_notifications` y permite usar un doble en los tests. El toque en el aviso
se guarda como una estación pendiente y `ShellPantalla` abre `FichaEstacionSheet`.

La comprobación actual es al abrir o reanudar la app, alineada con `meta.next_update`.
El trabajo con la app cerrada mediante WorkManager se añadirá en un change posterior.

## Servicios de plataforma

- **Ubicación**: `geolocator` en Android, con permisos solicitados al usarlos. En Windows
  y Linux no hay ubicación nativa: la app muestra el aviso y usa la búsqueda manual.
- **Navegación externa**: `url_launcher` abre la app de mapas en Android y Google Maps en
  el navegador en escritorio.
- **Notificaciones**: `flutter_local_notifications` en Android, Windows y Linux; el canal
  se llama «Avisos de precio». En Android se pide `POST_NOTIFICATIONS` al activar la
  primera campana.
- **Tema**: claro u oscuro, siguiendo el sistema por defecto; el cambio se aplica al
  instante.

## Pruebas

`test/` replica la estructura de `lib/`:

- Tests unitarios de modelos, parseo, API, repositorios y controladores.
- Widget tests de las pantallas y estados clave: carga, error, vacío, datos, tema,
  favoritos, alias, histórico y «Acerca de».

Los tests no dependen de la red: usan clientes y repositorios falsos. `npm run verify`
ejecuta formato, análisis, tests y las comprobaciones de OpenSpec.
