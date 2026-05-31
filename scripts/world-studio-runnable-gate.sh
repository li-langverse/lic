#!/usr/bin/env bash
# Progress gate: Li World Studio runnable slice (Windows/WSL friendly).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

fail() { echo "FAIL: $*" >&2; exit 1; }
warn() { echo "WARN: $*" >&2; }

LIC="${LIC:-}"
for c in \
  "$ROOT/build-wsl/compiler/lic/lic" \
  "$ROOT/build/compiler/lic/lic" \
  "$ROOT/build/compiler/lic/lic.exe"; do
  if [[ -x "$c" ]]; then LIC="$c"; break; fi
done
if [[ -z "$LIC" && -x "$ROOT/scripts/resolve-lic.sh" ]]; then
  LIC="$("$ROOT/scripts/resolve-lic.sh" 2>/dev/null)" || true
fi

[[ -f "$ROOT/packages/li-studio/src/main.li" ]] || fail "li-studio main.li"
grep -q 'li-sim-sensors' "$ROOT/packages/li.toml" || fail "li-sim-sensors not in workspace members"
grep -q 'want->isFloatTy() && val->getType()->isDoubleTy()' "$ROOT/compiler/codegen/emit.cpp" || fail "emit.cpp missing f64->f32 CallProc trunc"
[[ -f "$ROOT/installer/LiWorldStudio.iss" ]] || fail "installer/LiWorldStudio.iss missing"
[[ -f "$ROOT/scripts/start-li-world-studio.ps1" ]] || fail "scripts/start-li-world-studio.ps1 missing"

lic_check_smoke() {
  local smoke="$1"
  local path="$ROOT/packages/li-studio/li-tests/smoke/$smoke"
  [[ -f "$path" ]] || fail "missing $smoke"
  if [[ -f "$ROOT/build-wsl/compiler/lic/lic" ]] && command -v wsl >/dev/null 2>&1; then
    local wsl_root=""
    if command -v wsl >/dev/null 2>&1; then
      wsl_root="$(wsl wslpath -a "$ROOT" 2>/dev/null || true)"
    fi
    if [[ -z "$wsl_root" ]]; then
      wsl_root="$(cd "$ROOT" && pwd -W 2>/dev/null | sed 's|\\|/|g' | sed 's|^|/mnt/|' | sed 's|:||' | sed 's|^/mnt/\([A-Za-z]\)|/mnt/\L\1|')"
    fi
    wsl -e bash -lc "cd '$wsl_root' && ./build-wsl/compiler/lic/lic check packages/li-studio/li-tests/smoke/$smoke" \
      || fail "lic check $smoke (wsl)"
  elif [[ -n "$LIC" && -x "$LIC" ]]; then
    "$LIC" check "$path" || fail "lic check $smoke"
  else
    warn "lic not runnable — skipping lic check smokes"
    return 0
  fi
}

if [[ -f "$ROOT/build-wsl/compiler/lic/lic" ]] || [[ -n "$LIC" && -x "$LIC" ]]; then
  lic_check_smoke studio_vertical_demo_env.li
  lic_check_smoke studio_sim_step_by_profile.li
else
  warn "lic not built — skipping lic check smokes"
fi

echo "OK world-studio-runnable-gate"
