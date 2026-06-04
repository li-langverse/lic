#!/usr/bin/env bash
# Compatibility shim: exec-tested lic resolution for PH-ML gates (delegates to lic-bin-select).
set -euo pipefail

_lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lic-bin-select.sh
source "$_lib_dir/lic-bin-select.sh"

lic_is_runnable() {
  li_lic_is_runnable "$1"
}

lic_resolve_runnable() {
  local root="${1:-$(cd "$_lib_dir/../.." && pwd)}"
  local rel abs
  rel="$(li_pick_lic_bin "$root")" || {
    echo "lic-runnable: no runnable lic under $root or LIC_ROOT=${LIC_ROOT:-${LI_REPO_ROOT:-<unset>}}" >&2
    return 1
  }
  case "$rel" in
    ./*) abs="$root/${rel#./}" ;;
    /*) abs="$rel" ;;
    *) abs="$rel" ;;
  esac
  echo "$abs"
}
