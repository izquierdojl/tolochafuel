# Design

## Context

La app tiene la lista de cercanas con tarjeta de gasolinera y cliente API con caché en
memoria. `shared_preferences` ya forma parte del stack fijado en AGENTS.md. Sin cuentas
ni backend por decisión de proyecto. Ver `proposal.md` para la motivación.

## Goals / Non-Goals

**Goals:**

- Marcado instantáneo y persistente entre ejecuciones.
- Pantalla de favoritos con precios vigentes por identificador.
- Estado de favoritos compartido entre las dos secciones de la app.

**Non-Goals:**

- Guardar precios históricos o comparar variaciones.
- Sincronización remota de cualquier tipo.

## Decisions

- **Modelo `Favorito` inmutable** (id, rótulo, dirección, lat, lng) en
  `lib/features/favoritos/data/favorito.dart`, serializado como JSON en una única clave
  de `shared_preferences`. Se guarda solo la identidad: el precio siempre se consulta en
  vivo para no mostrar datos obsoletos.
- **`FavoritosController` (provider) global**, registrado en `main.dart`: expone
  `esFavorito(id)`, `alternar(gasolinera)` y la lista; la lista de cercanas y la sección
  Favoritos comparten el mismo estado reactivo.
- **Precios de favoritos**: `GET /v1/stations/{id}` por cada favorito con la caché en
  memoria del cliente API; las consultas se lanzan al abrir la sección, nunca en bucle.
- **UI**: `NavigationBar` inferior con dos destinos («Cercanas» y «Favoritos»); la
  tarjeta existente gana el icono de favorito y conserva la acción «Navegar» cuando el
  change de navegación esté aplicado.
- **Errores por favorito**: si la consulta de precio falla, el favorito se muestra igual
  (identidad local) con «Precio no disponible» y reintento; nunca se elimina solo.

## Risks / Trade-offs

- **Favoritos de gasolineras desaparecidas**: si el `id` deja de existir en la API, la
  tarjeta muestra precio no disponible; se podrá borrar manualmente.
- **Duplicidad de claves**: el almacenamiento guarda una sola entrada JSON; un fallo de
  parseo no debe romper la app (lista vacía + aviso).
