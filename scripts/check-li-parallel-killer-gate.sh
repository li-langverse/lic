#!/usr/bin/env bash
# WP-PAR-99 — li-parallel killer completion gate (whole org suite path + runtime smokes).
# Stricter than check-li-parallel-full-suite.sh (PR Class A profile only).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LIC_ROOT="$ROOT"
export LI_REPO_ROOT="$ROOT"

# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"

li_phase "li-parallel killer gate (WP-PAR-99)"

if [[ ! -x "$ROOT/build/compiler/lic/lic" ]]; then
  li_fail "lic missing — run ./scripts/build.sh"
  exit 1
fi
export SKIP_BUILD="${SKIP_BUILD:-1}"

echo "==> killer gate: parallel runtime smokes"
for smoke in \
  li-tests/tooling/li_par_pool_smoke.sh \
  li-tests/tooling/li_par_pool_schedule_smoke.sh \
  li-tests/tooling/li_par_reduce_sum_smoke.sh \
  li-tests/tooling/li_dpar_for_smoke.sh \
  li-tests/tooling/li_parallel_suite_resolve.sh
do
  chmod +x "$ROOT/$smoke"
  bash "$ROOT/$smoke"
done

echo "==> killer gate: PR profile dual-mode (check-li-parallel-full-suite.sh)"
chmod +x "$ROOT/scripts/check-li-parallel-full-suite.sh"
export SKIP_TIER5_HTTP="${SKIP_TIER5_HTTP:-1}"
export BENCH_RUNS="${BENCH_RUNS:-1}"
export LI_LIPAR_PERF_STRICT="${LI_LIPAR_PERF_STRICT:-0}"
"$ROOT/scripts/check-li-parallel-full-suite.sh"

if [[ "${LIPAR_KILLER_SKIP_FULL:-0}" == "1" ]]; then
  echo "==> killer gate: LIPAR_KILLER_SKIP_FULL=1 — skipping whole-suite path"
else
  SUITE="$ROOT/packages/li-parallel/scripts/lipar-suite.sh"
  BENCH_ROOT="$(
    bash -c '
      set -euo pipefail
      ROOT="'"$ROOT"'"
      # shellcheck source=scripts/lib/benchmarks-env.sh
      source "$ROOT/scripts/lib/benchmarks-env.sh"
      if [[ -f "${BENCHMARKS_ROOT}/scripts/run-full-benchmark-suite.sh" ]]; then
        echo "$BENCHMARKS_ROOT"
        exit 0
      fi
      cache="$ROOT/.cache/li-benchmarks"
      [[ -f "$cache/scripts/run-full-benchmark-suite.sh" ]] && echo "$cache"
    '
  )"
  if [[ -z "${BENCH_ROOT:-}" || ! -f "$BENCH_ROOT/scripts/run-full-benchmark-suite.sh" ]]; then
    li_fail "missing run-full-benchmark-suite.sh — clone benchmarks or populate .cache/li-benchmarks"
    exit 1
  fi
  chmod +x "$BENCH_ROOT/scripts/run-full-benchmark-suite.sh" 2>/dev/null || true
  chmod +x "$BENCH_ROOT/scripts/run-bench.sh" 2>/dev/null || true

  echo "==> killer gate: whole-suite path via lipar-suite --profile full (parallel pass)"
  export BENCHMARKS_ROOT="$BENCH_ROOT"
  export SKIP_TIER0="${SKIP_TIER0:-1}"
  export SKIP_TIER5_HTTP="${SKIP_TIER5_HTTP:-1}"
  export SKIP_EXPLOITS="${SKIP_EXPLOITS:-1}"
  export BENCH_RUNS="${BENCH_RUNS:-1}"
  export LIPAR_CORES="${LIPAR_CORES:-8}"
  chmod +x "$SUITE"
  # Serial+dual-mode already covered by check-li-parallel-full-suite.sh above.
  bash "$SUITE" --profile full --skip-serial --cores "$LIPAR_CORES"

  CSV="${BENCHMARKS_CSV:-$BENCHMARKS_ROOT/results/latest.csv}"
  python3 - "$CSV" <<'PY'
import csv
import os
import sys

path = sys.argv[1]
min_benches = int(os.environ.get("LIPAR_KILLER_MIN_BENCHES", "8"))
rows = list(csv.DictReader(open(path, newline="", encoding="utf-8")))
benches = {
    r.get("benchmark")
    for r in rows
    if r.get("metric") == "wall_time" and r.get("benchmark")
}
tier2 = [b for b in benches if b.startswith(("md_", "fea_", "heat_", "euler_"))]
if len(benches) < min_benches:
    print(
        f"killer gate: whole-suite breadth too narrow ({len(benches)} < {min_benches})",
        file=sys.stderr,
    )
    sys.exit(1)
if not tier2:
    print("killer gate: no tier2 physics rows in CSV — whole suite did not reach tier2", file=sys.stderr)
    sys.exit(1)
print(f"killer gate: whole-suite CSV has {len(benches)} benchmark(s), tier2 sample: {tier2[0]}")
PY
fi

li_ok "check-li-parallel-killer-gate.sh: PASS"
