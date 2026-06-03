#!/usr/bin/env bash
# Pick the first lic binary that executes on this host (build-wsl may exist but need newer glibc).
lic_is_runnable() {
  local bin="$1"
  [[ -n "$bin" && -x "$bin" ]] && "$bin" --version &>/dev/null
}

li_pick_lic_bin() {
  local root="${1:?root required}"
  local lic_root="${LIC_ROOT:-${LI_REPO_ROOT:-}}"
  local cand rel

  if [[ -z "$lic_root" && -d /workspace/lic/build/compiler/lic ]]; then
    lic_root="/workspace/lic"
  fi

  if [[ -n "${LIC:-}" ]] && lic_is_runnable "$LIC"; then
    case "$LIC" in
      "$root"/*) echo "./${LIC#"$root"/}" ;;
      *) echo "$LIC" ;;
    esac
    return 0
  fi

  for cand in \
    "$root/build/compiler/lic/lic" \
    "$root/build-wsl/compiler/lic/lic" \
    "$root/build/compiler/lic/lic.exe"; do
    if lic_is_runnable "$cand"; then
      case "$cand" in
        "$root/build/compiler/lic/lic") rel="./build/compiler/lic/lic" ;;
        "$root/build-wsl/compiler/lic/lic") rel="./build-wsl/compiler/lic/lic" ;;
        *) rel="$cand" ;;
      esac
      echo "$rel"
      return 0
    fi
  done

  if [[ -n "$lic_root" ]]; then
    for cand in \
      "$lic_root/build/compiler/lic/lic" \
      "$lic_root/build-wsl/compiler/lic/lic" \
      "$lic_root/build/compiler/lic/lic.exe"; do
      if lic_is_runnable "$cand"; then
        echo "$cand"
        return 0
      fi
    done
  fi

  return 1
}

lic_resolve_runnable() {
  local root="${1:?root required}"
  local rel
  if rel="$(li_pick_lic_bin "$root")"; then
    case "$rel" in
      ./*) echo "$root/${rel#./}" ;;
      /*) echo "$rel" ;;
      *) echo "$rel" ;;
    esac
    return 0
  fi
  echo "lic-bin-select: no runnable lic under $root or LIC_ROOT=${LIC_ROOT:-${LI_REPO_ROOT:-<unset>}}" >&2
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
