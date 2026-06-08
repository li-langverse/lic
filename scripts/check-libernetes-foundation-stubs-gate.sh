#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
for pkg in li-watch li-workqueue li-etcd; do
  test -f "$ROOT/packages/$pkg/li.toml" || { echo "missing packages/$pkg/li.toml" >&2; exit 1; }
  test -f "$ROOT/packages/$pkg/README.md" || { echo "missing packages/$pkg/README.md" >&2; exit 1; }
done
echo "libernetes foundation stubs gate: OK"
