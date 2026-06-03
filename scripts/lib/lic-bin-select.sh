#!/usr/bin/env bash
# Pick the first lic binary that executes on this host (build-wsl may exist but need newer glibc).
li_pick_lic_bin() {
  local root="${1:?root required}"
  local lic_root="${LIC_ROOT:-${LI_REPO_ROOT:-}}"
  local cand rel
  for cand in \
    "$root/build/compiler/lic/lic" \
    "$root/build-wsl/compiler/lic/lic" \
    "$root/build/compiler/lic/lic.exe"; do
    if [[ -x "$cand" ]] && "$cand" --version &>/dev/null; then
      case "$cand" in
        "$root/build/compiler/lic/lic") rel="./build/compiler/lic/lic" ;;
        "$root/build-wsl/compiler/lic/lic") rel="./build-wsl/compiler/lic/lic" ;;
        *) rel="$cand" ;;
      esac
      echo "$rel"
      return 0
    fi
  done
  if [[ -n "$lic_root" && "$lic_root" != "$root" ]]; then
    for cand in \
      "$lic_root/build/compiler/lic/lic" \
      "$lic_root/build-wsl/compiler/lic/lic" \
      "$lic_root/build/compiler/lic/lic.exe"; do
      if [[ -x "$cand" ]] && "$cand" --version &>/dev/null; then
        echo "$cand"
        return 0
      fi
    done
  fi
  return 1
}

li_has_runnable_lic() {
  local root="${1:?root required}"
  if [[ -n "${LIC:-}" ]] && "$LIC" --version &>/dev/null; then
    return 0
  fi
  li_pick_lic_bin "$root" >/dev/null 2>&1
}

li_ensure_lic() {
  local root="${1:?root required}"
  local msg="${2:-build lic (./scripts/build.sh)}"
  if [[ -n "${LIC:-}" ]] && "$LIC" --version &>/dev/null; then
    return 0
  fi
  # shellcheck disable=SC1091
  source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lic-bin-select.sh"
  LIC="$(li_pick_lic_bin "$root")" || { echo "$msg"; return 1; }
  export LIC
}
