#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
for f in client.li; do
  test -f "$ROOT/packages/li-etcd/src/$f" || { echo "missing packages/li-etcd/src/$f" >&2; exit 1; }
done
test -f "$ROOT/packages/li-watch/src/reflector.li"
test -f "$ROOT/packages/li-workqueue/src/queue.li"
test -f "$ROOT/packages/li-grpc/li.toml"
test -f "$ROOT/packages/li-grpc/src/lib.li"
grep -q 'li-grpc' "$ROOT/packages/li.toml"
echo "libernetes platform wave2 gate: OK"
