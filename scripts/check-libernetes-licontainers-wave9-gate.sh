#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/packages/licontainers/src/metrics/cri_metrics.li"
test -f "$ROOT/docs/libernetes/cluster-operations.md"
grep -q 'cri_metrics' "$ROOT/docs/libernetes/cluster-operations.md"
echo "libernetes licontainers wave9 gate: OK"
