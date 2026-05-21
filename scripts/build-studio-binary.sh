#!/usr/bin/env bash
# Build native World Studio shell stub binary (studio_main.li).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
OUT="${1:-$ROOT/build/bin/world-studio}"
MAIN="$ROOT/packages/studio/src/studio_main.li"
mkdir -p "$(dirname "$OUT")"
echo "build-studio-binary: $MAIN -> $OUT"
"$LIC" build "$MAIN" -o "$OUT"
echo "build-studio-binary: ok"
