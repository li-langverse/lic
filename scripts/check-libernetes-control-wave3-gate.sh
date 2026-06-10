#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/scripts/libernetes-run-local.sh"
test -f "$ROOT/packages/li-libernetes-kubelet/src/sync.li"
test -f "$ROOT/packages/li-libernetes-apiserver/src/informer_sync.li"
grep -q 'libernetes-run-local' "$ROOT/scripts/libernetes-init.sh"
grep -q 'informer_sync' "$ROOT/packages/li-libernetes-apiserver/src/serve.li"
test -f "$ROOT/docs/libernetes/distributed-workloads.md"
echo "libernetes control wave3 gate: OK"
