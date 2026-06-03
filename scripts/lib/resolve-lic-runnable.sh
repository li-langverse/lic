#!/usr/bin/env bash
# Pick a lic binary that executes on this host (build-wsl may require newer GLIBC).
set -euo pipefail

lic_runnable() {
  [[ -x "$1" ]] && "$1" --version >/dev/null 2>&1
}

resolve_lic_runnable() {
  local root="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
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
  echo "resolve-lic-runnable: no runnable lic under build/ or build-wsl/ (run ./scripts/build.sh)" >&2
  return 1
}
