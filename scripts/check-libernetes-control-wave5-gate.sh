#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/packages/li-libernetes-scheduler/src/schedule.li"
test -f "$ROOT/packages/li-libernetes-kubelet/src/pod_sync.li"
test -f "$ROOT/packages/li-libernetes-kubelet/li-tests/integration/distributed_pod.li"
echo "libernetes control wave5 gate: OK"
