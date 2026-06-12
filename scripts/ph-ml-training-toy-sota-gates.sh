#!/usr/bin/env bash
# PH-ML training toy + SOTA sprint — Phase K minimum (XOR SGD loop).
set -euo pipefail
ROOT="${PH_ML_TRAINING_TOY_SOTA_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

run_in_wsl() {
  local wsl_root
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  wsl.exe bash -lc "cd '$wsl_root' && export PH_ML_TRAINING_TOY_SOTA_ROOT='$wsl_root' PH_ML_TRAINING_TOY_SOTA_INNER=1 && bash scripts/ph-ml-training-toy-sota-gates.sh"
}

if [[ "${PH_ML_TRAINING_TOY_SOTA_INNER:-0}" != "1" ]] \
  && [[ ! -x "$ROOT/build-wsl/compiler/lic/lic" ]] \
  && [[ ! -x "$ROOT/build/compiler/lic/lic" ]] \
  && command -v wsl.exe >/dev/null 2>&1; then
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  if [[ -n "$wsl_root" ]] && wsl.exe bash -lc "test -x '$wsl_root/build-wsl/compiler/lic/lic'" 2>/dev/null; then
    run_in_wsl
    exit $?
  fi
fi

# shellcheck source=lib/lic-bin-select.sh
source "$ROOT/scripts/lib/lic-bin-select.sh"
li_export_lic "$ROOT" || { echo "ph-ml-training-toy-sota-gates: build lic"; exit 1; }

echo "==> Phase K goal file"
[[ -f data/goal-directed-sprints/ph-ml-training-toy-sota.md ]] \
  || { echo "missing ph-ml-training-toy-sota goal file"; exit 1; }

echo "==> Phase K symbols"
grep -q 'ml_mlp_sgd_step_f32' packages/li-ml/src/lib.li \
  || { echo "missing ml_mlp_sgd_step_f32"; exit 1; }
grep -q 'ml_mlp_train_step_f32' packages/li-ml/src/lib.li \
  || { echo "missing ml_mlp_train_step_f32 (backward prerequisite)"; exit 1; }

SMOKE="packages/li-ml/li-tests/smoke/ml_mlp_xor_sgd.li"
[[ -f "$SMOKE" ]] || { echo "missing smoke: $SMOKE"; exit 1; }

echo "==> Phase K XOR SGD smoke (build + run)"
BIN="$ROOT/.build/ph-ml-training-toy-sota/ml_mlp_xor_sgd"
mkdir -p "$(dirname "$BIN")"
"$LIC" build --allow-open-vc "$SMOKE" -o "$BIN" || { echo "lic build failed: $SMOKE"; exit 1; }
"$BIN" || { echo "XOR SGD smoke failed (loss must decrease over 10 steps)"; exit 1; }

echo "ph-ml-training-toy-sota: Phase K gate OK"
