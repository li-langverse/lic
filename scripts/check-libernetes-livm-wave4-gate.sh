#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/packages/livm/src/runtime/remote.li"
test -f "$ROOT/packages/livm/li-tests/integration/remote_vm.li"
echo "libernetes livm wave4 gate: OK"
