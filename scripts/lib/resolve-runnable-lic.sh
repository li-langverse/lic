#!/usr/bin/env bash
# Shared helpers: pick a lic binary that actually runs (--version succeeds).
# Prefer native build/ over build-wsl/ when the latter is present but linked against
# a newer glibc (common on Linux CI agents with a stale WSL artifact checkout).
set -euo pipefail

lic_runnable() {
  local bin="$1"
  [[ -n "$bin" && ( -f "$bin" || -x "$bin" ) ]] || return 1
  "$bin" --version >/dev/null 2>&1
}

# resolve_runnable_lic_path — print absolute path to first runnable candidate.
resolve_runnable_lic_path() {
  local root="${RESOLVE_LIC_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
  local candidate
  for candidate in \
    "$root/build/compiler/lic/lic" \
    "$root/build/compiler/lic/lic.exe" \
    "$root/build-wsl/compiler/lic/lic"; do
    if lic_runnable "$candidate"; then
      echo "$candidate"
      return 0
    fi
  done
  return 1
}
