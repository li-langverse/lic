#!/usr/bin/env bash
# Print path to built lic (handles lic vs lic.exe on Windows/Git Bash).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/resolve-lic-runnable.sh
source "$ROOT/scripts/lib/resolve-lic-runnable.sh"
resolve_lic_runnable "$ROOT"
