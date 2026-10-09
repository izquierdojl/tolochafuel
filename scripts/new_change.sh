#!/usr/bin/env bash
set -euo pipefail

# Crea un change OpenSpec con nombre <tipo>-<id8>-<slug> y metadata completa.
# Uso: scripts/new_change.sh <tipo> "<titulo>" [dev|feature]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RAIZ="$(dirname "$SCRIPT_DIR")"
CHANGE_DIR_BASE="$RAIZ/openspec/changes"

DEFAULT_BRANCH="${TOLOCHAFUEL_DEFAULT_BRANCH:-dev}"
TIPOS="feature bug docs infra refactor test chore"

if [[ $# -lt 2 ]]; then
  echo "Uso: scripts/new_change.sh <tipo> \"<titulo>\" [dev|feature]" >&2
  echo "Tipos: $TIPOS" >&2
  exit 1
fi

TIPO="$1"
TITULO="$2"
RAMA="${3:-$DEFAULT_BRANCH}"

if ! echo " $TIPOS " | grep -q " $TIPO "; then
  echo "Tipo no valido: '$TIPO'. Tipos admitidos: $TIPOS" >&2
  exit 1
fi

if [[ "$RAMA" != "dev" && "$RAMA" != "feature" ]]; then
  echo "Rama no valida: '$RAMA'. Use 'dev' o 'feature'." >&2
  exit 1
fi

ID="$(python3 "$SCRIPT_DIR/spec_id.py")"
SLUG="$(python3 - "$TITULO" <<'PY'
import re
import sys
import unicodedata

texto = sys.argv[1]
texto = unicodedata.normalize("NFD", texto)
texto = "".join(c for c in texto if unicodedata.category(c) != "Mn")
texto = texto.lower()
texto = re.sub(r"[^a-z0-9]+", "-", texto).strip("-")
print(texto or "sin-titulo")
PY
)"
NOMBRE="${TIPO}-${ID}-${SLUG}"
DESTINO="$CHANGE_DIR_BASE/$NOMBRE"

if [[ -e "$DESTINO" ]]; then
  echo "El change ya existe: $NOMBRE" >&2
  exit 1
fi

AUTOR_NOMBRE="$(git -C "$RAIZ" config user.name || true)"
AUTOR_EMAIL="$(git -C "$RAIZ" config user.email || true)"
AUTOR_NOMBRE="${AUTOR_NOMBRE:-desconocido}"
AUTOR_EMAIL="${AUTOR_EMAIL:-desconocido}"
FECHA="$(date --iso-8601=seconds)"

cd "$RAIZ"
openspec new change "$NOMBRE" >/dev/null

cat > "$DESTINO/meta.yaml" <<EOF
tipo: $TIPO
id: $ID
titulo: "$TITULO"
autor:
  nombre: "$AUTOR_NOMBRE"
  email: "$AUTOR_EMAIL"
fecha: "$FECHA"
branch: $RAMA
EOF

echo "Change creado: openspec/changes/$NOMBRE"
echo "  tipo:   $TIPO"
echo "  id:     $ID"
echo "  autor:  $AUTOR_NOMBRE <$AUTOR_EMAIL>"
echo "  fecha:  $FECHA"
echo "  branch: $RAMA"

if [[ "$RAMA" == "feature" ]]; then
  RAMA_GIT="feature/$NOMBRE"
  if git -C "$RAIZ" rev-parse --verify "$RAMA_GIT" >/dev/null 2>&1; then
    git -C "$RAIZ" switch "$RAMA_GIT"
  else
    git -C "$RAIZ" switch -c "$RAMA_GIT"
  fi
  echo "  rama git: $RAMA_GIT"
fi
