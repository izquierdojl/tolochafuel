# Proposal

Tipo: feature

## Why

Quien sigue una gasolinera favorita tiene que abrir la app y revisar sus precios para
enterarse de un cambio. La fuente se actualiza dos veces al día y no hay backend ni
push; la app puede usar `meta.next_update` para comprobar solo cuando hay datos nuevos y
avisar con los precios publicados.

## What Changes

- Añadir una campana por favorito en Favoritas, como fila con interruptor al pie de la
  tarjeta, con el texto «Avisarme de cambios de precio» y la nota de que los datos se
  actualizan dos veces al día.
- Persistir el estado del aviso en `Favorito` (`avisosPrecio`), de modo que desmarcar
  una gasolinera como favorita borre el aviso por construcción. Volver a marcarla
  empieza con la campana apagada.
- Guardar una base local de precios por estación al activar la campana. La primera
  comprobación no notifica; solo avisa de cambios posteriores.
- Comparar los precios de los carburantes reconocidos (`Carburante`) con la base,
  ignorando AdBlue y productos que no son carburante. No se avisa de la primera base ni
  de la aparición o desaparición de un carburante.
- Publicar una notificación local por estación cuando cambien uno o varios precios,
  agrupada bajo «Avisos de precio» y con una identidad estable por estación. El cuerpo
  muestra los carburantes cambiados, el precio anterior y el nuevo, la fecha de los
  datos y el aviso de `meta.stale` cuando corresponda.
- Abrir un bottom sheet de ficha al tocar la notificación: precios actuales, histórico,
  navegar, favorito y campana. Si la estación ya no es favorita, la ficha se abre
  igualmente, pero sin campana.
- Comprobar al abrir o reanudar la app, sin polling: si `meta.next_update` ya pasó y hay
  campanas activas, se consulta una estación para leer `meta.last_updated`; solo si los
  datos cambiaron se piden las fichas de las favoritas con aviso, con concurrencia
  limitada.
- Pedir el permiso `POST_NOTIFICATIONS` en Android 13 o superior solo al activar la
  primera campana. Si se deniega, la campana no se activa y se explica en español cómo
  concederlo.
- Mantener la atribución completa a Gasolina hoy y al Ministerio (CC BY 4.0) en
  Configuración → Acerca de, como en el resto de la app. El aviso muestra la fecha de
  los datos, no una atribución junto a los precios.
- Actualizar la documentación de uso, arquitectura y datos.

Plataformas afectadas: Android (principal; notificaciones locales y comprobación al
abrir o reanudar), Windows y Linux (comprobación al abrir o reanudar; notificación local
si el entorno lo permite y, si no, aviso dentro de la app). La comprobación con la app
cerrada se aborda en el change de infraestructura posterior.

## Capabilities

### New Capabilities

- `avisos-precio`: activación de avisos por favorito, base de precios, detección de
  cambios, contenido de la notificación, ficha desde el aviso y comprobación al abrir o
  reanudar.

### Modified Capabilities

- `favoritos`: el favorito incorpora el estado de aviso; solo las gasolineras favoritas
  pueden activarlo y al desmarcarlas se borra el aviso y su base.

## Impact

- Código: `lib/features/favoritos/data/favorito.dart` y repositorio, controlador y
  pantalla de Favoritos; nuevo `lib/features/avisos/` con modelo, repositorio,
  comprobador, servicio de notificaciones y ficha; `lib/app` para la inicialización y el
  enrutado del toque; `lib/main.dart` para registrar el controlador.
- Dependencias: `flutter_local_notifications`.
- Android: permiso `POST_NOTIFICATIONS`, icono monocromo de notificación y canal
  «Avisos de precio».
- API: solo `GET /v1/stations/{id}` y los metadatos `meta.last_updated`,
  `meta.next_update` y `meta.stale`; no se inventan endpoints ni campos.
- Tests: modelos y persistencia, diff de precios, formato del aviso, activación y
  desactivación, permiso denegado, desfavoritear, ficha y enrutado del toque.
- Sin cambios en la API, en el backend (no existe) ni en la atribución.

## Fuera de alcance

- La comprobación con la app cerrada y la programación con WorkManager; se hará en
  `infra-56167d5b-comprobacion-de-avisos-en-segundo-plano`.
- Push, FCM, backend propio o cualquier servicio intermedio.
- iOS y web.
- Elegir carburantes por favorito; se vigilan todos los carburantes reconocidos.
- Alertas de disponibilidad, de AdBlue o de productos que no son carburante, y alertas
  basadas en el histórico.
- Silencio nocturno o franjas horarias configurables.
- Notificaciones exactas, alarmas exactas y exención de optimización de batería.
- Sincronización de favoritos o avisos entre dispositivos.
- Una ficha a pantalla completa; se usa un bottom sheet dentro del patrón actual.
