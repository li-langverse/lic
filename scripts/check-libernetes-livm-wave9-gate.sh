#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/packages/livm/src/metrics/vm_metrics.li"
test -f "$ROOT/docs/libernetes/cluster-operations.md"
grep -q 'vm_metrics' "$ROOT/docs/libernetes/cluster-operations.md"
echo "libernetes livm wave9 gate: OK"
