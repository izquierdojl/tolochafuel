# historico-precios Specification

## Purpose
Muestra la tendencia del precio de cada producto de una estación según su última
variación registrada y permite consultar sus últimos cambios de precio.

## Requirements

### Requirement: Tendencia por última variación registrada

La tarjeta de gasolinera SHALL indicar, a la derecha del precio de cada producto, la
tendencia según la última variación registrada en el histórico diario de la estación
(hasta 90 días, `/v1/stations/{id}/history`), con los colores del tema. La atribución
completa a Gasolina hoy y al Ministerio (CC BY 4.0) vive en Configuración → Acerca de.

#### Scenario: Precio que baja

- **WHEN** el último precio de los últimos 90 días es menor que el anterior precio
  distinto
- **THEN** la fila del producto muestra una flecha verde hacia abajo a la derecha del
  precio

#### Scenario: Precio que sube

- **WHEN** el último precio de los últimos 90 días es mayor que el anterior precio
  distinto
- **THEN** la fila del producto muestra una flecha roja hacia arriba a la derecha del
  precio

#### Scenario: Precio sin cambios

- **WHEN** todos los precios de los últimos 90 días son iguales
- **THEN** la fila del producto muestra un indicador neutro «=»

#### Scenario: Sin histórico disponible

- **WHEN** la estación no tiene histórico o la consulta falla
- **THEN** la tarjeta muestra el precio sin flecha, sin bloquear la lista

### Requirement: Detalle de los últimos cambios de precio

Al pulsar sobre el precio o la flecha de un producto, la app SHALL abrir un modal con
los últimos cambios de precio de cada producto (según
`/v1/stations/{id}/history?days=90`), agrupados, con su fecha (dd/mm/aaaa), su precio y
una flecha de subida o bajada a la derecha con los colores de tendencia del tema. La
atribución completa a Gasolina hoy y al Ministerio (CC BY 4.0) vive en Configuración →
Acerca de.

#### Scenario: Apertura del modal

- **WHEN** el usuario pulsa el precio o la flecha de un producto
- **THEN** se abre un modal con los últimos cambios de precio (hasta cinco) de cada
  producto, agrupados y con su fecha (dd/mm/aaaa), su precio y su flecha de dirección

#### Scenario: Cambio al alza

- **WHEN** el precio de un cambio es mayor que el registro anterior
- **THEN** su fila muestra una flecha roja hacia arriba

#### Scenario: Cambio a la baja

- **WHEN** el precio de un cambio es menor que el registro anterior
- **THEN** su fila muestra una flecha verde hacia abajo

#### Scenario: Producto sin cambios

- **WHEN** el precio de un producto no ha cambiado en los últimos 90 días
- **THEN** el modal indica «Sin cambios en los últimos 90 días» para ese producto

#### Scenario: Resumen de variación por producto

- **WHEN** el usuario abre el modal de histórico
- **THEN** cada producto con histórico muestra, bajo sus últimos cambios, el bloque de
  medias de la última semana y del último mes con su flecha de tendencia

#### Scenario: Histórico cargando

- **WHEN** el histórico aún no está disponible al abrir el modal
- **THEN** el modal muestra un indicador de carga y se completa al llegar la respuesta

#### Scenario: Error al consultar el histórico

- **WHEN** la consulta del histórico falla
- **THEN** el modal muestra un mensaje en español con opción de reintentar

#### Scenario: Estación sin histórico

- **WHEN** la estación no tiene datos históricos
- **THEN** el modal lo indica en español sin bloquear el resto de la pantalla

### Requirement: Límites de la API y caché del histórico

La app SHALL tratar `/v1/stations/{id}/history` como consulta pesada (30 pet/min por
IP): SHALL consultarlo solo para estaciones visibles, con concurrencia limitada, y SHALL
cachear cada histórico en memoria hasta la próxima actualización de la fuente
(`meta.next_update`), sin polling.

#### Scenario: Navegación repetida

- **WHEN** el usuario vuelve a ver una estación ya consultada antes de la próxima
  actualización de la fuente
- **THEN** se reutiliza el histórico cacheado y no se repite la petición

#### Scenario: Límite de concurrencia

- **WHEN** muchas tarjetas visibles piden histórico a la vez
- **THEN** las peticiones se limitan para no superar el límite de consultas pesadas

### Requirement: Medias de la última semana y del último mes

El modal SHALL mostrar, bajo los últimos cambios de cada producto, la media de los
últimos 7 registros diarios («Última semana») y de los últimos 30 («Último mes»), en la
unidad del producto. Cada media SHALL llevar una flecha de tendencia (colores del tema)
que la compara con la media anterior equivalente, o «=» si coinciden a tres decimales;
sin ventana anterior completa, sin flecha. Atribución a Gasolina hoy y al Ministerio
(CC BY 4.0) en Configuración → Acerca de.

#### Scenario: Última semana y último mes

- **WHEN** el histórico del producto cubre al menos 30 registros diarios
- **THEN** el bloque muestra «Última semana» y «Último mes» con la media de sus últimos
  7 y 30 precios en la unidad del producto

#### Scenario: Media semanal a la baja

- **WHEN** hay al menos 14 registros y la media de los últimos 7 es menor que la de los
  7 anteriores
- **THEN** la fila «Última semana» muestra una flecha verde hacia abajo

#### Scenario: Media mensual al alza

- **WHEN** hay al menos 60 registros y la media de los últimos 30 es mayor que la de
  los 30 anteriores
- **THEN** la fila «Último mes» muestra una flecha roja hacia arriba

#### Scenario: Medias iguales

- **WHEN** la media de una ventana coincide a tres decimales con la de la ventana
  anterior
- **THEN** su fila muestra un indicador neutro «=»

#### Scenario: Ventana anterior incompleta

- **WHEN** el histórico tiene entre 7 y 13 registros (o entre 30 y 59 para el mes)
- **THEN** la fila de esa ventana muestra su media sin flecha

#### Scenario: Histórico corto

- **WHEN** el histórico tiene menos de 7 registros
- **THEN** no se muestran filas de medias y el bloque se limita a ofrecer el gráfico

#### Scenario: Producto sin cambios en 90 días

- **WHEN** todos los precios del histórico de un producto son iguales
- **THEN** se mantiene la nota «Sin cambios en los últimos 90 días» y sus medias
  aparecen con «=»

### Requirement: Gráfico del precio

Al pulsar el bloque de medias, el modal SHALL expandir un gráfico de línea con los
últimos precios registrados del producto (hasta 90 días del histórico ya cacheado),
con el precio actual resaltado; al tocar un punto SHALL mostrar su fecha (dd/mm/aaaa) y
su precio en la unidad del producto. El gráfico usa los colores y la tipografía del
tema y se contrae al volver a pulsar el bloque. Atribución a Gasolina hoy y al
Ministerio (CC BY 4.0) en Configuración → Acerca de.

#### Scenario: Gráfico expandido

- **WHEN** el usuario pulsa el bloque de medias de un producto con al menos 2 registros
- **THEN** se expande un gráfico de línea bajo el bloque con los últimos precios y el
  punto actual resaltado

#### Scenario: Detalle de un punto

- **WHEN** el usuario toca un punto del gráfico
- **THEN** se muestra un tooltip con la fecha (dd/mm/aaaa) y el precio en la unidad del
  producto

#### Scenario: Gráfico contraído

- **WHEN** el usuario vuelve a pulsar el bloque con el gráfico expandido
- **THEN** el gráfico se contrae

#### Scenario: Serie plana

- **WHEN** todos los precios del producto son iguales
- **THEN** el gráfico muestra una línea horizontal legible, sin peticiones adicionales

#### Scenario: Menos de dos registros

- **WHEN** el producto tiene menos de 2 registros históricos
- **THEN** no se ofrece gráfico para ese producto

#### Scenario: Sin histórico

- **WHEN** la estación no tiene histórico o la consulta falla
- **THEN** no hay bloque de medias ni gráfico y el modal mantiene su estado vacío o de
  error con reintento
