#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
for pkg in li-etcd li-watch li-workqueue; do
  test -f "$ROOT/packages/$pkg/src/lib.li" || { echo "missing packages/$pkg/src/lib.li" >&2; exit 1; }
done
grep -q 'li-libernetes-core' "$ROOT/packages/li.toml"
grep -q 'li-etcd' "$ROOT/packages/li.toml"
grep -q 'li-watch' "$ROOT/packages/li.toml"
grep -q 'li-workqueue' "$ROOT/packages/li.toml"
echo "libernetes platform wave1 gate: OK"
