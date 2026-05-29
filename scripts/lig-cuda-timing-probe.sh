#!/usr/bin/env bash
# WP-HW-08/09: device matmul timing probe (honest ns when libcuda + GPU present).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CC="${CC:-clang}"
PROBE_SRC="$ROOT/runtime/lig_cuda_timing_probe_main.c"
"$CC" -O2 -x c "$PROBE_SRC" -x c "$ROOT/runtime/li_rt_lig_cuda.c" -I"$ROOT/runtime" -ldl -o /tmp/lig_cuda_timing_probe
if ns="$(/tmp/lig_cuda_timing_probe 2>/dev/null)"; then
  if ! python3 - <<PY
ns = int("$ns")
assert ns > 0, "cuda timing must be positive when device ok"
print(__import__("json").dumps({"cuda_device_ok": True, "cuda_timing_ns": ns, "gpu_timing_ns": ns}))
PY
  then
    echo '{"cuda_device_ok": false, "cuda_timing_ns": "N/A", "gpu_timing_ns": "N/A"}'
    exit 0
  fi
else
  echo '{"cuda_device_ok": false, "cuda_timing_ns": "N/A", "gpu_timing_ns": "N/A"}'
  exit 0
fi
