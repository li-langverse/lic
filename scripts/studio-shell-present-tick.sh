#!/usr/bin/env bash
# PH-HW WP3 — one host present tick (SDL when available, honest mock otherwise).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NATIVE="$ROOT/deploy/studio-demo/native"
BIN="${STUDIO_SHELL_PRESENT_HOST_BIN:-$NATIVE/studio_shell_present_host}"
export LIG_HOST_PRESENT="${LIG_HOST_PRESENT:-1}"

if [[ -x "$BIN" ]]; then
  exec "$BIN" --width "${STUDIO_PRESENT_WIDTH:-1280}" --height "${STUDIO_PRESENT_HEIGHT:-720}"
fi

if [[ -f "$NATIVE/studio_shell_present_host.c" ]]; then
  chmod +x "$NATIVE/native-sdl-build.sh" 2>/dev/null || true
  if bash "$NATIVE/native-sdl-build.sh" "$NATIVE/studio_shell_present_host.c" "$BIN"; then
    exec "$BIN" --width "${STUDIO_PRESENT_WIDTH:-1280}" --height "${STUDIO_PRESENT_HEIGHT:-720}"
  fi
fi

echo '{"presented":1,"native_pixels":0,"backend":"mock","capture_mode":"no_sdl"}'
