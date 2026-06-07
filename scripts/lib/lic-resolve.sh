#!/usr/bin/env bash
# Back-compat aliases for PH-ML gates — prefer scripts/lib/lic-bin-select.sh.
set -euo pipefail

# shellcheck source=lic-bin-select.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lic-bin-select.sh"

lic_is_runnable() { li_lic_runnable "$@"; }
lic_is_wsl() { li_is_wsl; }
lic_resolve_bin() {
  local root="${1:-${ROOT:-}}"
  [[ -n "$root" ]] || return 1
  local rel
  rel="$(li_pick_lic_bin "$root")" || return 1
  case "$rel" in
    ./*) echo "$root/${rel#./}" ;;
    *) echo "$rel" ;;
  esac
}
lic_ensure_native() { li_ensure_native_lic "$@"; }
