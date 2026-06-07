#!/usr/bin/env bash
# WP-PAR-02 — shallow benchmarks clone must chmod harness scripts before tier 7+.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=scripts/lib/lipar-suite-prereqs.sh
source "$ROOT/scripts/lib/lipar-suite-prereqs.sh"
# shellcheck source=scripts/lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"

cache="$ROOT/.cache/li-benchmarks"
if [[ ! -f "$cache/scripts/run-bench.sh" ]]; then
  mkdir -p "$(dirname "$cache")"
  git clone --depth 1 https://github.com/li-langverse/benchmarks.git "$cache" >/dev/null 2>&1
fi

chmod -x "$cache/scripts/run-bench.sh" 2>/dev/null || true
[[ ! -x "$cache/scripts/run-bench.sh" ]]

lipar_suite_ensure_bench_scripts "$cache"
[[ -x "$cache/scripts/run-bench.sh" ]]
[[ -x "$cache/scripts/run-full-benchmark-suite.sh" ]]

echo "li_parallel_bench_scripts_executable: ok"
