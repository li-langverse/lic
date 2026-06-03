#!/usr/bin/env bash
# Print path to built lic (prefers runnable binary on this host).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/lic-bin-select.sh
source "$ROOT/scripts/lib/lic-bin-select.sh"
if lic="$(li_pick_lic_bin "$ROOT")"; then
  case "$lic" in
    ./*) echo "$ROOT/${lic#./}" ;;
    *) echo "$lic" ;;
  esac
  exit 0
fi
echo "resolve-lic: no runnable lic under build/, build-wsl/, or LIC_ROOT siblings" >&2
exit 1
