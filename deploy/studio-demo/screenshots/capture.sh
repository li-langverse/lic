#!/usr/bin/env bash
# Capture PNG screenshots from static HTML mocks (1920×1080). Not committed to git by loop.
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
OUT="${OUT:-$DIR/png}"
CHROME="${CHROME:-}"
for c in google-chrome chromium chromium-browser; do
  if command -v "$c" >/dev/null 2>&1; then CHROME="$c"; break; fi
done
[[ -n "$CHROME" ]] || { echo "no chrome"; exit 0; }
mkdir -p "$OUT"

for f in "$DIR"/[0-9]*.html; do
  [[ -f "$f" ]] || continue
  base=$(basename "$f" .html)
  "$CHROME" --headless --disable-gpu --hide-scrollbars \
    --window-size=1920,1080 \
    --screenshot="$OUT/${base}.png" \
    "file://${f}"
  echo "  $OUT/${base}.png"
done
