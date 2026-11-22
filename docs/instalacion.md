# Instalación

> [← Volver al README](../README.md)

TolochaFuel se distribuye desde [GitHub Releases](https://github.com/izquierdojl/tolochafuel/releases/latest).
Los enlaces de descarga directa usan siempre la última versión publicada.

| Plataforma | Formato | Descarga |
| --- | --- | --- |
| Android | APK | [tolochafuel.apk](https://github.com/izquierdojl/tolochafuel/releases/latest/download/tolochafuel.apk) |
| Windows x64 | ZIP portable | [tolochafuel-windows-x64.zip](https://github.com/izquierdojl/tolochafuel/releases/latest/download/tolochafuel-windows-x64.zip) |
| Linux x64 | tar.gz portable | [tolochafuel-linux-x64.tar.gz](https://github.com/izquierdojl/tolochafuel/releases/latest/download/tolochafuel-linux-x64.tar.gz) |
| Linux x64 | AppImage | [tolochafuel-linux-x64.AppImage](https://github.com/izquierdojl/tolochafuel/releases/latest/download/tolochafuel-linux-x64.AppImage) |
| Linux x64 | Flatpak | [tolochafuel-linux-x64.flatpak](https://github.com/izquierdojl/tolochafuel/releases/latest/download/tolochafuel-linux-x64.flatpak) |

iOS, la web y la Play Store están aplazados; no hay descargas para esas plataformas.

## Android

1. Descarga `tolochafuel.apk` en el dispositivo.
2. Abre el archivo. Si Android no permite instalar apps de esa procedencia, activa el
   permiso para el navegador o el gestor de archivos que uses.
3. Instala y abre TolochaFuel.

Las versiones se firman con la misma clave de release, así que las actualizaciones se
instalan encima de la anterior sin desinstalar. La app no está en Play Store.

## Windows

1. Descarga `tolochafuel-windows-x64.zip`.
2. Extrae todo el contenido en una carpeta (no ejecutes el programa desde dentro del ZIP).
3. Abre `tolochafuel.exe`.

Al no estar firmado con un certificado de código, SmartScreen puede mostrar un aviso la
primera vez: pulsa **Más información** y después **Ejecutar de todas formas**. Es el
comportamiento esperado de un ejecutable sin firma comercial.

## Linux

### tar.gz portable

```bash
tar -xzf tolochafuel-linux-x64.tar.gz
./tolochafuel/tolochafuel
```

La carpeta `tolochafuel/` debe mantenerse completa: el ejecutable necesita los datos y
las bibliotecas que la acompañan.

### AppImage

```bash
chmod +x tolochafuel-linux-x64.AppImage
./tolochafuel-linux-x64.AppImage
```

### Flatpak

```bash
flatpak install --user ./tolochafuel-linux-x64.flatpak
flatpak run io.github.izquierdojl.TolochaFuel
```

El paquete usa el runtime `org.gnome.Platform` 51. Si no está instalado, Flatpak lo
descarga desde Flathub; asegúrate de tener el remoto configurado o acepta la instalación
que proponga el sistema.

## Ubicación en el escritorio

En Windows y Linux la app no puede leer la ubicación del sistema. En Cercanas y Más
económicas muestra un aviso y ofrece la sección **Buscar** para elegir un municipio o una
provincia. La navegación a la gasolinera abre Google Maps en el navegador.
