# Design

## Context

`release.yml` compila el bundle Linux y, en el mismo job `linux`, ejecuta
`packaging/linux/empaquetar.sh`, que genera el `tar.gz`, el AppImage y el Flatpak. El
manifiesto copia el bundle a `/app/bin` con `cp -r` y no fija el permiso del binario
principal. Mientras el bundle conserve el modo `0755` el paquete funciona, pero el
resultado depende del origen: un artefacto de GitHub Actions (zip), una copia manual o
cualquier proceso que normalice a `0644` producen un Flatpak que no arranca.

En tolochameteo el fallo ya era real porque el Flatpak se construye en un job distinto
que descarga el bundle como artefacto. Aquí el empaquetado es en el mismo job, así que
el bug está latente; se corrige igual para no depender del orden y del transporte del
bundle.

## Goals / Non-Goals

**Goals:**

- Garantizar que el binario principal del Flatpak sea ejecutable.
- Evitar que el fallo dependa de cómo se obtiene el bundle (artefacto, copia local o
  build manual).
- Que `tar.gz`, AppImage y Flatpak se generen siempre desde un binario ejecutable.

**Non-Goals:**

- Cambiar el layout de instalación, el runtime GNOME o los permisos del sandbox.
- Alterar el comportamiento de la app o de los paquetes de otras plataformas.
- Añadir dependencias nuevas al workflow.
- Republicar la release actual.

## Decisions

1. **`chmod +x` en el manifiesto Flatpak.**
   - Se añade `chmod +x /app/bin/tolochafuel` justo después de `cp -r`.
   - El manifiesto queda autosuficiente: el arreglo se aplica también en builds locales
     con `flatpak-builder` o si en el futuro cambia la forma de preparar el bundle.
   - Alternativa descartada: instalar solo el binario con `install -Dm755` y copiar
     aparte `data` y `lib`; funciona, pero separa la copia del bundle y se aleja del
     arreglo ya aplicado en tolochameteo.

2. **Normalizar el bundle en `empaquetar.sh`.**
   - El script comprueba que existe el binario y le aplica `chmod +x` antes de generar
     los paquetes.
   - La comprobación pasa de `-x` a `-f`: el objetivo es empaquetar un binario que
     existe, y el script lo deja ejecutable en vez de abortar por un permiso que puede
     corregir.
   - Sirve de defensa en profundidad para el `tar.gz` y el AppImage, que se construyen
     en el mismo script, y para un futuro job separado de Flatpak.

3. **Verificación local sin `flatpak-builder`.**
   - Se simula un bundle sin bit de ejecución copiándolo y aplicando `chmod 0644` al
     binario; después se ejecuta la secuencia del manifiesto sobre una raíz temporal y
     se comprueba que el binario queda ejecutable.
   - Se valida el YAML del manifiesto y se ejecuta `npm run verify`.

## Risks / Trade-offs

- **Nombre del binario cambiado** → el `chmod` fallaría y el build se detendría antes
  de publicar un Flatpak inútil; es el comportamiento deseado.
- **Bundle incompleto** → la comprobación de existencia falla y el script no empaqueta
  nada.
- **Artefactos ya publicados** → la release existente no necesita cambios (su binario
  ya es ejecutable); el endurecimiento entra en la próxima release.

## Migration Plan

Sin migración de datos ni cambios de app. El arreglo se publica con la siguiente
release y no requiere reinstalar el Flatpak actual si ya funciona.
