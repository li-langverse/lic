#!/usr/bin/env bash
# Print path to a runnable lic (native build/ preferred over stale build-wsl/).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export RESOLVE_LIC_ROOT="$ROOT"
# shellcheck source=lib/resolve-runnable-lic.sh
source "$ROOT/scripts/lib/resolve-runnable-lic.sh"
if resolve_runnable_lic_path; then
  exit 0
fi
echo "resolve-lic: no runnable lic under build/compiler/lic/ or build-wsl/compiler/lic/" >&2
exit 1
