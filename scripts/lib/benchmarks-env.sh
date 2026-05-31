#!/usr/bin/env bash
# Resolve li-langverse/benchmarks checkout (harness + workloads live there, not under lic/).
# Source from lic scripts after ROOT/LIC_ROOT is set.
set -euo pipefail

_benchmarks_env_lic_root() {
  if [[ -n "${LIC_ROOT:-}" ]]; then
    echo "$(cd "$LIC_ROOT" && pwd)"
    return 0
  fi
  if [[ -n "${LI_REPO_ROOT:-}" ]]; then
    echo "$(cd "$LI_REPO_ROOT" && pwd)"
    return 0
  fi
  local here
  here="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
  echo "$here"
}

if [[ -z "${BENCHMARKS_ROOT:-}" ]]; then
  _lic="$(_benchmarks_env_lic_root)"
  for _c in "$_lic/../benchmarks" "$_lic/../li-langverse/benchmarks"; do
    if [[ -f "$_c/harness/bench.py" ]]; then
      BENCHMARKS_ROOT="$(cd "$_c" && pwd)"
      break
    fi
  done
fi

if [[ -z "${BENCHMARKS_ROOT:-}" || ! -f "${BENCHMARKS_ROOT}/harness/bench.py" ]]; then
  echo "benchmarks-env: clone li-langverse/benchmarks sibling and set BENCHMARKS_ROOT" >&2
  echo "  expected: \$LIC_ROOT/../benchmarks/harness/bench.py" >&2
  return 1 2>/dev/null || exit 1
fi

export BENCHMARKS_ROOT
export LI_BENCHMARKS_ROOT="${LI_BENCHMARKS_ROOT:-$BENCHMARKS_ROOT}"
export HARNESS="${HARNESS:-$BENCHMARKS_ROOT/harness}"
export BENCHMARKS_RESULTS="${BENCHMARKS_RESULTS:-$BENCHMARKS_ROOT/results}"
export BENCHMARKS_WORKLOADS="${BENCHMARKS_WORKLOADS:-$BENCHMARKS_ROOT/benchmarks/workloads}"
export BENCHMARKS_COMPETITIVE="${BENCHMARKS_COMPETITIVE:-$BENCHMARKS_WORKLOADS/competitive}"
mkdir -p "$BENCHMARKS_RESULTS"
