#!/usr/bin/env bash
# Capture PNG mockups to .artifacts/studio-mockups/ (gitignored).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PKG="$ROOT/scripts/studio-demo-pkg"
if [[ ! -d "$PKG/node_modules/puppeteer-core" ]]; then
  npm install --prefix "$PKG" --silent
fi
node "$ROOT/scripts/capture-studio-mockup-screenshots.mjs"
