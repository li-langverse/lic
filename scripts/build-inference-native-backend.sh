#!/usr/bin/env bash
# Build Li-native inference SSE upstream (Stage 8 — replaces Python mock in test-m15-inference-live).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=llvm-env.sh
source "$ROOT/scripts/llvm-env.sh"
li_detect_compilers
export CC CXX
OUT="$ROOT/build/inference-native-backend"
mkdir -p "$ROOT/build"
RT="$ROOT/runtime"
OBJS=()
for src in \
  li_rt.c li_rt_log.c li_rt_net.c li_rt_rng.c li_rt_winsock.c \
  li_rt_tls.c li_rt_h2.c li_rt_httpd.c li_rt_llm.c li_rt_inference_sse.c; do
  obj="$ROOT/build/${src%.c}.o"
  "$CC" -O2 -I"$RT" -c "$RT/$src" -o "$obj"
  OBJS+=("$obj")
done
"$CC" -O2 -I"$RT" -o "$OUT" "$ROOT/tools/inference-native-backend.c" "${OBJS[@]}" -lpthread -lm -ldl
echo "build-inference-native-backend: ok → $OUT"
