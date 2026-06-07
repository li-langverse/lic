#!/usr/bin/env bash
# WP-PAR-60–65 — federated learning hardening smoke (partial ranks, stragglers, compressed halos).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RT="$ROOT/runtime"
OUT="$ROOT/build/li_fl_smoke"
SRC="$RT/test/li_fl_smoke.c"
LIPAR_RUN="$ROOT/packages/li-parallel/scripts/lipar-run.sh"

CC="${CC:-clang-22}"
mkdir -p "$(dirname "$OUT")"
"$CC" -std=c11 -O2 -Wall -Wextra -D_DEFAULT_SOURCE \
  -I"$RT" \
  "$SRC" \
  "$RT/li_dpar.c" \
  "$RT/li_fl.c" \
  -pthread -lm \
  -o "$OUT"

LI_DPAR_RANK=0 LI_DPAR_WORLD_SIZE=1 "$OUT"

# shellcheck source=scripts/lib/pick-dpar-port.sh
source "$ROOT/scripts/lib/pick-dpar-port.sh"
PORT="$(pick_dpar_port)"
chmod +x "$LIPAR_RUN"
LI_FL_STRAGGLER_RANK=2 "$LIPAR_RUN" --hosts "127.0.0.1,127.0.0.1,127.0.0.1,127.0.0.1" --world 4 --port "$PORT" -- "$OUT"
