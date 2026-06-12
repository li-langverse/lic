#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/packages/livm/src/workload/restart_policy.li"
test -f "$ROOT/packages/livm/li-tests/integration/self_heal.li"
echo "libernetes livm wave7 gate: OK"
