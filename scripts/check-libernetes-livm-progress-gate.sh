#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/packages/livm/li.toml"
test -f "$ROOT/data/goal-directed-sprints/libernetes-livm.md"
echo "libernetes livm progress gate: OK"
