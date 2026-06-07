#!/usr/bin/env bash
# PH-ML li-array completion gates — strict-shape array package + ml bridge smokes.
set -euo pipefail
ROOT="${PH_ML_LI_ARRAY_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

run_in_wsl() {
  local wsl_root
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  wsl.exe bash -lc "cd '$wsl_root' && export PH_ML_LI_ARRAY_ROOT='$wsl_root' PH_ML_LI_ARRAY_INNER=1 LIC=./build-wsl/compiler/lic/lic source scripts/ph-ml-li-array-gates.sh"
}

lic_check_smokes() {
  local lic smoke rc i bin
  if [[ -x "./build-wsl/compiler/lic/lic" ]]; then
    lic="./build-wsl/compiler/lic/lic"
  else
    lic="${1:?lic required}"
  fi
  unset CC CXX
  local compile_smokes=(
    packages/li-array/li-tests/smoke/builds.li
    packages/li-array/li-tests/smoke/array_add_same_shape.li
    packages/li-array/li-tests/smoke/array_sum_1d.li
    packages/li-array/li-tests/smoke/array_matmul_4.li
    packages/li-array/li-tests/smoke/array_shape_strict_reject.li
  )
  local run_smokes=(
    packages/li-array/li-tests/smoke/builds.li
    packages/li-array/li-tests/smoke/array_gate_run.li
  )
  for smoke in "${compile_smokes[@]}"; do
    [[ -f "$smoke" ]] || { echo "missing smoke: $smoke"; return 1; }
    bin="/tmp/ph-ml-li-array-compile-$$-${RANDOM}"
    set +e
    "$lic" build --allow-open-vc "$smoke" -o "$bin" 2>&1
    rc=$?
    set -e
    if [[ "$rc" -ne 0 ]]; then
      echo "lic build failed: $smoke (exit $rc)"
      return 1
    fi
    rm -f "$bin"
  done
  i=0
  for smoke in "${run_smokes[@]}"; do
    i=$((i + 1))
    bin="/tmp/ph-ml-li-array-run-${i}-$$"
    "$lic" build --allow-open-vc "$smoke" -o "$bin" 2>&1
    set +e
    "$bin" >/dev/null 2>&1
    rc=$?
    set -e
    if [[ "$rc" -ne 0 ]]; then
      echo "lic run failed: $smoke (exit $rc)"
      return 1
    fi
    rm -f "$bin"
  done
}

if [[ "${PH_ML_LI_ARRAY_INNER:-0}" != "1" ]] && [[ ! -x "$ROOT/build/compiler/lic/lic" && ! -x "$ROOT/build/compiler/lic/lic.exe" ]] && command -v wsl.exe >/dev/null 2>&1; then
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  if [[ -n "$wsl_root" ]] && wsl.exe bash -lc "test -x '$wsl_root/build-wsl/compiler/lic/lic'" 2>/dev/null; then
    run_in_wsl
    exit $?
  fi
fi

if [[ -x "./build-wsl/compiler/lic/lic" ]] && "./build-wsl/compiler/lic/lic" --version &>/dev/null; then
  export LIC="./build-wsl/compiler/lic/lic"
else
  # shellcheck source=lib/lic-bin-select.sh
  source "$ROOT/scripts/lib/lic-bin-select.sh"
  if [[ -n "${LIC:-}" ]] && "$LIC" --version &>/dev/null; then
    :
  elif li_export_lic "$ROOT"; then
    :
  else
    li_ensure_lic "$ROOT" "ph-ml-li-array-gates: build lic (./scripts/build.sh or --build-dir build-wsl in WSL)" || exit 1
  fi
fi

[[ -f docs/game-dev/specs/li-array-rfc.md ]] || { echo "missing li-array RFC"; exit 1; }
[[ -f data/goal-directed-sprints/ph-ml-li-array-competitive.md ]] || { echo "missing li-array goal file"; exit 1; }
grep -q 'array_shape_equal' packages/li-array/src/lib.li || { echo "li-array missing strict shape check"; exit 1; }
grep -q 'array_matmul' packages/li-array/src/lib.li || { echo "li-array missing array_matmul"; exit 1; }
grep -q 'ml_tensor_matmul_64' packages/li-array/src/lib.li || { echo "li-array missing ml bridge"; exit 1; }
grep -q 'ml_array_add_n' packages/li-ml/src/lib.li || { echo "li-ml missing ml_array_add_n bridge"; exit 1; }
grep -q 'No silent' docs/game-dev/specs/li-array-rfc.md || { echo "RFC must document no silent broadcasting"; exit 1; }
grep -q 'li-array' packages/li.toml || { echo "li-array not in workspace members"; exit 1; }

lic_check_smokes "$LIC" || exit 1

echo "ph-ml-li-array: Phase A completion gate OK"
