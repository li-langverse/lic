#!/usr/bin/env bash
# WP-PAR-88–91 — copy elision, fusion, D2D, RDMA→GPU runtime smoke.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RT="$ROOT/runtime"
OUT="$ROOT/build/li_xfer_elision_smoke"
SRC="$RT/test/li_xfer_elision_smoke.c"

CC="${CC:-clang-22}"
mkdir -p "$(dirname "$OUT")"
"$CC" -std=c11 -O2 -Wall -Wextra -D_DEFAULT_SOURCE \
  -I"$RT" \
  "$SRC" \
  "$RT/li_xfer_plan.c" \
  "$RT/li_dpar.c" \
  "$RT/li_rt_hetero.c" \
  "$RT/li_rt.c" \
  -pthread -lm \
  -o "$OUT"

LI_XFER_RDMA_GPU=1 LI_DPAR_RANK=0 LI_DPAR_WORLD_SIZE=1 "$OUT"

echo "li_xfer_elision_smoke: ok"
