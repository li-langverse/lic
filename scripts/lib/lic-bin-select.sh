#!/usr/bin/env bash
# Pick the first lic binary that executes on this host (build-wsl may exist but need newer glibc).
# shellcheck source=lic-runnable.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lic-runnable.sh"

li_pick_lic_bin() {
  local root="${1:?root required}"
  local abs
  abs="$(lic_resolve_runnable "$root")" || return 1
  case "$abs" in
    "$root/build/compiler/lic/lic") echo "./build/compiler/lic/lic" ;;
    "$root/build-wsl/compiler/lic/lic") echo "./build-wsl/compiler/lic/lic" ;;
    "$root/build/compiler/lic/lic.exe") echo "./build/compiler/lic/lic.exe" ;;
    *) echo "$abs" ;;
  esac
}

li_ensure_lic() {
  local root="${1:?root required}"
  local msg="${2:-build lic (./scripts/build.sh)}"
  if [[ -n "${LIC:-}" ]] && lic_is_runnable "$LIC"; then
    return 0
  fi
  LIC="$(li_pick_lic_bin "$root")" || { echo "$msg"; return 1; }
  export LIC
}
