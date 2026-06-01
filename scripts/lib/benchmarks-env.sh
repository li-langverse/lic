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
  # Prefer explicit org roots when available (used by other swarm scripts).
  for _c in \
    "${LI_LANGVERSE_ROOT:-}/benchmarks" \
    "${LANGVERSE:-}/benchmarks" \
    "$_lic/benchmarks" \
    "$_lic/../benchmarks" \
    "$_lic/../li-langverse/benchmarks"
  do
    if [[ -f "$_c/harness/bench.py" ]]; then
      BENCHMARKS_ROOT="$(cd "$_c" && pwd)"
      break
    fi
    # "Lite" fallback: in-repo results + competitive only when harness is present too.
    # Without harness, prefer cloning li-langverse/benchmarks (studio-ui gates need animate_md).
    if [[ -d "$_c/results" && -d "$_c/competitive" && -f "$_c/harness/bench.py" ]]; then
      BENCHMARKS_ROOT="$(cd "$_c" && pwd)"
      break
    fi
  done
  # Fallback for isolated clones that vendor only the minimal benchmarks layout
  # (results + competitive) inside the lic repo.
  if [[ -z "${BENCHMARKS_ROOT:-}" ]] \
    && [[ -d "$_lic/benchmarks/results" ]] \
    && [[ -d "$_lic/benchmarks/competitive" ]] \
    && [[ -f "$_lic/benchmarks/harness/bench.py" ]]; then
    BENCHMARKS_ROOT="$(cd "$_lic/benchmarks" && pwd)"
  fi
fi

# Fallback: walk up parent dirs (handles isolated clones under data/workspaces/...).
if [[ -z "${BENCHMARKS_ROOT:-}" ]]; then
  _here="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
  _p="$_here"
  for _i in 1 2 3 4 5 6 7 8 9 10; do
    for _c in "$_p/benchmarks" "$_p/li-langverse/benchmarks"; do
      if [[ -f "$_c/harness/bench.py" ]]; then
        BENCHMARKS_ROOT="$(cd "$_c" && pwd)"
        break 2
      fi
    done
    _p="$(cd "$_p/.." && pwd)"
  done
fi

# Last resort: populate a local cache (useful for CI runners without sibling checkouts).
if [[ -z "${BENCHMARKS_ROOT:-}" ]]; then
  _lic="$(_benchmarks_env_lic_root)"
  _cache="$_lic/.cache/li-benchmarks"
  if [[ ! -f "$_cache/harness/bench.py" ]]; then
    mkdir -p "$(dirname "$_cache")"
    if [[ -d "$_cache/.git" ]]; then
      (cd "$_cache" && git fetch --depth 1 origin main >/dev/null 2>&1 || true)
      (cd "$_cache" && git checkout -f origin/main >/dev/null 2>&1 || true)
    else
      git clone --depth 1 https://github.com/li-langverse/benchmarks.git "$_cache" >/dev/null 2>&1 || true
    fi
  fi
  if [[ -f "$_cache/harness/bench.py" ]]; then
    BENCHMARKS_ROOT="$(cd "$_cache" && pwd)"
  fi
fi

if [[ -z "${BENCHMARKS_ROOT:-}" ]]; then
  echo "benchmarks-env: set BENCHMARKS_ROOT to a benchmarks checkout" >&2
  echo "  expected sibling: \$LIC_ROOT/../benchmarks/harness/bench.py (or set LI_LANGVERSE_ROOT/LANGVERSE)" >&2
  echo "  or in-repo:      \$LIC_ROOT/benchmarks/{results,competitive}" >&2
  return 1 2>/dev/null || exit 1
fi

if [[ ! -f "${BENCHMARKS_ROOT}/harness/bench.py" ]] \
  && [[ ! -d "${BENCHMARKS_ROOT}/results" || ! -d "${BENCHMARKS_ROOT}/competitive" ]]
then
  echo "benchmarks-env: BENCHMARKS_ROOT is missing harness and in-repo layout" >&2
  echo "  got: $BENCHMARKS_ROOT" >&2
  return 1 2>/dev/null || exit 1
fi

export BENCHMARKS_ROOT
export LI_BENCHMARKS_ROOT="${LI_BENCHMARKS_ROOT:-$BENCHMARKS_ROOT}"
if [[ -z "${HARNESS:-}" ]] && [[ -d "$BENCHMARKS_ROOT/harness" ]]; then
  HARNESS="$BENCHMARKS_ROOT/harness"
fi
export HARNESS="${HARNESS:-}"
export BENCHMARKS_RESULTS="${BENCHMARKS_RESULTS:-$BENCHMARKS_ROOT/results}"

if [[ -f "${BENCHMARKS_ROOT}/harness/bench.py" ]]; then
  export HARNESS="${HARNESS:-$BENCHMARKS_ROOT/harness}"
  export BENCHMARKS_WORKLOADS="${BENCHMARKS_WORKLOADS:-$BENCHMARKS_ROOT/benchmarks/workloads}"
  export BENCHMARKS_COMPETITIVE="${BENCHMARKS_COMPETITIVE:-$BENCHMARKS_WORKLOADS/competitive}"
else
  export BENCHMARKS_COMPETITIVE="${BENCHMARKS_COMPETITIVE:-$BENCHMARKS_ROOT/competitive}"
fi
mkdir -p "$BENCHMARKS_RESULTS"
