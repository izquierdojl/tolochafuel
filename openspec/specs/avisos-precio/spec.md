# avisos-precio Specification

## Purpose
Avisa al usuario de los cambios de precio de sus gasolineras favoritas mediante
notificaciones locales y permite abrir la ficha de la estación desde el aviso.

## Requirements

### Requirement: Activación de avisos y permiso

La app SHALL permitir activar los avisos solo para gasolineras favoritas. En Android 13
o superior SHALL solicitar el permiso de notificaciones al activar la primera campana;
si se deniega, el aviso SHALL quedar apagado y la app SHALL explicar en español cómo
concederlo. En el resto de plataformas SHALL activar el aviso sin solicitar permiso.

#### Scenario: Primera activación con permiso concedido

- **WHEN** el usuario activa la campana en Android 13 o superior y concede el permiso
- **THEN** el aviso queda activado y la app guarda la base de precios

#### Scenario: Permiso denegado

- **WHEN** el usuario activa la campana en Android 13 o superior y deniega el permiso
- **THEN** la campana vuelve a apagado y se muestra una explicación en español para
  concederlo desde los ajustes del sistema

#### Scenario: Notificaciones desactivadas en el sistema

- **WHEN** el usuario activa la campana y las notificaciones de la app están desactivadas
  en el sistema
- **THEN** la app avisa de que no podrá mostrar avisos y no promete que llegarán

#### Scenario: Activación en escritorio

- **WHEN** el usuario activa la campana en Windows o Linux
- **THEN** el aviso queda activado sin solicitar permiso de notificaciones y se indica
  que la comprobación se hace al abrir o reanudar la app

#### Scenario: Intento sobre una estación no favorita

- **WHEN** una estación no es favorita
- **THEN** la app no ofrece ni activa avisos para ella

### Requirement: Base de precios al activar

Al activar el aviso, la app SHALL consultar la ficha de la estación
(`GET /v1/stations/{id}`) y guardar localmente los precios de los carburantes
reconocidos. Esa primera base SHALL ser la referencia y no SHALL generar ninguna
notificación. Si la consulta falla, el aviso SHALL permanecer activo y la siguiente
comprobación correcta SHALL establecer la base sin notificar.

#### Scenario: Base creada sin aviso

- **WHEN** el usuario activa la campana y la ficha devuelve precios
- **THEN** se guarda la base actual y no se publica ninguna notificación por esos precios

#### Scenario: Fallo al crear la base

- **WHEN** el usuario activa la campana y la consulta de la ficha falla
- **THEN** el aviso permanece activo y se informa de que se comprobará cuando haya
  conexión, sin notificar todavía

#### Scenario: Base establecida en una comprobación posterior

- **WHEN** un aviso activo no tiene base y una comprobación posterior obtiene precios
- **THEN** se guarda esa base y no se notifica el cambio respecto a la nada

#### Scenario: Estación sin precios

- **WHEN** la ficha no devuelve ningún carburante con precio
- **THEN** el aviso permanece activo y no se notifica hasta que haya precios que comparar

### Requirement: Detección de cambios de precio

En cada comprobación, la app SHALL comparar los precios actuales de los carburantes
reconocidos con la base guardada y SHALL notificar solo los carburantes cuyo precio haya
cambiado. Las subidas y las bajadas SHALL avisarse por igual. La aparición o
desaparición de un carburante, y los cambios de AdBlue o de productos que no son
carburante, no SHALL generar aviso.

#### Scenario: Precio que baja

- **WHEN** un carburante de la base aparece en la ficha con un precio menor
- **THEN** el aviso incluye ese carburante con el precio anterior y el nuevo

#### Scenario: Precio que sube

- **WHEN** un carburante de la base aparece en la ficha con un precio mayor
- **THEN** el aviso incluye ese carburante con el precio anterior y el nuevo

#### Scenario: Precio sin cambios

- **WHEN** todos los carburantes de la base conservan su precio
- **THEN** no se publica ninguna notificación

#### Scenario: Carburante nuevo

- **WHEN** la ficha incorpora un carburante que no estaba en la base
- **THEN** se añade a la base sin generar aviso

#### Scenario: Carburante desaparecido

- **WHEN** la ficha deja de devolver un carburante que estaba en la base
- **THEN** se elimina de la base sin generar aviso

#### Scenario: Cambio de AdBlue

- **WHEN** solo cambia el precio de AdBlue o de un producto que no es carburante
- **THEN** no se publica ninguna notificación

#### Scenario: Ficha no disponible

- **WHEN** la consulta de la ficha falla durante una comprobación
- **THEN** no se notifica ese intento, se conserva la base anterior y se reintenta en la
  siguiente comprobación

### Requirement: Contenido de la notificación

La notificación SHALL usar el alias o el nombre de la estación y SHALL mostrar los
carburantes cambiados con el precio anterior y el nuevo. SHALL incluir la fecha de los
datos o el texto genérico de actualización dos veces al día, y SHALL añadir el aviso de
datos de la actualización anterior cuando `meta.stale` sea verdadero. La atribución
completa a Gasolina hoy y al Ministerio (CC BY 4.0) vive en Configuración → Acerca de.

#### Scenario: Un carburante cambia

- **WHEN** cambia el precio de un solo carburante
- **THEN** la notificación muestra su nombre, el precio anterior y el nuevo

#### Scenario: Varios carburantes cambian

- **WHEN** cambian varios carburantes de la misma estación
- **THEN** una sola notificación muestra todos los cambios

#### Scenario: Alias de la estación

- **WHEN** la estación tiene alias guardado
- **THEN** la notificación usa el alias en lugar del nombre de la API

#### Scenario: Fecha de los datos disponible

- **WHEN** la respuesta incluye `meta.last_updated`
- **THEN** la notificación muestra la fecha y hora de esa actualización

#### Scenario: Fecha de los datos no disponible

- **WHEN** la respuesta no incluye `meta.last_updated`
- **THEN** la notificación usa el texto genérico de actualización dos veces al día

#### Scenario: Datos en modo stale

- **WHEN** la respuesta incluye `meta.stale = true`
- **THEN** la notificación añade el aviso de que pueden ser datos de la actualización
  anterior

### Requirement: Una notificación por estación

La app SHALL publicar como máximo una notificación por estación y actualización, con una
identidad estable por estación, y SHALL agruparlas bajo «Avisos de precio». Si cambian
varios carburantes de la misma estación, SHALL enviarse una sola notificación con todos
los cambios. Una actualización posterior de la misma estación SHALL reemplazar el aviso
anterior.

#### Scenario: Varios carburantes de una estación

- **WHEN** cambian dos o más carburantes de la misma estación
- **THEN** se publica una sola notificación con todos los cambios

#### Scenario: Varias estaciones

- **WHEN** cambian precios de varias favoritas en la misma comprobación
- **THEN** se publica una notificación por estación, agrupadas bajo «Avisos de precio»

#### Scenario: Actualización posterior

- **WHEN** una estación ya notificada vuelve a cambiar en una actualización posterior
- **THEN** la nueva notificación reemplaza a la anterior de esa estación

### Requirement: Apertura de la ficha desde el aviso

Al tocar una notificación, la app SHALL abrir la ficha de la estación en un bottom sheet
con los precios actuales, el histórico, navegar, favorito y la campana. Si la estación ya
no es favorita, la ficha SHALL abrirse sin campana. Si la consulta falla, SHALL mostrar un
error en español con opción de reintentar. La atribución completa a Gasolina hoy y al
Ministerio (CC BY 4.0) vive en Configuración → Acerca de.

#### Scenario: Toque con la app abierta

- **WHEN** el usuario toca la notificación con la app en primer plano
- **THEN** se abre la ficha de la estación con sus precios actuales

#### Scenario: Toque con la app cerrada

- **WHEN** el usuario toca una notificación que lanzó la app desde cero
- **THEN** la app termina de arrancar y abre la ficha de la estación

#### Scenario: Estación que ya no es favorita

- **WHEN** el usuario toca una notificación de una estación que ya no está en Favoritos
- **THEN** la ficha se abre igualmente, sin campana

#### Scenario: Error al cargar la ficha

- **WHEN** la consulta de la ficha falla al abrirla desde la notificación
- **THEN** se muestra un mensaje en español con opción de reintentar

#### Scenario: Estación inexistente

- **WHEN** la estación de la notificación ya no existe en la API
- **THEN** se muestra un mensaje en español sin bloquear el resto de la app

### Requirement: Comprobación al abrir o reanudar

Sin polling, al abrir o reanudar la app con avisos activos, la app SHALL comprobar si
`meta.next_update` ya pasó; SHALL leer `meta.last_updated` con una sola ficha y solo
SHALL consultar el resto de favoritas con aviso si los datos cambiaron. Las consultas
SHALL limitar la concurrencia y respetar los límites de la API. Si no hay avisos
activos, no SHALL hacer peticiones.

#### Scenario: Apertura después de la actualización

- **WHEN** el usuario abre la app después de `meta.next_update` y hay avisos activos
- **THEN** la app comprueba los precios y publica los avisos de los cambios

#### Scenario: Apertura antes de la actualización

- **WHEN** el usuario abre la app antes de `meta.next_update`
- **THEN** no se consultan fichas para avisos

#### Scenario: Sin datos nuevos

- **WHEN** `meta.next_update` ya pasó pero `meta.last_updated` no cambió
- **THEN** la app corta tras la primera ficha y no publica avisos

#### Scenario: Sin avisos activos

- **WHEN** ninguna favorita tiene la campana activada
- **THEN** la app no hace peticiones para avisos

#### Scenario: Muchas favoritas con aviso

- **WHEN** hay muchas favoritas con aviso y los datos cambiaron
- **THEN** las fichas se consultan con concurrencia limitada, respetando los límites de
  la API

#### Scenario: Error en una ficha

- **WHEN** falla la consulta de una favorita y las demás responden
- **THEN** se avisa de las que cambiaron y la fallida se reintenta en la siguiente
  comprobación

#### Scenario: Reanudar la app

- **WHEN** el usuario vuelve a la app después de haberla dejado en segundo plano
- **THEN** se aplica la misma comprobación que al abrir, sin polling mientras permanece
  abierta

### Requirement: Persistencia y coherencia con favoritos

El estado de la campana y la base de precios SHALL guardarse localmente y conservarse
entre ejecuciones. La app SHALL releer el favorito y la campana justo antes de publicar
una notificación; si la estación dejó de ser favorita o el aviso se apagó, no SHALL
notificar. Un fallo de lectura o escritura no SHALL bloquear la app y SHALL mostrar un
aviso en español cuando afecte a una acción del usuario.

#### Scenario: Reapertura de la app

- **WHEN** el usuario cierra y vuelve a abrir la app
- **THEN** las campanas y las bases de precios se conservan

#### Scenario: Desmarcar el favorito durante la comprobación

- **WHEN** la estación deja de ser favorita mientras se comprueban sus precios
- **THEN** no se publica ninguna notificación para ella

#### Scenario: Apagar la campana durante la comprobación

- **WHEN** el usuario apaga la campana mientras se comprueban los precios
- **THEN** no se publica ninguna notificación para esa estación

#### Scenario: Datos locales corruptos

- **WHEN** la base de precios o el estado de la campana no se pueden leer
- **THEN** la app sigue funcionando, descarta solo esos datos y avisa en español

#### Scenario: Fallo al guardar

- **WHEN** falla la escritura del estado de la campana o de la base
- **THEN** el cambio se mantiene durante la sesión y se muestra un aviso en español

### Requirement: Comportamiento por plataforma

En Android, los avisos SHALL usar notificaciones locales del sistema y la comprobación
SHALL funcionar al abrir o reanudar la app; la comprobación con la app cerrada se añade
en un change posterior. En Windows y Linux, la comprobación SHALL ser al abrir o
reanudar y el aviso SHALL mostrarse mediante una notificación local si el entorno lo
permite; si no, SHALL mostrarse un aviso dentro de la app. La app no SHALL prometer
avisos con la app cerrada en escritorio.

#### Scenario: Android

- **WHEN** el usuario activa una campana en Android y los datos cambian
- **THEN** el aviso llega como notificación del sistema al abrir o reanudar la app

#### Scenario: Escritorio con notificaciones disponibles

- **WHEN** el usuario activa una campana en Windows o Linux y el entorno admite
  notificaciones
- **THEN** el aviso se muestra como notificación local al abrir o reanudar la app

#### Scenario: Escritorio sin notificaciones disponibles

- **WHEN** el entorno de escritorio no admite notificaciones locales
- **THEN** el aviso se muestra dentro de la app, sin bloquear el uso

#### Scenario: App cerrada en escritorio

- **WHEN** la app está cerrada en Windows o Linux
- **THEN** no se promete ni se intenta una comprobación en segundo plano

### Requirement: Privacidad y datos

Los avisos, la campana y la base de precios SHALL ser locales al dispositivo; la app no
SHALL crear cuentas, enviar datos a un backend propio ni sincronizar avisos entre
dispositivos. Las únicas peticiones SHALL ser a la API pública
`api.preciosgasolina.es` y respetarán sus límites y licencia.

#### Scenario: Sin cuentas ni backend

- **WHEN** el usuario activa y usa los avisos
- **THEN** no se crea ninguna cuenta ni se envían datos a un servidor propio

#### Scenario: Solo API pública

- **WHEN** la app comprueba precios para los avisos
- **THEN** solo consulta `api.preciosgasolina.es` con los endpoints y campos documentados

#### Scenario: Límites de la API

- **WHEN** hay varias favoritas con aviso
- **THEN** la app limita las peticiones para respetar los límites publicados

#### Scenario: Atribución y licencia

- **WHEN** el usuario consulta los datos que originan los avisos
- **THEN** la atribución a Gasolina hoy y al Ministerio y la licencia CC BY 4.0 siguen
  disponibles en Configuración → Acerca de
