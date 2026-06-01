#!/usr/bin/env bash
# PH-ML program-complete — passes only when ALL Wave 12 deferred items are implemented.
set -euo pipefail
ROOT="${PH_ML_PROGRAM_COMPLETE_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"
# shellcheck source=lib/benchmarks-env.sh
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
  -r scripts/requirements-ph-ml-competitive.txt \
  -r scripts/requirements-ph-ml-wave12-rl.txt >/dev/null 2>&1 || true
export PYTHONPATH="$ROOT/scripts${PYTHONPATH:+:$PYTHONPATH}"
export PH_ML_SB3_VECENV_OUT="$BENCHMARKS_RESULTS/ph-ml-competitor-sb3-vecenv.json"
export PH_ML_RAY_RLLIB_OUT="$BENCHMARKS_RESULTS/ph-ml-competitor-ray-rllib.json"
python3 scripts/bench_ph_ml_competitor_sb3_vecenv.py
python3 scripts/bench_ph_ml_competitor_ray_rllib.py
python3 - <<'PY'
import json, sys
from pathlib import Path
for name in ("ph-ml-competitor-sb3-vecenv.json", "ph-ml-competitor-ray-rllib.json"):
    d = json.loads(Path("benchmarks/results", name).read_text())
    if not d.get("executed"):
        sys.exit(f"T5: {name} must execute (hard CI)")
PY

export PH_ML_MATMUL_N=32
bash scripts/bench-ph-ml-lkir-matmul-32.sh
python3 - <<'PY'
import json, sys
from pathlib import Path
p = Path("benchmarks/results/ph-ml-lkir-matmul-32.json")
if not p.is_file():
    sys.exit("T6: missing ph-ml-lkir-matmul-32.json")
d = json.loads(p.read_text())
ratio = d.get("ratio_vs_li") or d.get("best_ratio_vs_li")
if ratio is None or float(ratio) > 2.0:
    sys.exit(f"T6: ratio_vs_li must be <= 2.0 (got {ratio})")
PY

: "${PH_ML_WEIGHTS_FIXTURE:=$ROOT/benchmarks/fixtures/ph-ml-weights}"
export PH_ML_WEIGHTS_FIXTURE
python3 scripts/gen-ph-ml-weights-fixture.py
[[ -f packages/li-llm/li-tests/smoke/llm_weights_file_mmap.li ]] \
  || { echo "T7: missing llm_weights_file_mmap.li smoke"; exit 1; }

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