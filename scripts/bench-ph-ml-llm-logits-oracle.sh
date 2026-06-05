#!/usr/bin/env bash
# Stage 8: reference logits oracle parity smoke bench.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
OUT="${PH_ML_LLM_LOGITS_ORACLE_OUT:-$ROOT/benchmarks/results/ph-ml-llm-logits-oracle.json}"
LIC="${LIC:-}"
if [[ -x "$ROOT/build-wsl/compiler/lic/lic" ]]; then
  LIC="$ROOT/build-wsl/compiler/lic/lic"
elif [[ -x "$ROOT/build/compiler/lic/lic" ]]; then
  LIC="$ROOT/build/compiler/lic/lic"
fi
[[ -x "$LIC" ]] || { echo "bench-ph-ml-llm-logits-oracle: build lic"; exit 1; }

python3 "$ROOT/scripts/prepare_ph_ml_weights_fixture.py"
SMOKE="packages/li-llm/li-tests/smoke/llm_logits_oracle_parity.li"
BIN="/tmp/ph-ml-llm-logits-oracle-$$"
COMPILE_OK=0
RUN_RC=1
TOP_ID=""
export CC="${CC:-clang-22}" CXX="${CXX:-clang++-22}"
if "$LIC" build --allow-open-vc "$SMOKE" -o "$BIN" >/dev/null 2>&1; then
  COMPILE_OK=1
fi
if [[ "$COMPILE_OK" == "1" && -x "$BIN" ]]; then
  if "$BIN" >/dev/null 2>&1; then
    RUN_RC=0
  fi
fi
export PH_ML_LOGITS_COMPILE_OK="$COMPILE_OK" PH_ML_LOGITS_RUN_RC="$RUN_RC" PH_ML_LLM_LOGITS_ORACLE_OUT="$OUT"
python3 - <<'PY'
import json, os, time
from pathlib import Path

compile_ok = os.environ.get("PH_ML_LOGITS_COMPILE_OK") == "1"
run_rc = int(os.environ.get("PH_ML_LOGITS_RUN_RC", "1"))
executed = compile_ok and run_rc == 0
out = Path(os.environ["PH_ML_LLM_LOGITS_ORACLE_OUT"])
out.parent.mkdir(parents=True, exist_ok=True)
report = {
    "suite": "ph-ml-llm-logits-oracle",
    "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "workload_class": "tier3_cpu" if executed else "stub",
    "oracle_fixture": "fixtures/ph-ml-weights/model.safetensors",
    "prompt": "ab",
    "ulp_smoke": True,
    "compile_ok": compile_ok,
    "executed": executed,
    "validity_gate_pass": executed,
    "note": "llm_logits_oracle_parity_ok deterministic top_id smoke",
}
out.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
print(out)
PY
rm -f "$BIN"
echo "bench-ph-ml-llm-logits-oracle: done"
