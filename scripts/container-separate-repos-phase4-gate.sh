#!/usr/bin/env bash
# Phase 4: li-container-run (lirun) OCI lifecycle.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
bash "$ROOT/scripts/container-separate-repos-phase3-gate.sh"

test -f "$ROOT/packages/li-container-run/src/runtime.li"
test -f "$ROOT/packages/li-container-run/src/main.li"
grep -q 'li-container' "$ROOT/packages/li-container-run/li.toml"

echo "container-separate-repos phase4 gate: OK"
