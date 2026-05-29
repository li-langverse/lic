#!/usr/bin/env bash
# WP-HW-08/09: device matmul timing probe (honest ns when libcuda + GPU present).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CC="${CC:-clang}"
PROBE_SRC="$ROOT/runtime/lig_cuda_timing_probe.c"
cat >"$PROBE_SRC" <<'C'
#include "li_rt_lig_cuda.h"
#include <stdio.h>
int main(void) {
  if (li_rt_lig_cuda_matmul2x2_device() != 1) {
    return 1;
  }
  printf("%lld\n", (long long)li_rt_lig_cuda_last_timing_ns());
  return 0;
}
C
"$CC" -O2 -x c "$PROBE_SRC" -x c "$ROOT/runtime/li_rt_lig_cuda.c" -I"$ROOT/runtime" -ldl -o /tmp/lig_cuda_timing_probe
if ns="$(/tmp/lig_cuda_timing_probe 2>/dev/null)"; then
  python3 - <<PY
import json
ns = int("$ns")
print(json.dumps({"cuda_device_ok": True, "cuda_timing_ns": ns, "gpu_timing_ns": ns}))
PY
else
  echo '{"cuda_device_ok": false, "cuda_timing_ns": "N/A", "gpu_timing_ns": "N/A"}'
  exit 0
fi
