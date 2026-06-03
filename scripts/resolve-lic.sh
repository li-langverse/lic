#!/usr/bin/env bash
# Print path to built lic (handles lic vs lic.exe on Windows/Git Bash).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/resolve-runnable-lic.sh
source "$ROOT/scripts/lib/resolve-runnable-lic.sh"
resolve_runnable_lic "$ROOT"
