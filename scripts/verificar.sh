#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RAIZ="$(dirname "$SCRIPT_DIR")"

cd "$RAIZ"

echo "==> Changes OpenSpec"
bash scripts/check_changes.sh

echo "==> Formato"
dart format --output=none --set-exit-if-changed lib test

echo "==> Análisis"
flutter analyze

echo "==> Tests"
flutter test
