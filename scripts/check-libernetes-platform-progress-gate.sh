#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/data/goal-directed-sprints/libernetes-platform.md"
bash "$ROOT/scripts/check-libernetes-platform-docs-gate.sh"
echo "libernetes platform progress gate: OK"
