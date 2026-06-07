#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/packages/livm/li.toml"
test -f "$ROOT/packages/livm/README.md"
echo "libernetes livm scaffold gate: OK"
