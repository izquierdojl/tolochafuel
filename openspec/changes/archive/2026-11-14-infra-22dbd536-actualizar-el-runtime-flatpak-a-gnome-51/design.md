# Design

## Context

Ver `proposal.md` - Why. El manifiesto
`packaging/linux/io.github.izquierdojl.TolochaFuel.yml` declara
`org.gnome.Platform`/`org.gnome.Sdk` 46 y `release.yml` instala esas mismas ramas antes
de ejecutar `packaging/linux/empaquetar.sh`. GNOME 46 está basado en Freedesktop 23.08,
de ahí los avisos de `GL.default` y `VAAPI.Intel` 23.08. Flathub ofrece actualmente las
ramas 49, 50 y 51 de `org.gnome.Platform`; la 51 incluye `libgtk-3.so.0` y
`libepoxy.so.0`, que son las bibliotecas que necesita el runner Linux de Flutter.

## Goals / Non-Goals

**Goals:**

- Referenciar únicamente un runtime soportado y actualizar el manifiesto y el job de
  release en el mismo cambio, para que no queden desalineados.
- Mantener intactos el contenido del bundle, los permisos Flatpak y el resto de assets.
- Verificar que la nueva release se construye y publica con GNOME 51.

**Non-Goals:**

- Migrar Flutter a GTK4 o cambiar la app.
- Añadir un repositorio Flatpak propio o publicar en Flathub.
- Cambiar el proceso de release, el versionado o los otros empaquetados.

## Decisions

- **Saltar a GNOME 51, no a 49 ni 50.** Las tres ramas aparecen hoy en Flathub, pero 51 es
  la más reciente y la que más tiempo seguirá soportada; 49 y 50 acortarían el ciclo de
  vida del próximo release. Alternativa descartada: quedarse en 46, que ya no recibe
  parches de seguridad.

- **Actualizar manifiesto y CI a la vez.** `flatpak-builder` necesita el SDK que declara
  el manifiesto; si solo cambia el YAML, el job instalaría SDK 46 y fallaría al pedir 51.
  Si solo cambia el job, instalaría SDK 51 pero construiría con 46. Ambos valores viven
  en el mismo commit y en la misma release.

- **Reutilizar el manifiesto y el script existentes.** Solo cambia `runtime-version` y la
  línea de instalación del runner; no se toca `finish-args`, el módulo `simple`, la
  iconografía ni el `.desktop`. Alternativa descartada: introducir un manifiesto
  parametrizado, innecesario para una sola app.

- **La release es la verificación autoritativa.** El job `linux` de `release.yml` instala
  el SDK, ejecuta `flatpak-builder` y empaqueta el bundle; si GNOME 51 no satisficiera las
  dependencias de Flutter, el workflow fallaría antes de publicar. En local se comprueba
  el manifiesto y que el runtime 51 contiene GTK3/libepoxy, pero no se exige instalar
  SDK/SDK-builder en la máquina de desarrollo.

## Risks / Trade-offs

- [GNOME 51 cambia bibliotecas y el runner Flutter no arranca en el sandbox] → el runtime
  51 incluye GTK3 y libepoxy; la build de release lo valida antes de publicar y, si
  fallara, se revierte el manifiesto a 50 o 49 en un change de corrección.
- [El primer build descarga ~875 MB de SDK en CI] → se acepta el coste puntual; el cache
  del runner y las siguientes releases lo reutilizan.
- [Usuarios con la versión anterior siguen viendo el aviso hasta actualizar] → el aviso es
  del runtime instalado, no del repo; al instalar la release nueva el Flatpak pasa a
  referenciar 51 y los runtimes 46/23.08 quedan como no usados.
- [Runtimes antiguos ocupando disco tras la actualización] → no se automatiza su borrado;
  se puede ejecutar `flatpak uninstall --unused` y se documenta en la respuesta del
  release.

## Migration Plan

1. Cambiar el manifiesto y el workflow en `dev`.
2. Publicar una release patch; `version.yml` la etiqueta y `release.yml` reconstruye el
   Flatpak con GNOME 51.
3. Los usuarios actualizan con `flatpak update`; si quieren liberar espacio, ejecutan
   `flatpak uninstall --unused`.
4. Rollback: revertir el cambio del runtime a la rama anterior y publicar otra patch; el
   bundle antiguo seguiría siendo instalable, aunque con el aviso de EOL.
