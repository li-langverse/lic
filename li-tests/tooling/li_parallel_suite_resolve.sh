#!/usr/bin/env bash
# Smoke: lipar-suite resolves full benchmarks harness (no suite run).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SUITE="$ROOT/packages/li-parallel/scripts/lipar-suite.sh"
chmod +x "$SUITE"
"$SUITE" --help >/dev/null
# Resolve harness without executing workloads.
bash -c '
  set -euo pipefail
  ROOT="'"$ROOT"'"
  # shellcheck source=scripts/lib/benchmarks-env.sh
  source "$ROOT/scripts/lib/benchmarks-env.sh"
  _ensure() {
    local suite="${BENCHMARKS_ROOT}/scripts/run-full-benchmark-suite.sh"
    if [[ -f "$suite" ]]; then echo "$BENCHMARKS_ROOT"; return 0; fi
    local cache="$ROOT/.cache/li-benchmarks"
    [[ -f "$cache/scripts/run-full-benchmark-suite.sh" ]] && { echo "$cache"; return 0; }
    return 1
  }
  bench="$(_ensure)"
  [[ -f "$bench/scripts/run-full-benchmark-suite.sh" ]]
'
echo "li_parallel_suite_resolve: ok"
