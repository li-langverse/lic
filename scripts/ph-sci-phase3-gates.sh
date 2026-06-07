#!/usr/bin/env bash
# PH-SCI Phase 3 partial gate — science_gpu + MIR placement (WP-SCI-GPU-VENDOR-03).
set -euo pipefail
ROOT="${PH_SCI_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

export PH_SCI_REQUIRE_MIR_GPU=1
bash scripts/ph-sci-gpu-gates.sh

if [[ "${PH_SCI_VENDOR_LKIR:-1}" == "1" ]]; then
  export LIG_EMIT_CUDA=1
  bash scripts/lig-emit-vendor-stub.sh
  LIC="${LIC_BIN:-${LIC:-}}"
  if [[ -z "$LIC" ]] || ! "$LIC" --version &>/dev/null; then
    LIC="$("$ROOT/scripts/resolve-lic.sh")"
  fi
  export LIC
  "$LIC" build --allow-open-vc --no-lean-verify \
    packages/li-sim-scientific/li-tests/smoke/scientific_gpu_lkir_launch.li -o /dev/null
  bash scripts/bench-ph-sci-lkir-md-oracle.sh
  python3 - <<'PY'
import json, sys
from pathlib import Path
p = Path("benchmarks/results/ph-sci-lkir-md-oracle.json")
d = json.loads(p.read_text())
if not d.get("compile_ok"):
    sys.exit("ph-sci-lkir-md-oracle: compile_ok false")
if d.get("lig_emit_cuda") and not d.get("validity_gate_pass"):
    sys.exit("ph-sci-lkir-md-oracle: validity_gate_pass false (run with rebuilt lic + LIG_EMIT_CUDA=1)")
print("WP-SCI-GPU-VENDOR-01: MD LKIR bench OK")
PY
  bash scripts/bench-ph-sci-md-device-buffer.sh
  python3 - <<'PY'
import json, sys
from pathlib import Path
p = Path("benchmarks/results/ph-sci-md-device-buffer.json")
d = json.loads(p.read_text())
if not d.get("compile_ok"):
    sys.exit("ph-sci-md-device-buffer: compile_ok false")
if d.get("lig_emit_cuda") and not d.get("parity_gate_pass"):
    sys.exit("ph-sci-md-device-buffer: parity_gate_pass false")
print("WP-SCI-GPU-VENDOR-02: MD device buffer parity bench OK")
PY
fi

[[ -f data/goal-directed-sprints/ph-sci-simulation-gap-close-plan.md ]] \
  || { echo "missing sprint goal file"; exit 1; }

echo "ph-sci-simulation-gap-close: Phase 3 (GPU vendor CI gate) OK"
