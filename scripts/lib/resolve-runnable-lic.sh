#!/usr/bin/env bash
# Shared lic path resolution: prefer native build/ over stale build-wsl when both exist.
# A binary is "runnable" only if it executes (avoids GLIBC mismatch on copied WSL artifacts).
set -euo pipefail

lic_is_runnable() {
  local lic="$1"
  [[ -n "$lic" && -x "$lic" ]] || return 1
  "$lic" --version >/dev/null 2>&1
}

# Print absolute path to first runnable lic, or exit 1.
resolve_runnable_lic() {
  local root="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
  local c
  for c in \
    "$root/build/compiler/lic/lic" \
    "$root/build/compiler/lic/lic.exe" \
    "$root/build-wsl/compiler/lic/lic"; do
    if lic_is_runnable "$c"; then
      echo "$c"
      return 0
    fi
  done
  echo "resolve-runnable-lic: no runnable lic under build/ or build-wsl/" >&2
  return 1
}

# Relative path for smoke invocations from repo root (./build/...).
lic_rel_for_smokes() {
  local lic="$1"
  local root="${2:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
  case "$lic" in
    "$root/build/compiler/lic/lic") echo "./build/compiler/lic/lic" ;;
    "$root/build-wsl/compiler/lic/lic") echo "./build-wsl/compiler/lic/lic" ;;
    *) echo "$lic" ;;
  esac
}
