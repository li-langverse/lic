#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/packages/livm/src/workload/exec.li"
test -f "$ROOT/packages/livm/li-tests/integration/distributed_exec.li"
echo "libernetes livm wave5 gate: OK"
