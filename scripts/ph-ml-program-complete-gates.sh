#!/usr/bin/env bash
# PH-ML program-complete — passes only when ALL Wave 12 deferred items are implemented.
set -euo pipefail
ROOT="${PH_ML_PROGRAM_COMPLETE_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"
# shellcheck source=lib/resolve-runnable-lic.sh
source "$ROOT/scripts/lib/resolve-runnable-lic.sh"
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
  local wsl_weights=""
  if [[ -n "${PH_ML_WEIGHTS_FIXTURE:-}" ]]; then
    wsl_weights="$(wsl.exe wslpath -u "$PH_ML_WEIGHTS_FIXTURE" 2>/dev/null | tr -d '\r\n')" || wsl_weights=""
  fi
  wsl.exe bash -lc "cd '$wsl_root' && PH_ML_PROGRAM_COMPLETE_ROOT='$wsl_root' PH_ML_PROGRAM_COMPLETE_INNER=1 LIG_EMIT_CUDA=1 BENCHMARKS_ROOT='${wsl_bench}' BENCHMARKS_RESULTS='$wsl_root/benchmarks/results' PH_ML_WEIGHTS_FIXTURE='${wsl_weights:-$wsl_root/benchmarks/fixtures/ph-ml-weights}' bash scripts/ph-ml-program-complete-gates.sh"
}

if [[ "${PH_ML_PROGRAM_COMPLETE_INNER:-0}" != "1" ]] \
  && ! lic_is_runnable "$ROOT/build/compiler/lic/lic" \
  && ! lic_is_runnable "$ROOT/build/compiler/lic/lic.exe" \
  && command -v wsl.exe >/dev/null 2>&1; then
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  if [[ -n "$wsl_root" ]] && wsl.exe bash -lc "test -x '$wsl_root/build-wsl/compiler/lic/lic'" 2>/dev/null; then
    run_in_wsl
    exit $?
  fi
fi

# shellcheck source=lib/benchmarks-env.sh
export BENCHMARKS_ALLOW_NO_HARNESS=1
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="$ROOT/benchmarks/results"
mkdir -p "$BENCHMARKS_RESULTS"
export LIG_EMIT_CUDA=1

bash scripts/ph-ml-wave13-gates.sh

grep -q 'lig_emit_vendor_lowering_ready' packages/lig/src/lib.li \
  || { echo "T1: lig missing lig_emit_vendor_lowering_ready"; exit 1; }
bash scripts/lig-emit-vendor-stub.sh
test -s build/lig-emit-vendor.ptx 2>/dev/null || test -s benchmarks/results/lig-emit-vendor-artifact.txt 2>/dev/null \
  || { echo "T1: vendor emit must produce non-empty artifact"; exit 1; }

[[ -f packages/li-ml/li-tests/smoke/ml_gpu_device_buffer.li ]] \
  || { echo "T2: missing ml_gpu_device_buffer.li smoke"; exit 1; }
grep -q 'ml_gpu_device_buffer_pipeline' packages/li-ml/src/lib.li \
  || { echo "T2: missing device buffer pipeline"; exit 1; }

grep -q 'import ml' packages/li-llm/src/lib.li \
  || { echo "T3: li-llm must use import ml"; exit 1; }
[[ -f packages/li-llm/li-tests/smoke/llm_import_ml.li ]] \
  || { echo "T3: missing llm_import_ml.li smoke"; exit 1; }

grep -q 'sim_rl_env_li_process_fork_ready' packages/li-sim/src/lib.li \
  || { echo "T4: missing sim_rl_env_li_process_fork_ready"; exit 1; }

grep -q 'stable-baselines3' scripts/requirements-ph-ml-wave12-rl.txt \
  || { echo "T5: SB3 must be a declared dependency"; exit 1; }
grep -q 'ray' scripts/requirements-ph-ml-wave12-rl.txt \
  || { echo "T5: Ray must be a declared dependency"; exit 1; }
python3 -m pip install --user --break-system-packages \
  -r scripts/requirements-ph-ml-wave12-rl.txt >/dev/null 2>&1 || true
export PYTHONPATH="$ROOT/scripts${PYTHONPATH:+:$PYTHONPATH}"
export PH_ML_SB3_VECENV_OUT="$BENCHMARKS_RESULTS/ph-ml-competitor-sb3-vecenv.json"
export PH_ML_RAY_RLLIB_OUT="$BENCHMARKS_RESULTS/ph-ml-competitor-ray-rllib.json"
python3 scripts/bench_ph_ml_competitor_sb3_vecenv.py
python3 scripts/bench_ph_ml_competitor_ray_rllib.py
export PH_ML_GATE_COMPETITOR_CHECK=sb3
python3 scripts/lib/ph_ml_gate_competitor_honesty.py
export PH_ML_GATE_COMPETITOR_CHECK=ray
python3 scripts/lib/ph_ml_gate_competitor_honesty.py

export PH_ML_MATMUL_N=32
bash scripts/bench-ph-ml-lkir-matmul-32.sh
python3 - <<'PY'
import json, sys
from pathlib import Path
p = Path("benchmarks/results/ph-ml-lkir-matmul-32.json")
if not p.is_file():
    sys.exit("T6: missing ph-ml-lkir-matmul-32.json")
d = json.loads(p.read_text())
if not d.get("executed"):
    sys.exit("T6: Li matmul-32 bench must execute")
if not d.get("validity_gate_pass"):
    sys.exit("T6: Li matmul-32 validity_gate_pass must be true")
ratio = d.get("ratio_vs_li") or d.get("best_ratio_vs_li")
if ratio is None or float(ratio) > 2.0:
    sys.exit(f"T6: ratio_vs_li must be <= 2.0 (got {ratio})")
PY

export PH_ML_WEIGHTS_FIXTURE="${PH_ML_WEIGHTS_FIXTURE:-$ROOT/benchmarks/fixtures/ph-ml-weights}"
python3 scripts/prepare_ph_ml_weights_fixture.py
[[ -f "$PH_ML_WEIGHTS_FIXTURE/model.safetensors" && -f "$PH_ML_WEIGHTS_FIXTURE/model.gguf" ]] \
  || { echo "T7: PH_ML_WEIGHTS_FIXTURE must contain model.safetensors and model.gguf"; exit 1; }
[[ -f packages/li-llm/li-tests/smoke/llm_weights_file_mmap.li ]] \
  || { echo "T7: missing llm_weights_file_mmap.li smoke"; exit 1; }
grep -q 'llm_path_is_safetensors_fixture' packages/li-llm/src/lib.li \
  || { echo "T7: missing ph-ml-weights path helpers"; exit 1; }

export PH_ML_LLM_TRUSTED_HTTPD_OUT="$BENCHMARKS_RESULTS/ph-ml-llm-trusted-httpd.json"
export PH_ML_LLM_TRUSTED_HTTPD_LIVE=1
python3 scripts/bench_ph_ml_llm_trusted_httpd.py
python3 - <<'PY'
import json, sys
from pathlib import Path
d = json.loads(Path("benchmarks/results/ph-ml-llm-trusted-httpd.json").read_text())
if not d.get("executed") or not d.get("live_proxy"):
    sys.exit("T8: trusted httpd bench must execute with live_proxy")
PY

[[ -f docs/release-notes/2026-05-31-ph-ml-program-complete.md ]] \
  || { echo "missing program-complete release note"; exit 1; }
echo "ph-ml-program-complete: ALL tranches OK"
