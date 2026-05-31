#!/usr/bin/env bash
# Forward to li-langverse/benchmarks harness (workloads no longer live under lic/).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BENCHMARKS_ROOT="${BENCHMARKS_ROOT:-$ROOT/../benchmarks}"
if [[ ! -f "$BENCHMARKS_ROOT/scripts/run-bench.sh" ]]; then
  echo "bench-via-benchmarks: set BENCHMARKS_ROOT to li-langverse/benchmarks checkout" >&2
  echo "  missing: $BENCHMARKS_ROOT/scripts/run-bench.sh" >&2
  exit 1
fi
export LIC_ROOT="${LIC_ROOT:-$ROOT}"
export BENCHMARKS_ROOT
exec bash "$BENCHMARKS_ROOT/scripts/run-bench.sh" "$@"
