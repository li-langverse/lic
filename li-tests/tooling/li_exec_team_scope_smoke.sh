#!/usr/bin/env bash
# WP-PAR-17 — scoped team push/pop runtime smoke.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RT="$ROOT/runtime"
OUT="$ROOT/build/li_exec_team_scope_smoke"
SRC="$RT/test/li_exec_team_scope_smoke.c"

CC="${CC:-clang-22}"
mkdir -p "$(dirname "$OUT")"
"$CC" -std=c11 -O2 -Wall -Wextra -D_DEFAULT_SOURCE \
  -I"$RT" \
  "$SRC" \
  "$RT/li_par_pool.c" \
  "$RT/li_par_reduce.c" \
  "$RT/li_exec_plan.c" \
  "$RT/li_comm_plan.c" \
  "$RT/li_dpar.c" \
  -pthread -lm \
  -o "$OUT"

"$OUT"
