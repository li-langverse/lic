#!/usr/bin/env bash
# Scaffold a World Studio project from spin-up templates (until `lis new` ships).
# Usage: ./scripts/lis-new-world-studio.sh [template] [dest_dir]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE="${1:-game}"
DEST="${2:-.}"
SRC="$ROOT/deploy/world-studio-spinup/templates/$TEMPLATE"

if [[ ! -d "$SRC" ]]; then
  echo "Unknown template: $TEMPLATE" >&2
  echo "See deploy/world-studio-spinup/spinup.toml" >&2
  exit 1
fi

mkdir -p "$DEST"
cp -r "$SRC/"* "$DEST/"
if [[ -f "$ROOT/deploy/world-studio-spinup/spinup.toml" ]]; then
  cp "$ROOT/deploy/world-studio-spinup/spinup.toml" "$DEST/spinup.toml"
fi
echo "Created World Studio project ($TEMPLATE) in $DEST"
echo "  main.li · studio.toml (if present)"
echo "Next: lic check $DEST/main.li"
