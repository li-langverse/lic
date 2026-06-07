#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/docs/libernetes/easy-setup.md"
test -f "$ROOT/docs/libernetes/heterogeneous-workers.md"
echo "libernetes control docs gate: OK"
