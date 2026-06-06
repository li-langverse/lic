#!/usr/bin/env bash
# WP-PAR-73–74 — RDMA hook registration + cluster latency bench.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RT="$ROOT/runtime"
OUT="$ROOT/build/li_comm_latency_bench"
SRC="$RT/test/li_comm_latency_bench.c"
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

LI_COMM_RDMA=1 LI_DPAR_RANK=0 LI_DPAR_WORLD_SIZE=1 "$OUT"

PORT="${LI_DPAR_PORT:-29621}"
chmod +x "$LIPAR_RUN"
LI_COMM_RDMA=1 "$LIPAR_RUN" --hosts "127.0.0.1,127.0.0.1,127.0.0.1,127.0.0.1" --world 4 --port "$PORT" -- "$OUT"

# WP-PAR-73 — RDMA hook symbol present and callable.
nm_out="$(nm "$OUT" 2>/dev/null || true)"
if [[ "$nm_out" != *"li_comm_rdma_post"* ]]; then
  echo "li_comm_latency_bench: missing li_comm_rdma_post symbol" >&2
  exit 1
fi
