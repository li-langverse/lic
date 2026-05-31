#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LIC="${LIC:-$ROOT/build-wsl/compiler/lic/lic}"
if [[ ! -x "$LIC" && -x "$ROOT/build-wsl/compiler/lic/lic" ]]; then
  LIC="$ROOT/build-wsl/compiler/lic/lic"
fi
if [[ -z "${BENCHMARKS_RESULTS:-}" ]]; then
  if [[ -f "$ROOT/../benchmarks/harness/bench.py" ]]; then
    BENCHMARKS_RESULTS="$(cd "$ROOT/../benchmarks/results" && pwd)"
  else
    BENCHMARKS_RESULTS="$ROOT/benchmarks/results"
  fi
fi
OUT="$BENCHMARKS_RESULTS/ph-ml-llm-forward.json"
SMOKE="packages/li-llm/li-tests/smoke/llm_forward.li"
BIN="/tmp/ph-ml-llm-forward-bench"
mkdir -p "$BENCHMARKS_RESULTS"
export CC="${CC:-clang-22}" CXX="${CXX:-clang++-22}"
compile_ok=false
executed=false
validity=false
run_rc=1
cpu_sec=null
if [[ -x "$LIC" && -f "$ROOT/$SMOKE" ]]; then
  t0="$(date +%s.%N)"
  if "$LIC" build --allow-open-vc "$SMOKE" -o "$BIN" >/dev/null 2>&1; then
    compile_ok=true
    if [[ -x "$BIN" ]]; then
      executed=true
      set +e
      "$BIN"
      run_rc=$?
      set -e
      if [[ "$run_rc" -eq 0 ]]; then
        validity=true
      fi
    fi
  fi
  t1="$(date +%s.%N)"
  cpu_sec="$(python3 - <<PY
import decimal
print(round(decimal.Decimal("$t1") - decimal.Decimal("$t0"), 6))
PY
)"
fi
python3 - <<PY
import json, time
from pathlib import Path
out = Path("$OUT")
report = {
    "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "suite": "ph-ml-llm-forward",
    "workload_class": "stub",
    "compile_ok": $( [[ "$compile_ok" == true ]] && echo True || echo False ),
    "executed": $( [[ "$executed" == true ]] && echo True || echo False ),
    "validity_gate_pass": $( [[ "$validity" == true ]] && echo True || echo False ),
    "worker": "cpu_sync",
    "worker_count": 1,
    "run_exit_code": $run_rc,
}
cs = "$cpu_sec"
if cs != "null":
    report["cpu_sec"] = float(cs)
out.write_text(json.dumps(report, indent=2) + "\n")
print(out)
PY
echo "bench-ph-ml-llm-forward: done"
