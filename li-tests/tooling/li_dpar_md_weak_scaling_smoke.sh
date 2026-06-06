#!/usr/bin/env bash
# WP-PAR-20/22 — programmed cluster multi-node MD weak-scaling specimen.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RT="$ROOT/runtime"
OUT="$ROOT/build/li_dpar_md_weak_scaling_smoke"
SRC="$RT/test/li_dpar_md_weak_scaling_smoke.c"
MD_MINI="$RT/test/md_smoke_mini.c"
LIPAR_RUN="$ROOT/packages/li-parallel/scripts/lipar-run.sh"

CC="${CC:-clang-22}"
mkdir -p "$(dirname "$OUT")"
"$CC" -std=c11 -O2 -Wall -Wextra -D_DEFAULT_SOURCE \
  -I"$RT/test" \
  -I"$RT" \
  "$SRC" \
  "$MD_MINI" \
  "$RT/li_dpar.c" \
  "$RT/li_dpar_collective.c" \
  -pthread -lm \
  -o "$OUT"

LI_DPAR_RANK=0 LI_DPAR_WORLD_SIZE=1 "$OUT"

PORT="${LI_DPAR_PORT:-29601}"
chmod +x "$LIPAR_RUN"
"$LIPAR_RUN" --hosts "127.0.0.1,127.0.0.1,127.0.0.1,127.0.0.1" --world 4 --port "$PORT" -- "$OUT"
