#!/usr/bin/env bash
# WP-PAR-72 — MD specimen ghost overlap ≥50%.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RT="$ROOT/runtime"
OUT="$ROOT/build/li_comm_md_ghost_overlap_smoke"
SRC="$RT/test/li_comm_md_ghost_overlap_smoke.c"
LIPAR_RUN="$ROOT/packages/li-parallel/scripts/lipar-run.sh"

CC="${CC:-clang-22}"
mkdir -p "$(dirname "$OUT")"
"$CC" -std=c11 -O2 -Wall -Wextra -D_DEFAULT_SOURCE \
  -I"$RT" \
  "$SRC" \
  "$RT/li_dpar.c" \
  "$RT/li_dpar_collective.c" \
  "$RT/li_comm_plan.c" \
  -pthread -lm \
  -o "$OUT"

LI_DPAR_RANK=0 LI_DPAR_WORLD_SIZE=1 "$OUT"

PORT="${LI_DPAR_PORT:-29620}"
chmod +x "$LIPAR_RUN"
"$LIPAR_RUN" --hosts "127.0.0.1,127.0.0.1,127.0.0.1,127.0.0.1" --world 4 --port "$PORT" -- "$OUT"
