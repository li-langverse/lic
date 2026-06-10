#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/packages/li-libernetes-core/src/cluster_state.li"
grep -q 'kubelet.conf' "$ROOT/scripts/libernetes-worker-join.sh"
test -f "$ROOT/packages/li-libernetes-kubelet/li-tests/integration/multi_node_join.li"
echo "libernetes control wave4 gate: OK"
