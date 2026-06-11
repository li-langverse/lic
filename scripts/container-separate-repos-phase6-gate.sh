#!/usr/bin/env bash
# Phase 6: orchestration packages + licontainers retirement.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
bash "$ROOT/scripts/container-separate-repos-phase5-gate.sh"

for pkg in li-containerd li-container-cli li-container-cri; do
  test -f "$ROOT/packages/$pkg/li.toml"
  test -f "$ROOT/packages/$pkg/src/main.li"
done

echo "container-separate-repos phase6 gate: OK"
