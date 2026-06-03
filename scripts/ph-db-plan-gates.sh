#!/usr/bin/env bash
# Gates for PH-DB cross-repo plan loop (Wave 3). Not compiler/httpd loops.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh" 2>/dev/null || true
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh" 2>/dev/null || true

fail() {
  li_gate_fail "$*" 2>/dev/null || echo "FAIL: $*" >&2
  exit 1
}
ok() { li_ok "$*" 2>/dev/null || echo "OK: $*"; }

PLAN_LOOP="$ROOT/docs/superpowers/plans/2026-06-03-ph-db-plan-loop.md"
SWARM="$ROOT/docs/superpowers/plans/ph-db-swarm-plan.md"

[[ -f "$PLAN_LOOP" ]] || fail "missing plan-loop $PLAN_LOOP"
[[ -f "$SWARM" ]] || fail "missing swarm canvas $SWARM"
grep -q '^todos:' "$PLAN_LOOP" || fail "plan-loop missing todos YAML"
grep -q 'wp-h-containers' "$PLAN_LOOP" || fail "plan-loop missing wp-h-containers"

LANGVERSE="${LI_LANGVERSE_ROOT:-$ROOT/..}"

if [[ "${PH_DB_GATES_SKIP_SIBLINGS:-0}" != "1" ]]; then
  for repo in lidb lis benchmarks li-cursor-agents; do
    if [[ -d "$LANGVERSE/$repo/.git" ]]; then
      li_phase "sibling present: $repo" 2>/dev/null || true
    else
      echo "WARN: sibling $repo not checked out under $LANGVERSE" >&2
    fi
  done
fi

if [[ "${PH_DB_GATES_FULL:-0}" == "1" ]]; then
  li_phase "lidb smoke" 2>/dev/null || true
  if [[ -x "$LANGVERSE/lidb/scripts/smoke.sh" ]]; then
    (cd "$LANGVERSE/lidb" && bash scripts/smoke.sh) || fail "lidb smoke"
  fi
  li_phase "lis db-smoke" 2>/dev/null || true
  if [[ -x "$LANGVERSE/lis/scripts/db-smoke.sh" ]]; then
    (cd "$LANGVERSE/lis" && bash scripts/db-smoke.sh) || fail "lis db-smoke"
  fi
  if [[ -f "$BENCHMARKS_ROOT/data/latest/tier-db-registry.json" ]]; then
    grep -q '"engine_mode"' "$BENCHMARKS_ROOT/data/latest/tier-db-registry.json" \
      || fail "tier-db-registry.json missing engine_mode"
  fi
fi

ok "ph-db plan gates"
