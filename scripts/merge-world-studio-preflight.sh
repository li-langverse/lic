#!/usr/bin/env bash
# Full merge preflight for feat/world-studio-impl-1 → main.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"

li_banner "World Studio merge preflight"

"$ROOT/scripts/check-portable-targets.sh"
"$ROOT/scripts/verify-world-studio-binary.sh"
"$ROOT/scripts/check-world-studio-gates.sh"

li_gate_ok "merge preflight complete"
