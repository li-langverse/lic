#!/usr/bin/env bash
# Build in-tree MCP stdio server (li-engine) — links runtime/li_rt.c only.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CC="${CC:-clang}"
OUT="${1:-$ROOT/build/tools/studio-mcp-li-engine}"
mkdir -p "$(dirname "$OUT")"
"$CC" -Wno-override-module -x c "$ROOT/runtime/li_rt.c" \
  -x c "$ROOT/runtime/studio_mcp_stdio.c" \
  -I"$ROOT/runtime" -lm -o "$OUT"
echo "built $OUT"
