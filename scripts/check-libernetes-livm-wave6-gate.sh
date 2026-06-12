#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/benchmarks/libernetes/README.md"
grep -q 'livm' "$ROOT/benchmarks/libernetes/README.md"
test -f "$ROOT/packages/livm/li-tests/bench/vm_boot.li"
echo "libernetes livm wave6 gate: OK"
