#!/usr/bin/env bash
# Phase 2: li-container core library + backend abstraction.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
bash "$ROOT/scripts/container-separate-repos-phase1-gate.sh"

for f in bundle.li state.li runerr.li seam.li; do
  test -f "$ROOT/packages/li-container/src/$f"
done
test -f "$ROOT/packages/li-container/src/backend/select.li"
test -f "$ROOT/packages/li-container/src/backend/linux.li"
grep -q 'li-oci' "$ROOT/packages/li-container/li.toml"

echo "container-separate-repos phase2 gate: OK"
