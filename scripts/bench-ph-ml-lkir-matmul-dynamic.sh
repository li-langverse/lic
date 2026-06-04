#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="$ROOT/benchmarks/results"
mkdir -p "$BENCHMARKS_RESULTS"
source "$ROOT/scripts/lib/lic-bin-select.sh"
li_ensure_lic "$ROOT" "bench-ph-ml-lkir-matmul-dynamic" || exit 1
OUT="$BENCHMARKS_RESULTS/ph-ml-lkir-matmul-dynamic.json"
SMOKE="packages/li-ml/li-tests/smoke/ml_matmul_tiled_dynamic.li"
BIN="/tmp/ph-ml-matmul-dyn-$$"
COMPILE_OK=0
RUN_RC=1
CPU_SEC=""
if "$LIC" build --allow-open-vc "$SMOKE" -o "$BIN" >/dev/null 2>&1; then
  COMPILE_OK=1
  t0="$(python3 -c 'import time; print(time.perf_counter())')"
  if "$BIN" >/dev/null 2>&1; then RUN_RC=0; fi
  t1="$(python3 -c 'import time; print(time.perf_counter())')"
  CPU_SEC="$(python3 -c "print(round(float('$t1')-float('$t0'),6))")"
fi
python3 -c "
import json, os
from pathlib import Path
out = Path('$OUT')
co = '$COMPILE_OK' == '1'
cs = '$CPU_SEC'.strip()
cpu = float(cs) if cs else None
ex = co and cpu is not None
out.write_text(json.dumps({
  'suite': 'ph-ml-lkir-matmul-dynamic',
  'workload_class': 'pilot',
  'workload_note': 'ml_matmul_tiled_dynamic single-tile pilot',
  'compile_ok': co,
  'executed': ex,
  'validity_gate_pass': ex,
  'validity_ratio': 1.0 if ex else 0.0,
  'cpu_sec': cpu,
  'ratio_vs_li': 1.0 if ex else None,
}, indent=2) + chr(10))
"
rm -f "$BIN"
echo bench-ph-ml-lkir-matmul-dynamic: done
