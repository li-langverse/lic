#!/usr/bin/env bash
# PH-HW WP3 — one host present tick (aarch64-apple-darwin SDL+Metal or mock).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NATIVE="$ROOT/deploy/studio-demo/native"
BIN="${STUDIO_SHELL_PRESENT_HOST_BIN:-$NATIVE/studio_shell_present_host}"
export LIG_HOST_PRESENT="${LIG_HOST_PRESENT:-1}"

if [[ -x "$BIN" ]]; then
  "$BIN" --width 1280 --height 720
  exit 0
fi

if command -v cc >/dev/null && command -v sdl2-config >/dev/null; then
  cc -std=c11 -Wall -Wextra -o "$BIN" "$NATIVE/studio_shell_present_host.c" $(sdl2-config --cflags --libs)
  "$BIN" --width 1280 --height 720
  exit 0
fi

echo '{"presented":1,"native_pixels":0,"backend":"mock","capture_mode":"no_sdl"}'
exit 0
