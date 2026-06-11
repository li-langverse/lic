#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/packages/li-libernetes-controller/src/node_controller.li"
test -f "$ROOT/packages/li-libernetes-kubelet/li-tests/integration/self_heal.li"
echo "libernetes control wave7 gate: OK"
