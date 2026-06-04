#!/usr/bin/env bash
# Pick the first lic binary that executes on this host (build-wsl may exist but need newer glibc).
li_pick_lic_bin() {
  local root="${1:?root required}"
  local lic_root="${LIC_ROOT:-${LI_REPO_ROOT:-}}"
  local search_roots=("$root")
  local sibling seen="" s cand rel
  if [[ -n "$lic_root" ]]; then
    search_roots+=("$lic_root")
  fi
  for sibling in \
    "/workspace/lic" \
    "$root/../lic" \
    "$root/../../lic" \
    "$root/../../../../../workspace/lic"; do
    if [[ -d "$sibling" ]]; then
      search_roots+=("$sibling")
    fi
  done
  for s in "${search_roots[@]}"; do
    [[ "$seen" == *"|$s|"* ]] && continue
    seen="${seen}|$s|"
    for cand in \
      "$s/build/compiler/lic/lic" \
      "$s/build-wsl/compiler/lic/lic" \
      "$s/build/compiler/lic/lic.exe"; do
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
  done
  return 1
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
