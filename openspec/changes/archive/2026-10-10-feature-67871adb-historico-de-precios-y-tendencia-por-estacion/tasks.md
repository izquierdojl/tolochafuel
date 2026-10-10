# Tasks

## 1. Modelo y API

- [x] 1.1 Crear `HistoricoEstacion` con series por carburante (puntos fecha/precio) y `proximaActualizacion`, con parseo tolerante; test de modelo con JSON real simplificado, incluida una serie con huecos (`flutter analyze` + `flutter test` en verde)
- [x] 1.2 `PreciosGasolinaApi.historico(id, {days = 90})` contra `/v1/stations/{id}/history?days=90`; test de API con cliente falso verificando ruta, parámetros y parseo (`flutter analyze` + `flutter test` en verde)

## 2. Controlador y tema

- [x] 2.1 `HistorialController` con caché TTL (`meta.next_update`), deduplicación, cola de concurrencia (máx. 4) y estados `cargando`/`error` por id; tests: la caché no repite peticiones, el error no rompe y la cola limita las simultáneas (`flutter analyze` + `flutter test` en verde)
- [x] 2.2 Colores semánticos de tendencia en `lib/app/theme` (`ThemeExtension` para claro y oscuro) con valores de la paleta; verificación de que ambos temas los exponen (`flutter analyze` + `flutter test` en verde)

## 3. Interfaz

- [x] 3.1 Flecha de tendencia por producto en `TarjetaGasolinera` (verde ▼, roja ▲, neutra «=», comparación redondeada a 3 decimales) con carga perezosa al montar; widget tests: baja, sube, igual y sin histórico (sin flecha) (`flutter analyze` + `flutter test` en verde)
- [x] 3.2 Modal de últimos cambios de precio (`showModalBottomSheet`) agrupado por producto con fecha (dd/mm/aaaa), precio y variación, con estados de carga, error con reintento y sin datos; widget tests de cada estado (`flutter analyze` + `flutter test` en verde)
- [x] 3.3 Registrar `HistorialController` en `main.dart` y verificar la integración en Cercanas, Más económicas, Buscar y Favoritos con la tarjeta compartida; tests existentes en verde (`flutter analyze` + `flutter test` en verde)

## 4. Verificación final

- [x] 4.1 `dart format .` + `flutter analyze` + `flutter test` en verde y prueba manual (Android o escritorio) abriendo Cercanas y navegando entre secciones, comprobando que no hay 429 y que la caché evita repetir consultas

## Workflow follow-up

- Archivar el change cuando esté implementado y verificado (commit en `dev`, `git status` limpio).
