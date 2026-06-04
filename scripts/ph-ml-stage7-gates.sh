#!/usr/bin/env bash
# PH-ML Stage 7 — SOTA non-pilot benches, SSE streaming prep, autograd pilot backward.
set -euo pipefail
ROOT="${PH_ML_STAGE7_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

run_in_wsl() {
  local wsl_root
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  wsl.exe bash -lc "cd '$wsl_root' && export PH_ML_STAGE7_ROOT='$wsl_root' PH_ML_STAGE7_INNER=1 && bash scripts/ph-ml-stage7-gates.sh"
}

if [[ "${PH_ML_STAGE7_INNER:-0}" != "1" ]] && command -v wsl.exe >/dev/null 2>&1; then
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  if [[ -n "$wsl_root" ]] && wsl.exe bash -lc "test -x '$wsl_root/build-wsl/compiler/lic/lic'" 2>/dev/null; then
    run_in_wsl
    exit $?
  fi
fi

export PH_ML_STAGE6_INNER=1
bash scripts/ph-ml-stage6-gates.sh

LIC="${LIC:-}"
if [[ -x "$ROOT/build-wsl/compiler/lic/lic" ]]; then
  LIC="$ROOT/build-wsl/compiler/lic/lic"
elif [[ -x "$ROOT/build/compiler/lic/lic" ]]; then
  LIC="$ROOT/build/compiler/lic/lic"
fi
[[ -x "$LIC" ]] || { echo "ph-ml-stage7-gates: build lic"; exit 1; }

grep -q 'llm_streaming_sse_prep_ok' packages/li-llm/src/lib.li \
  || { echo "7.1: missing streaming SSE prep"; exit 1; }
grep -q 'return 8' packages/li-llm/src/lib.li \
  || { echo "7.2: li_llm_version must be 8"; exit 1; }
grep -q 'ml_autograd_tape_enabled() -> int' packages/li-ml/src/lib.li \
  && grep -A6 'def ml_autograd_tape_enabled' packages/li-ml/src/lib.li | grep -q 'return 1' \
  || { echo "7.3: autograd tape must be enabled"; exit 1; }

for smoke in \
  packages/li-llm/li-tests/smoke/llm_streaming_sse_prep.li \
  packages/li-ml/li-tests/smoke/ml_autograd_stub.li; do
  [[ -f "$smoke" ]] || { echo "missing smoke: $smoke"; exit 1; }
  "$LIC" build --allow-open-vc "$smoke" -o /dev/null || { echo "lic build failed: $smoke"; exit 1; }
done

bash scripts/bench-ph-ml-lkir-matmul-32.sh
bash scripts/bench-ph-ml-mlp-train-step.sh
bash scripts/bench-ph-ml-llm-streaming-sse.sh
bash scripts/bench-ph-ml-competitive.sh

python3 - <<'PY'
import json, sys
from pathlib import Path

root = Path("benchmarks/results")
mat32 = json.loads((root / "ph-ml-lkir-matmul-32.json").read_text())
if not mat32.get("executed") or not mat32.get("validity_gate_pass"):
    sys.exit("7.4: ph-ml-lkir-matmul-32 must execute with validity_gate_pass")

train = json.loads((root / "ph-ml-mlp-train-step.json").read_text())
if train.get("autograd_mode") != "pilot_backward":
    sys.exit("7.5: autograd_mode must be pilot_backward")
if not train.get("executed"):
    sys.exit("7.5: mlp train step must execute")

sse = json.loads((root / "ph-ml-llm-streaming-sse.json").read_text())
if not sse.get("executed") or not sse.get("native_decode"):
    sys.exit("7.6: streaming SSE bench must execute with native_decode")

comp = json.loads((root / "ph-ml-competitive.json").read_text())
rows = {r.get("id"): r for r in (comp.get("rows") or [])}
for rid in ("matmul_lkir", "mlp_forward"):
    row = rows.get(rid) or {}
    wc = row.get("workload_class") or "pilot"
    if wc == "pilot":
        sys.exit(f"7.7: competitive {rid} must be tier3_cpu (non-pilot), got {wc!r}")
    li = row.get("li") or {}
    if (li.get("workload_class") or "pilot") == "pilot":
        sys.exit(f"7.7: competitive {rid} li.workload_class must not be pilot")
print("stage7 benches OK", "matmul32=", mat32.get("cpu_sec"), "sse=", sse.get("cpu_sec"))
PY

[[ -f data/goal-directed-sprints/ph-ml-stage7-streaming-prep.md ]] \
  || { echo "missing stage7 goal file"; exit 1; }
[[ -f docs/release-notes/2026-06-05-ph-ml-stage7-streaming-sota.md ]] \
  || { echo "missing stage7 release note"; exit 1; }

echo "ph-ml-stage7-streaming-sota: completion gate OK"
