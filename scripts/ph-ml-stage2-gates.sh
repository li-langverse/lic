#!/usr/bin/env bash
# PH-ML Stage 2 — Native DL spine (2.1 matmul/LKIR, 2.2 MLP, 2.3 autograd scaffold).
set -euo pipefail
ROOT="${PH_ML_STAGE2_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

run_in_wsl() {
  local wsl_root
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  wsl.exe bash -lc "cd '$wsl_root' && export PH_ML_STAGE2_ROOT='$wsl_root' PH_ML_STAGE2_INNER=1 LIG_EMIT_CUDA=1 && bash scripts/ph-ml-stage2-gates.sh"
}

if [[ "${PH_ML_STAGE2_INNER:-0}" != "1" ]] && [[ ! -x "$ROOT/build/compiler/lic/lic" && ! -x "$ROOT/build/compiler/lic/lic.exe" ]] && command -v wsl.exe >/dev/null 2>&1; then
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  if [[ -n "$wsl_root" ]] && wsl.exe bash -lc "test -x '$wsl_root/build-wsl/compiler/lic/lic'" 2>/dev/null; then
    run_in_wsl
    exit $?
  fi
fi

export BENCHMARKS_ALLOW_NO_HARNESS=1
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="$ROOT/benchmarks/results"
mkdir -p "$BENCHMARKS_RESULTS"
export LIG_EMIT_CUDA=1

LIC="${LIC:-}"
if [[ -x "$ROOT/build-wsl/compiler/lic/lic" ]]; then
  LIC="$ROOT/build-wsl/compiler/lic/lic"
elif [[ -x "$ROOT/build/compiler/lic/lic" ]]; then
  LIC="$ROOT/build/compiler/lic/lic"
elif [[ -x "$ROOT/build/compiler/lic/lic.exe" ]]; then
  LIC="$ROOT/build/compiler/lic/lic.exe"
fi
[[ -x "$LIC" ]] || { echo "ph-ml-stage2-gates: build lic (./scripts/build.sh --build-dir build-wsl in WSL)"; exit 1; }

bash scripts/ph-ml-program-complete-gates.sh

grep -q 'while t < 32' packages/li-ml/src/lib.li \
  || { echo "2.1: missing 32-tile LKIR matmul prologue"; exit 1; }
grep -q 'ml_gpu_mlp_lkir_progress' packages/li-ml/src/lib.li \
  || { echo "2.1: missing MLP device buffer progress"; exit 1; }
grep -q 'ml_mlp_train_step_f32' packages/li-ml/src/lib.li \
  || { echo "2.3: missing ml_mlp_train_step_f32"; exit 1; }

for smoke in \
  packages/li-ml/li-tests/smoke/ml_matmul_32_lkir.li \
  packages/li-ml/li-tests/smoke/ml_mlp_forward.li \
  packages/li-ml/li-tests/smoke/ml_autograd_stub.li \
  packages/li-ml/li-tests/smoke/ml_mlp_train_step.li; do
  [[ -f "$smoke" ]] || { echo "missing smoke: $smoke"; exit 1; }
  "$LIC" build --allow-open-vc "$smoke" -o /dev/null || { echo "lic build failed: $smoke"; exit 1; }
done

export PH_ML_MATMUL_N=32
bash scripts/bench-ph-ml-lkir-matmul-32.sh
bash scripts/bench-ph-ml-mlp-competitive.sh
bash scripts/bench-ph-ml-mlp-train-step.sh

python3 - <<'PY'
import json, sys
from pathlib import Path

def need(path, key, label):
    p = Path(path)
    if not p.is_file():
        sys.exit(f"missing {label}: {path}")
    d = json.loads(p.read_text())
    if not d.get(key):
        sys.exit(f"{label}: {key} must be true")
    return d

matmul = need("benchmarks/results/ph-ml-lkir-matmul-32.json", "executed", "2.1 matmul-32")
mlp = need("benchmarks/results/ph-ml-mlp-competitive.json", "executed", "2.2 mlp-competitive")
train = need("benchmarks/results/ph-ml-mlp-train-step.json", "executed", "2.3 train-step")
if train.get("autograd_mode") != "forward_only_scaffold":
    sys.exit("2.3: autograd_mode must be forward_only_scaffold")
ratio = matmul.get("ratio_vs_li")
if ratio is None or float(ratio) > 2.0:
    sys.exit(f"2.1: matmul ratio_vs_li must be <= 2.0 (got {ratio})")
mlp_ratio = mlp.get("ratio_vs_li")
if mlp_ratio is not None and float(mlp_ratio) > 50.0:
    sys.exit(f"2.2: mlp ratio_vs_li sanity cap failed ({mlp_ratio})")
print("stage2 benches OK", "matmul_ratio=", ratio, "mlp_ratio=", mlp_ratio)
PY

[[ -f data/goal-directed-sprints/ph-ml-stage2-dl-spine.md ]] \
  || { echo "missing stage2 goal file"; exit 1; }
[[ -f docs/release-notes/2026-06-04-ph-ml-stage2-dl-spine.md ]] \
  || { echo "missing stage2 release note"; exit 1; }
[[ -f docs/game-dev/specs/ml-autograd-forward-tape-rfc.md ]] \
  || { echo "missing autograd RFC"; exit 1; }
grep -q 'Native DL spine' docs/game-dev/PH-ML-GPU-battle-plan.md \
  || { echo "battle plan missing Stage 2 row"; exit 1; }
grep -q 'WP-ML-22' docs/game-dev/PH-ML-GPU-execution-tracker.md \
  || { echo "tracker missing Stage 2 WPs"; exit 1; }

echo "ph-ml-stage2-dl-spine: completion gate OK"
