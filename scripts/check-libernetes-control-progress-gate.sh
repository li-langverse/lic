#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/docs/libernetes/easy-setup.md"
test -f "$ROOT/data/goal-directed-sprints/libernetes-control.md"
echo "libernetes control progress gate: OK"
