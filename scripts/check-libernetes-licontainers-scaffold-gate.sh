#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/packages/licontainers/li.toml"
test -f "$ROOT/packages/licontainers/README.md"
echo "libernetes licontainers scaffold gate: OK"
