#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/packages/licontainers/src/workload/restart_policy.li"
test -f "$ROOT/packages/licontainers/li-tests/integration/self_heal.li"
echo "libernetes licontainers wave7 gate: OK"
