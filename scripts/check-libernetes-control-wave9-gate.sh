#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/docs/libernetes/cluster-operations.md"
test -f "$ROOT/scripts/libernetes-dashboard.sh"
grep -q 'node conditions' "$ROOT/docs/libernetes/cluster-operations.md"
echo "libernetes control wave9 gate: OK"
