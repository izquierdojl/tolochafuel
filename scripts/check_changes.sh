#!/usr/bin/env bash
set -euo pipefail

# Valida la nomenclatura y metadata de todos los changes OpenSpec.
# Uso: scripts/check_changes.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RAIZ="$(dirname "$SCRIPT_DIR")"
CAMBIOS="$RAIZ/openspec/changes"

PATRON_NOMBRE='^(feature|bug|docs|infra|refactor|test|chore)-[0-9a-f]{8}-[a-z0-9]+(-[a-z0-9]+)*$'
PATRON_ID='^[0-9a-f]{8}$'
ERRORES=0

if [[ ! -d "$CAMBIOS" ]]; then
  echo "No existe $CAMBIOS" >&2
  exit 1
fi

comprobar_change() {
  local dir="$1" base errores_locales=0
  base="$(basename "$dir")"

  if [[ "$base" == "archive" || "$base" == ".gitkeep" ]]; then
    return 0
  fi

  # Los archivados se guardan con el prefijo de fecha YYYY-MM-DD-.
  local nombre="$base"
  if [[ "$nombre" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}- ]]; then
    nombre="${nombre#????-??-??-}"
  fi

  if [[ ! "$nombre" =~ $PATRON_NOMBRE ]]; then
    echo "✗ $base: nombre fuera de convención <tipo>-<id8>-<slug>" >&2
    errores_locales=1
  fi

  local meta="$dir/meta.yaml"
  if [[ ! -f "$meta" ]]; then
    echo "✗ $base: falta meta.yaml" >&2
    return 1
  fi

  local tipo id titulo fecha branch
  tipo="$(sed -n 's/^tipo:[[:space:]]*//p' "$meta" | head -1 | tr -d '[:space:]')"
  id="$(sed -n 's/^id:[[:space:]]*//p' "$meta" | head -1 | tr -d '[:space:]')"
  titulo="$(sed -n 's/^titulo:[[:space:]]*//p' "$meta" | head -1 | sed 's/^"//; s/"$//')"
  fecha="$(sed -n 's/^fecha:[[:space:]]*//p' "$meta" | head -1 | sed 's/^"//; s/"$//')"
  branch="$(sed -n 's/^branch:[[:space:]]*//p' "$meta" | head -1 | tr -d '[:space:]')"

  [[ -n "$tipo" ]] || { echo "✗ $base: meta.yaml sin 'tipo'" >&2; errores_locales=1; }
  [[ -n "$id" ]] || { echo "✗ $base: meta.yaml sin 'id'" >&2; errores_locales=1; }
  [[ -n "$titulo" ]] || { echo "✗ $base: meta.yaml sin 'titulo'" >&2; errores_locales=1; }
  [[ -n "$fecha" ]] || { echo "✗ $base: meta.yaml sin 'fecha'" >&2; errores_locales=1; }
  [[ -n "$branch" ]] || { echo "✗ $base: meta.yaml sin 'branch'" >&2; errores_locales=1; }

  if [[ -n "$id" && ! "$id" =~ $PATRON_ID ]]; then
    echo "✗ $base: id '$id' no son 8 hex" >&2
    errores_locales=1
  fi

  if [[ -n "$branch" && "$branch" != "dev" && "$branch" != "feature" ]]; then
    echo "✗ $base: branch '$branch' debe ser 'dev' o 'feature'" >&2
    errores_locales=1
  fi

  if [[ "$nombre" == "${tipo}-${id}-"* ]]; then
    :
  else
    echo "✗ $base: el nombre no coincide con tipo+id de meta.yaml" >&2
    errores_locales=1
  fi

  if [[ -n "$fecha" && ! "$fecha" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2} ]]; then
    echo "✗ $base: fecha '$fecha' no es ISO 8601" >&2
    errores_locales=1
  fi

  return "$errores_locales"
}

TOTAL=0
for dir in "$CAMBIOS"/*/; do
  [[ -d "$dir" ]] || continue
  base="$(basename "$dir")"
  [[ "$base" == "archive" ]] && continue
  TOTAL=$((TOTAL + 1))
  if ! comprobar_change "$dir"; then
    ERRORES=$((ERRORES + 1))
  fi
done

if [[ -d "$CAMBIOS/archive" ]]; then
  for dir in "$CAMBIOS/archive"/*/; do
    [[ -d "$dir" ]] || continue
    TOTAL=$((TOTAL + 1))
    if ! comprobar_change "$dir"; then
      ERRORES=$((ERRORES + 1))
    fi
  done
fi

if [[ "$ERRORES" -gt 0 ]]; then
  echo "check_changes: $ERRORES change(s) con problemas de $TOTAL revisados" >&2
  exit 1
fi

echo "check_changes: $TOTAL change(s) correctos"
