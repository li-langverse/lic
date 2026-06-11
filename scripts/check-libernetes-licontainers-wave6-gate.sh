#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/benchmarks/libernetes/README.md"
grep -q 'licontainers' "$ROOT/benchmarks/libernetes/README.md"
test -f "$ROOT/packages/licontainers/li-tests/bench/cri_ops.li"
echo "libernetes licontainers wave6 gate: OK"
