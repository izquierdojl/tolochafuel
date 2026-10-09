# TolochaFuel

App móvil y de escritorio (Flutter) para consultar los precios de los carburantes de las
gasolineras cercanas en España: lista ordenada por cercanía con distancia, navegación a la
gasolinera y favoritos.

## Requisitos

- Flutter estable (versión fijada en CI: 3.47.7)
- Dart (incluido con Flutter)

## Comandos habituales

```
flutter pub get
flutter run -d <dispositivo>
flutter analyze && flutter test
dart format .
bash scripts/check_changes.sh
```

## Datos y licencia

Datos: [Gasolina hoy](https://preciosgasolina.es) (API `api.preciosgasolina.es`) con los
precios oficiales que las gasolineras comunican al Ministerio para la Transición
Ecológica y el Reto Demográfico. Licencia CC BY 4.0 con atribución visible en la app.
No son precios en tiempo real (la fuente se actualiza 2 veces al día).

## Distribución

- APK Android:
  https://github.com/izquierdojl/tolochafuel/releases/latest/download/tolochafuel.apk
- El ZIP portable de Windows se añadirá con el change `infra-…-release-windows`.

## Desarrollo

Flujo spec-driven con OpenSpec: toda funcionalidad empieza como change en
`openspec/changes/`. Ver `AGENTS.md` (constitución del proyecto).
