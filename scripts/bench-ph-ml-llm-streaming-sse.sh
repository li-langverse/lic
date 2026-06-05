#!/usr/bin/env bash
# Stage 7 prep: SSE streaming decode bench (native llm_generate_tracked steps).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
OUT="${PH_ML_LLM_STREAMING_SSE_OUT:-$ROOT/benchmarks/results/ph-ml-llm-streaming-sse.json}"
# shellcheck source=lib/lic-bin-select.sh
source "$ROOT/scripts/lib/lic-bin-select.sh"
li_ensure_lic "$ROOT" "bench-ph-ml-llm-streaming-sse: build lic" || exit 1

python3 "$ROOT/scripts/prepare_ph_ml_weights_fixture.py"
SMOKE="packages/li-llm/li-tests/smoke/llm_streaming_sse_prep.li"
BIN="/tmp/ph-ml-llm-streaming-sse-$$"
COMPILE_OK=0
RUN_RC=1
CPU_SEC=""
export CC="${CC:-clang-22}" CXX="${CXX:-clang++-22}"
if "$LIC" build --allow-open-vc "$SMOKE" -o "$BIN" >/dev/null 2>&1; then
  COMPILE_OK=1
fi
if [[ "$COMPILE_OK" == "1" && -x "$BIN" ]]; then
  set +e
  "$BIN" >/dev/null 2>&1
  _warm=$?
  t0="$(python3 -c 'import time; print(time.perf_counter())')"
  "$BIN" >/dev/null 2>&1
  RUN_RC=$?
  t1="$(python3 -c 'import time; print(time.perf_counter())')"
  set -e
  CPU_SEC="$(python3 -c "print(round(float('$t1') - float('$t0'), 6))")"
fi
export PH_ML_SSE_COMPILE_OK="$COMPILE_OK" PH_ML_SSE_RUN_RC="$RUN_RC" PH_ML_SSE_CPU_SEC="${CPU_SEC:-}" PH_ML_LLM_STREAMING_SSE_OUT="$OUT"
python3 - <<'PY'
import json, os, time
from pathlib import Path

compile_ok = os.environ.get("PH_ML_SSE_COMPILE_OK") == "1"
run_rc = int(os.environ.get("PH_ML_SSE_RUN_RC", "1"))
cpu_raw = os.environ.get("PH_ML_SSE_CPU_SEC", "").strip()
cpu_sec = float(cpu_raw) if cpu_raw else None
executed = compile_ok and run_rc == 0 and cpu_sec is not None
out = Path(os.environ.get("PH_ML_LLM_STREAMING_SSE_OUT", os.environ.get("PH_ML_BENCH_ROOT", ".") + "/benchmarks/results/ph-ml-llm-streaming-sse.json"))
out.parent.mkdir(parents=True, exist_ok=True)
report = {
    "suite": "ph-ml-llm-streaming-sse",
    "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "workload_class": "tier3_cpu" if executed else "stub",
    "content_type": "text/event-stream",
    "native_decode": True,
    "live_proxy": False,
    "compile_ok": compile_ok,
    "executed": executed,
    "validity_gate_pass": executed,
    "cpu_sec": cpu_sec,
    "note": "llm_streaming_sse_prep_ok via native decode steps",
}
out.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
print(out)
PY
rm -f "$BIN"
echo "bench-ph-ml-llm-streaming-sse: done"
