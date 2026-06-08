#!/usr/bin/env bash
# WP-PAR-12 — dynamic and guided schedulers on persistent pthread pool.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RT="$ROOT/runtime"
OUT="$ROOT/build/li_par_pool_schedule_smoke"
SRC="$RT/test/li_par_pool_schedule_smoke.c"

CC="${CC:-clang-22}"
mkdir -p "$(dirname "$OUT")"
"$CC" -std=c11 -O2 -Wall -Wextra \
  -I"$RT" \
  "$SRC" \
  "$RT/li_par_pool.c" \
  "$RT/li_par_reduce.c" \
  -pthread -lm \
  -o "$OUT"

"$OUT"
