#!/usr/bin/env bash
# WP-PAR-99 — li-parallel killer completion gate (whole org suite + hetero + FL + docs).
# No skip env vars (LIPAR_KILLER_SKIP_FULL removed). Partial PR gate is NOT ship criteria.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LIC_ROOT="$ROOT"
export LI_REPO_ROOT="$ROOT"

# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"

li_phase "li-parallel killer gate (WP-PAR-99)"

if [[ "${LIPAR_KILLER_SKIP_FULL:-}" == "1" ]]; then
  li_fail "LIPAR_KILLER_SKIP_FULL is disabled — killer gate must run the whole stack"
  exit 1
fi

if [[ ! -x "$ROOT/build/compiler/lic/lic" ]]; then
  li_fail "lic missing — run ./scripts/build.sh"
  exit 1
fi
export SKIP_BUILD="${SKIP_BUILD:-1}"

echo "==> killer gate step 1: parallel runtime smokes"
for smoke in \
  li-tests/tooling/li_par_pool_smoke.sh \
  li-tests/tooling/li_par_pool_schedule_smoke.sh \
  li-tests/tooling/li_par_pool_steal_smoke.sh \
  li-tests/tooling/li_par_reduce_sum_smoke.sh \
  li-tests/tooling/li_exec_team_scope_smoke.sh \
  li-tests/tooling/li_dpar_for_smoke.sh \
  li-tests/tooling/li_parallel_def_callable_smoke.sh \
  li-tests/tooling/li_parallel_suite_resolve.sh
do
  chmod +x "$ROOT/$smoke"
  bash "$ROOT/$smoke"
done

echo "==> killer gate step 2: progress slice (PR Class A dual-mode)"
chmod +x "$ROOT/scripts/check-li-parallel-full-suite.sh"
export SKIP_TIER5_HTTP="${SKIP_TIER5_HTTP:-1}"
export BENCH_RUNS="${BENCH_RUNS:-1}"
export LI_LIPAR_PERF_STRICT="${LI_LIPAR_PERF_STRICT:-1}"
"$ROOT/scripts/check-li-parallel-full-suite.sh"

SUBGATES=(
  check-li-parallel-docs-gate.sh
  check-li-parallel-compile-smoke-gate.sh
  audit-li-parallel-catalog-coverage.sh
  check-li-parallel-distributed-gate.sh
  check-li-parallel-fl-gate.sh
  check-li-parallel-comm-gate.sh
  check-li-parallel-hetero-gate.sh
  check-li-parallel-xfer-gate.sh
  check-li-parallel-proofs-gate.sh
  check-chip-package-boundaries.sh
)
for gate in "${SUBGATES[@]}"; do
  script="$ROOT/scripts/$gate"
  if [[ ! -f "$script" ]]; then
    li_fail "missing sub-gate $gate"
    exit 1
  fi
  chmod +x "$script"
  echo "==> killer gate: $gate"
  "$script"
done

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

echo "==> killer gate step 3: whole org suite dual-mode (tiers 0–7, no tier skips)"
export BENCHMARKS_ROOT="$BENCH_ROOT"
unset SKIP_TIER0 SKIP_TIER5_HTTP SKIP_EXPLOITS || true
export BENCH_RUNS="${BENCH_RUNS:-3}"
export LIPAR_CORES="${LIPAR_CORES:-8}"
chmod +x "$SUITE"
bash "$SUITE" --profile full --dual-mode --cores "$LIPAR_CORES"

CSV="${BENCHMARKS_CSV:-$BENCHMARKS_ROOT/results/latest.csv}"
python3 - "$CSV" <<'PY'
import csv
import os
import sys

path = sys.argv[1]
min_benches = int(os.environ.get("LIPAR_KILLER_MIN_BENCHES", "120"))
rows = list(csv.DictReader(open(path, newline="", encoding="utf-8")))
benches = {
    r.get("benchmark")
    for r in rows
    if r.get("metric") == "wall_time" and r.get("benchmark")
}
dual = {
    (r.get("benchmark"), r.get("lang"))
    for r in rows
    if r.get("metric") == "wall_time" and r.get("lang") in ("li_serial", "li_parallel")
}
tier2 = [b for b in benches if b.startswith(("md_", "fea_", "heat_", "euler_"))]
if len(benches) < min_benches:
    print(
        f"killer gate: whole-suite breadth too narrow ({len(benches)} < {min_benches})",
        file=sys.stderr,
    )
    sys.exit(1)
if not tier2:
    print("killer gate: no tier2 physics rows in CSV", file=sys.stderr)
    sys.exit(1)
li_langs = {"li", "li_serial", "li_parallel"}
li_benches = {
    r.get("benchmark")
    for r in rows
    if r.get("metric") == "wall_time" and r.get("lang") in li_langs and r.get("benchmark")
}
missing_dual = [
    b
    for b in li_benches
    if (b, "li_serial") not in dual or (b, "li_parallel") not in dual
]
if missing_dual:
    sample = ", ".join(sorted(missing_dual)[:8])
    print(
        f"killer gate: {len(missing_dual)} benchmark(s) missing li_serial/li_parallel dual-mode rows (e.g. {sample})",
        file=sys.stderr,
    )
    sys.exit(1)
print(f"killer gate: whole-suite CSV has {len(benches)} benchmarks, dual-mode complete, tier2 sample: {tier2[0]}")
PY

li_ok "check-li-parallel-killer-gate.sh: PASS"
