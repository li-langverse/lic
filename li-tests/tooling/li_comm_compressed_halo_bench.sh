#!/usr/bin/env bash
# WP-PAR-75 — compressed halo roundtrip bench.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RT="$ROOT/runtime"
OUT="$ROOT/build/li_comm_compressed_halo_bench"
SRC="$RT/test/li_comm_compressed_halo_bench.c"

CC="${CC:-clang-22}"
mkdir -p "$(dirname "$OUT")"
"$CC" -std=c11 -O2 -Wall -Wextra -D_DEFAULT_SOURCE \
  -I"$RT" \
  "$SRC" \
  "$RT/li_fl.c" \
  "$RT/li_dpar.c" \
  -pthread -lm \
  -o "$OUT"

"$OUT"
