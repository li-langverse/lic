#!/usr/bin/env bash
# Pick the first lic binary that executes on this host (build-wsl may exist but need newer glibc).
li_lic_is_runnable() {
  local cand="$1"
  [[ -n "$cand" && -x "$cand" ]] && "$cand" --version &>/dev/null
}

li_pick_lic_bin() {
  local root="${1:?root required}"
  local cand rel lic_root
  local -a search_roots=()

  if [[ -n "${LIC:-}" ]] && li_lic_is_runnable "$LIC"; then
    case "$LIC" in
      "$root"/*) rel="./${LIC#"$root"/}" ;;
      ./*|/*) rel="$LIC" ;;
      *) rel="$LIC" ;;
    esac
    echo "$rel"
    return 0
  fi

  search_roots+=("$root")
  if [[ -n "${LIC_ROOT:-${LI_REPO_ROOT:-}}" ]]; then
    search_roots+=("$(cd "${LIC_ROOT:-$LI_REPO_ROOT}" && pwd)")
  fi
  for lic_root in "$root/../lic" "$root/../../lic" "/workspace/lic"; do
    [[ -d "$lic_root" ]] || continue
    search_roots+=("$(cd "$lic_root" && pwd)")
  done

  for lic_root in "${search_roots[@]}"; do
    for cand in \
      "$lic_root/build/compiler/lic/lic" \
      "$lic_root/build-wsl/compiler/lic/lic" \
      "$lic_root/build/compiler/lic/lic.exe"; do
      if li_lic_is_runnable "$cand"; then
        case "$cand" in
          "$root/build/compiler/lic/lic") rel="./build/compiler/lic/lic" ;;
          "$root/build-wsl/compiler/lic/lic") rel="./build-wsl/compiler/lic/lic" ;;
          "$root/build/compiler/lic/lic.exe") rel="./build/compiler/lic/lic.exe" ;;
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
  if [[ -n "${LIC:-}" ]] && li_lic_is_runnable "$LIC"; then
    return 0
  fi
  # shellcheck disable=SC1091
  source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lic-bin-select.sh"
  LIC="$(li_pick_lic_bin "$root")" || { echo "$msg"; return 1; }
  export LIC
}
