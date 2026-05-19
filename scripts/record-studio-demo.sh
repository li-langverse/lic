#!/usr/bin/env bash
# Record Li World Studio demo showcase to WebM (puppeteer + ffmpeg).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DURATION="${DURATION:-30}"
FPS="${FPS:-12}"
PKG="$ROOT/scripts/studio-demo-pkg"

if [[ ! -d "$PKG/node_modules/puppeteer-core" ]]; then
  echo "Installing puppeteer-core (one-time)..."
  npm install --prefix "$PKG" --silent
fi

node "$ROOT/scripts/studio-demo-capture.mjs" "$DURATION" "$FPS"
echo "Open $ROOT/deploy/studio-demo/index.html for interactive studio."
