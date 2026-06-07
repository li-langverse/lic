#!/usr/bin/env bash
# WP-PAR-23 — distributed for runtime block partition smoke.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RT="$ROOT/runtime"
OUT="$ROOT/build/li_dpar_for_smoke"
SRC="$RT/test/li_dpar_for_smoke.c"

CC="${CC:-clang-22}"
mkdir -p "$(dirname "$OUT")"
"$CC" -std=c11 -O2 -Wall -Wextra -D_DEFAULT_SOURCE \
  -I"$RT" \
  "$SRC" \
  "$RT/li_dpar.c" \
  -pthread -lm \
  -o "$OUT"

"$OUT"
