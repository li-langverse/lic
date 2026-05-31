#!/usr/bin/env bash
# Completion gate: Li World Studio runnable + installer (Windows/WSL friendly).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

fail() { echo "FAIL: $*" >&2; exit 1; }
warn() { echo "WARN: $*" >&2; }

resolve_lic() {
  local c
  for c in \
    "$ROOT/build-wsl/compiler/lic/lic" \
    "$ROOT/build/compiler/lic/lic" \
    "$ROOT/build/compiler/lic/lic.exe"; do
    if [[ -f "$c" ]]; then
      echo "$c"
      return 0
    fi
  done
  if [[ -x "$ROOT/scripts/resolve-lic.sh" ]]; then
    "$ROOT/scripts/resolve-lic.sh" 2>/dev/null && return 0
  fi
  return 1
}

wsl_root_path() {
  local p="$ROOT"
  p="${p//\\//}"
  if [[ "$p" =~ ^/([a-zA-Z])/(.*)$ ]]; then
    echo "/mnt/${BASH_REMATCH[1],,}/${BASH_REMATCH[2]}"
    return
  fi
  if [[ "$p" =~ ^([A-Za-z]):/(.*)$ ]]; then
    echo "/mnt/${BASH_REMATCH[1],,}/${BASH_REMATCH[2]}"
    return
  fi
  echo "$p"
}

lic_check_smoke() {
  local smoke="$1"
  [[ -f "$ROOT/packages/li-studio/li-tests/smoke/$smoke" ]] || fail "missing smoke $smoke"
  if [[ -f "$ROOT/build-wsl/compiler/lic/lic" ]] && command -v wsl >/dev/null 2>&1; then
    local wsl_root
    wsl_root="$(wsl_root_path)"
    wsl -e bash -lc "cd '$wsl_root' && ./build-wsl/compiler/lic/lic check --no-cache packages/li-studio/li-tests/smoke/$smoke" \
      || fail "lic check $smoke (wsl)"
  elif [[ -n "${LIC:-}" && -f "$LIC" ]]; then
    "$LIC" check "$ROOT/packages/li-studio/li-tests/smoke/$smoke" || fail "lic check $smoke"
  else
    fail "lic not runnable for smoke $smoke"
  fi
}

LIC="${LIC:-}"
if ! LIC="$(resolve_lic)"; then
  fail "lic binary missing"
fi
export LIC

[[ -f "$ROOT/build/li-studio-demo" || -f "$ROOT/build/li-studio-demo.exe" ]] \
  || fail "li-studio-demo missing (run: mkdir -p build && CC=clang-22 lic build --allow-open-vc --no-lean-verify packages/li-studio/src/main.li -o build/li-studio-demo)"

lic_check_smoke studio_vertical_demo_env.li
lic_check_smoke studio_sim_step_by_profile.li

if command -v iscc >/dev/null 2>&1; then
  iscc /Qp "$ROOT/installer/LiWorldStudio.iss" || fail "iscc compile failed"
else
  warn "Inno Setup (iscc) not on PATH — skip installer compile"
fi

echo "OK world-studio-runnable-completion-gate"
