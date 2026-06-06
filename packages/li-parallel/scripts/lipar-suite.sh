#!/usr/bin/env bash
# li-parallel full org benchmark suite — serial baseline then parallel (LI_PARALLEL=1).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
# Agent runners often export stale LIC_ROOT=/workspace/lic — always pin to this checkout.
export LIC_ROOT="$ROOT"
export LI_REPO_ROOT="$ROOT"
# shellcheck source=../../../scripts/lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"

_ensure_full_benchmarks_root() {
  local suite="${BENCHMARKS_ROOT}/scripts/run-full-benchmark-suite.sh"
  if [[ -f "$suite" ]]; then
    echo "$BENCHMARKS_ROOT"
    return 0
  fi
  local cache="$ROOT/.cache/li-benchmarks"
  if [[ ! -f "$cache/scripts/run-full-benchmark-suite.sh" ]]; then
    mkdir -p "$(dirname "$cache")"
    if [[ -d "$cache/.git" ]]; then
      (cd "$cache" && git fetch --depth 1 origin main >/dev/null 2>&1 || true)
      (cd "$cache" && git checkout -f origin/main >/dev/null 2>&1 || true)
    else
      git clone --depth 1 https://github.com/li-langverse/benchmarks.git "$cache" >/dev/null 2>&1 || true
    fi
  fi
  if [[ -f "$cache/scripts/run-full-benchmark-suite.sh" ]]; then
    echo "$cache"
    return 0
  fi
  return 1
}

if ! BENCH_ROOT="$(_ensure_full_benchmarks_root)"; then
  echo "ERROR: benchmarks harness missing — set BENCHMARKS_ROOT to a full benchmarks checkout" >&2
  echo "  expected: \$BENCHMARKS_ROOT/scripts/run-full-benchmark-suite.sh" >&2
  exit 1
fi
export BENCHMARKS_ROOT="$BENCH_ROOT"
PROFILE="full"
CORES="${LIPAR_CORES:-8}"
HOSTS=""
DUAL_MODE=0
SKIP_SERIAL=0
SKIP_PARALLEL=0

usage() {
  cat <<'EOF'
Usage: lipar-suite.sh [options]

  --profile pr|full|distributed   Benchmark profile (default: full)
  --cores N                       Thread count for parallel pass (default: 8)
  --hosts h1,h2,...               Multi-node subset (distributed profile)
  --dual-mode                     Emit li_serial + li_parallel rows (default for gate)
  --skip-serial                   Parallel pass only
  --skip-parallel                 Serial pass only
  -h, --help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile) PROFILE="${2:?}"; shift 2 ;;
    --cores) CORES="${2:?}"; shift 2 ;;
    --hosts) HOSTS="${2:?}"; shift 2 ;;
    --dual-mode) DUAL_MODE=1; shift ;;
    --skip-serial) SKIP_SERIAL=1; shift ;;
    --skip-parallel) SKIP_PARALLEL=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown: $1" >&2; usage >&2; exit 1 ;;
  esac
done

case "$PROFILE" in
  pr) export BENCH_PROFILE=pr; export BENCH_RUNS="${BENCH_RUNS:-3}"; export SKIP_TIER0="${SKIP_TIER0:-1}" ;;
  full) export BENCH_PROFILE=full; export BENCH_RUNS="${BENCH_RUNS:-6}" ;;
  distributed)
    export BENCH_PROFILE=pr
    export BENCH_RUNS="${BENCH_RUNS:-3}"
    export LI_DPAR_HOSTS="${HOSTS:-localhost,localhost,localhost,localhost}"
    export LI_DPAR_WORLD_SIZE="${LI_DPAR_WORLD_SIZE:-4}"
    ;;
  *) echo "unknown profile: $PROFILE" >&2; exit 1 ;;
esac

SUITE="$BENCH_ROOT/scripts/run-full-benchmark-suite.sh"
if [[ ! -x "$SUITE" && ! -f "$SUITE" ]]; then
  echo "ERROR: missing $SUITE" >&2
  exit 1
fi

_run_benches() {
  if [[ "$PROFILE" == "pr" ]]; then
    chmod +x "$ROOT/scripts/lipar-run-class-a.sh"
    bash "$ROOT/scripts/lipar-run-class-a.sh"
  else
    bash "$SUITE"
  fi
}

_dual_mode_tag() {
  local mode="$1"
  python3 "$ROOT/scripts/lipar-dual-mode-csv.py" \
    --csv "${BENCHMARKS_CSV:-$BENCHMARKS_RESULTS/latest.csv}" \
    --mode "$mode" \
    --cores "$CORES"
}

run_pass() {
  local label="$1"
  local li_parallel="$2"
  local dual_flag="$3"
  echo "==> lipar-suite: $label (LI_PARALLEL=$li_parallel cores=$CORES profile=$PROFILE)"
  export LI_PARALLEL="$li_parallel"
  export BENCH_DUAL_MODE="$dual_flag"
  export LIPAR_CORES="$CORES"
  export BENCHMARKS_CSV="${BENCHMARKS_CSV:-$BENCHMARKS_RESULTS/latest.csv}"
  if [[ "$li_parallel" == "1" ]]; then
    export LIC_BUILD_FLAGS="--cores=${CORES} --threads-per-core=1"
  else
    unset LIC_BUILD_FLAGS || true
  fi
  _run_benches
  if [[ "$dual_flag" == "1" ]]; then
    if [[ "$li_parallel" == "1" ]]; then
      _dual_mode_tag parallel
    else
      _dual_mode_tag serial
    fi
  fi
}

if [[ "$DUAL_MODE" == "1" || ( "$SKIP_SERIAL" == "0" && "$SKIP_PARALLEL" == "0" ) ]]; then
  DUAL_MODE=1
fi

if [[ "$SKIP_SERIAL" != "1" ]]; then
  if [[ "$DUAL_MODE" == "1" ]]; then
    run_pass "serial baseline" "0" "1"
  else
    run_pass "serial" "0" "0"
  fi
fi

if [[ "$SKIP_PARALLEL" != "1" ]]; then
  if [[ "$DUAL_MODE" == "1" ]]; then
    run_pass "parallel runtime" "1" "1"
  else
    run_pass "parallel" "1" "0"
  fi
fi

echo "==> lipar-suite: done (profile=$PROFILE dual_mode=$DUAL_MODE)"
