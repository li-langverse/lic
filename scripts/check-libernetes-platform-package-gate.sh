#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/packages/li-libernetes-core/li.toml"
test -f "$ROOT/packages/li-libernetes-core/src/lib.li"
echo "libernetes platform package gate: OK"
