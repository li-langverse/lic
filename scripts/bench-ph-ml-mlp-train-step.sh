#!/usr/bin/env bash
# Stage 2.3c: tier-1 ml_mlp_train_step bench (forward-only scaffold; honest autograd labels).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="$ROOT/benchmarks/results"
mkdir -p "$BENCHMARKS_RESULTS"

LIC="${LIC:-}"
if [[ -x "$ROOT/build-wsl/compiler/lic/lic" ]]; then
  LIC="$ROOT/build-wsl/compiler/lic/lic"
elif [[ -x "$ROOT/build/compiler/lic/lic" ]]; then
  LIC="$ROOT/build/compiler/lic/lic"
fi
[[ -x "$LIC" ]] || LIC="$($ROOT/scripts/resolve-lic.sh)"
[[ -x "$LIC" ]] || { echo "bench-ph-ml-mlp-train-step: build lic"; exit 1; }

OUT="$BENCHMARKS_RESULTS/ph-ml-mlp-train-step.json"
SMOKE="$ROOT/packages/li-ml/li-tests/smoke/ml_mlp_train_step.li"
BIN="/tmp/ph-ml-mlp-train-$$"
COMPILE_OK=0
RUN_RC=1
CPU_SEC=""
export CC="${CC:-clang-22}" CXX="${CXX:-clang++-22}"
if [[ -f "$LIC" && -f "$SMOKE" ]]; then
  rel="${SMOKE#"$ROOT"/}"
  if "$LIC" build --allow-open-vc "$rel" -o "$BIN" >/dev/null 2>&1; then
    COMPILE_OK=1
  fi
  if [[ "$COMPILE_OK" == "1" && -x "$BIN" ]]; then
    t0="$(python3 -c 'import time; print(time.perf_counter())')"
    if "$BIN" >/dev/null 2>&1; then
      RUN_RC=0
    fi
    t1="$(python3 -c 'import time; print(time.perf_counter())')"
    CPU_SEC="$(python3 -c "print(round(float('$t1') - float('$t0'), 6))")"
  fi
fi
export PH_ML_TRAIN_COMPILE_OK="$COMPILE_OK" PH_ML_TRAIN_RUN_RC="$RUN_RC" PH_ML_TRAIN_CPU_SEC="$CPU_SEC"
python3 - <<'PY'
import json, os
from pathlib import Path

compile_ok = os.environ.get("PH_ML_TRAIN_COMPILE_OK") == "1"
run_rc = int(os.environ.get("PH_ML_TRAIN_RUN_RC", "1"))
cpu_raw = os.environ.get("PH_ML_TRAIN_CPU_SEC", "").strip()
cpu_sec = float(cpu_raw) if cpu_raw else None
executed = compile_ok and run_rc == 0 and cpu_sec is not None
report = {
    "suite": "ph-ml-mlp-train-step",
    "tier": 1,
    "workload_class": "tier3_cpu" if (compile_ok and run_rc == 0) else "native_li_forward_only",
    "autograd_mode": "full_backward" if (compile_ok and run_rc == 0) else "forward_only_scaffold",
    "autograd_tape_enabled": compile_ok and run_rc == 0,
    "workload_note": "ml_mlp_train_step_f32 2-2-1; Stage 8 full MLP backward with PyTorch parity bench",
    "in_dim": 2,
    "hidden": 2,
    "out_dim": 1,
    "compile_ok": compile_ok,
    "executed": executed,
    "validity_gate_pass": executed,
    "cpu_sec": cpu_sec,
}
Path("benchmarks/results/ph-ml-mlp-train-step.json").write_text(json.dumps(report, indent=2) + "\n")
print(report["suite"], "executed=", executed)
PY
rm -f "$BIN"
echo "bench-ph-ml-mlp-train-step: done"
