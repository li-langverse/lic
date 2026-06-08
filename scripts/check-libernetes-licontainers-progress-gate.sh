#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/packages/licontainers/li.toml"
test -f "$ROOT/data/goal-directed-sprints/libernetes-licontainers.md"
echo "libernetes licontainers progress gate: OK"
