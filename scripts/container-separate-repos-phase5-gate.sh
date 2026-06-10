#!/usr/bin/env bash
# Phase 5: cross-platform backends (Linux, LiOS, Windows, macOS).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
bash "$ROOT/scripts/container-separate-repos-phase4-gate.sh"

for f in lios.li windows.li darwin.li; do
  test -f "$ROOT/packages/li-container/src/backend/$f"
done
test -f "$ROOT/docs/libernetes/container-multi-os-matrix.md"

echo "container-separate-repos phase5 gate: OK"
