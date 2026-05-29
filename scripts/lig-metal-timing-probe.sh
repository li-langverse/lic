#!/usr/bin/env bash
# WP-HW-11: Metal device matmul timing (macOS Apple Silicon only).
set -euo pipefail
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo '{"metal_device_ok": false, "metal_timing_ns": "N/A", "gpu_timing_ns": "N/A", "note": "Darwin only"}'
  exit 0
fi
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CC="${CC:-clang}"
PROBE_SRC="$ROOT/runtime/lig_metal_timing_probe.c"
cat >"$PROBE_SRC" <<'C'
#include "li_rt_lig_metal.h"
#include <stdio.h>
int main(void) {
  if (li_rt_lig_metal_matmul2x2_device() != 1) {
    return 1;
  }
  printf("%lld\n", (long long)li_rt_lig_metal_last_timing_ns());
  return 0;
}
C
"$CC" -O2 -x c "$PROBE_SRC" -x objective-c++ "$ROOT/runtime/li_rt_lig_metal.mm" \
  -I"$ROOT/runtime" -framework Metal -framework Foundation -o /tmp/lig_metal_timing_probe
if ns="$(/tmp/lig_metal_timing_probe 2>/dev/null)"; then
  python3 - <<PY
import json
ns = int("$ns")
print(json.dumps({"metal_device_ok": True, "metal_timing_ns": ns, "gpu_timing_ns": ns}))
PY
else
  echo '{"metal_device_ok": false, "metal_timing_ns": "N/A", "gpu_timing_ns": "N/A"}'
fi
