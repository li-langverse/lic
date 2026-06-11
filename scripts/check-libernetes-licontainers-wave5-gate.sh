#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/packages/licontainers/src/workload/exec.li"
test -f "$ROOT/packages/licontainers/li-tests/integration/distributed_exec.li"
echo "libernetes licontainers wave5 gate: OK"
