#!/usr/bin/env bash
# Print path to built lic (prefers runnable binary on this host).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/lic-bin-select.sh
source "$ROOT/scripts/lib/lic-bin-select.sh"
for root in "${LIC_ROOT:-}" "${LI_REPO_ROOT:-}" "$ROOT" "$ROOT/../lic" "/workspace/lic"; do
  [[ -n "$root" ]] || continue
  [[ -d "$root" ]] || continue
  root="$(cd "$root" && pwd)"
  if lic="$(li_pick_lic_bin "$root")"; then
    case "$lic" in
      ./*) echo "$root/${lic#./}" ;;
      *) echo "$lic" ;;
    esac
    exit 0
  fi
done
echo "resolve-lic: no runnable lic under build/ or build-wsl/ (set LIC_ROOT or run ./scripts/build.sh)" >&2
exit 1
