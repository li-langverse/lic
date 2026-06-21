#!/usr/bin/env bash
# Stage 2.2: native Li MLP forward vs NumPy — same 2-2-1 f32 dims/FLOPs as competitor driver.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="${PH_ML_BENCHMARKS_RESULTS:-$ROOT/benchmarks/results}"
mkdir -p "$BENCHMARKS_RESULTS"

run_in_wsl() {
  local wsl_root wsl_bench
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  wsl_bench=""
  if [[ -n "${BENCHMARKS_ROOT:-}" ]]; then
    wsl_bench="$(wsl.exe wslpath -u "$BENCHMARKS_ROOT" 2>/dev/null | tr -d '\r\n')" || wsl_bench=""
  fi
  if [[ -z "$wsl_bench" ]]; then
    for _c in "$ROOT/../benchmarks" "$ROOT/../../benchmarks" "$ROOT/../../../../../benchmarks"; do
      if [[ -f "$_c/harness/bench.py" ]]; then
        wsl_bench="$(wsl.exe wslpath -u "$(cd "$_c" && pwd)" 2>/dev/null | tr -d '\r\n')" || wsl_bench=""
        break
      fi
    done
  fi
  wsl.exe bash -lc "cd '$wsl_root' && export PH_ML_MLP_COMP_INNER=1 BENCHMARKS_ROOT='${wsl_bench}' LIC=./build-wsl/compiler/lic/lic CC=clang-22 CXX=clang++-22 && bash scripts/bench-ph-ml-mlp-competitive.sh"
}

if [[ "${PH_ML_MLP_COMP_INNER:-0}" != "1" ]] \
  && [[ ! -x "$ROOT/build/compiler/lic/lic" && ! -x "$ROOT/build/compiler/lic/lic.exe" ]] \
  && command -v wsl.exe >/dev/null 2>&1; then
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  if [[ -n "$wsl_root" ]] && wsl.exe bash -lc "test -x '$wsl_root/build-wsl/compiler/lic/lic'" 2>/dev/null; then
    run_in_wsl
    exit $?
  fi
fi

# shellcheck source=lib/lic-bin-select.sh
source "$ROOT/scripts/lib/lic-bin-select.sh"
li_export_lic "$ROOT" || { echo "bench-ph-ml-mlp-competitive: no runnable lic"; exit 1; }

bash "$ROOT/scripts/bench-ph-ml-mlp-forward.sh"
export PH_ML_NUMPY_MLP_OUT="$BENCHMARKS_RESULTS/ph-ml-competitor-numpy-mlp.json"
export PYTHONPATH="$ROOT/scripts${PYTHONPATH:+:$PYTHONPATH}"
python3 "$ROOT/scripts/bench_ph_ml_competitor_numpy_mlp.py"

python3 - <<'PY'
import json
from pathlib import Path

root = Path(".")
li_p = root / "benchmarks/results/ph-ml-mlp-forward.json"
np_p = root / "benchmarks/results/ph-ml-competitor-numpy-mlp.json"
out_p = root / "benchmarks/results/ph-ml-mlp-competitive.json"
li_d = json.loads(li_p.read_text()) if li_p.is_file() else {}
np_d = json.loads(np_p.read_text()) if np_p.is_file() else {}
li_sec = li_d.get("cpu_sec")
np_sec = np_d.get("cpu_sec")
ratio = None
if li_sec and np_sec and float(li_sec) > 0:
    ratio = round(float(np_sec) / float(li_sec), 6)
report = {
    "suite": "ph-ml-mlp-competitive",
    "workload_class": "native_li_mlp_forward",
    "workload_note": "mlp_forward_2_2_1_f32 — matches bench_ph_ml_competitor_numpy_mlp.py",
    "in_dim": 2,
    "hidden": 2,
    "out_dim": 1,
    "executed": bool(li_d.get("executed")),
    "validity_gate_pass": bool(li_d.get("validity_gate_pass")),
    "li_cpu_sec": li_sec,
    "numpy_cpu_sec": np_sec,
    "ratio_vs_li": ratio,
    "tier": 1,
}
out_p.write_text(json.dumps(report, indent=2) + "\n")
print(out_p)
PY
echo "bench-ph-ml-mlp-competitive: done"
