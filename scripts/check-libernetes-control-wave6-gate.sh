#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/scripts/bench-libernetes-pod-churn-gate.sh"
test -f "$ROOT/packages/li-libernetes-kubelet/li-tests/e2e/distributed_workload.li"
echo "libernetes control wave6 gate: OK"
