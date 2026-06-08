# Orchestrator note — httpd phase2 registry reconcile (#619)

**Date:** 2026-06-06  
**Agent:** `code_implementer`  
**Branch:** `chore/agent-code_implementer-24685162`  
**Issue:** li-langverse/lic#619 · PH-H httpd

---

## Executive summary

| Field | Value |
|-------|-------|
| Snapshot httpd | **8/10** complete (not 10/10); `plan_pending`: `gap-phase2-perf-wrk-soak`, `gap-phase2-streaming-wrk` |
| Registry reconcile | Fixed `swarm-gap-ingest.py` (#436 syntax, #471 plan_debt sync); canonical httpd wrk rows **reopened** |
| Tier5 wrk gates | **Not verified** in agent sandbox — no `build/li-httpd`, nginx, or wrk |
| #477 | **Stays open** until `HTTPD_BENCH_SKIP_TIMING=0` gates pass on CI/nightly |

---

## Changes

1. **`scripts/swarm-gap-ingest.py`**
   - Fixed `ingest_verticals_stubs` syntax error (#436)
   - Added `_runner_completed_todo_ids` + `reconcile_snapshot_plan_debt` (#471)
   - Reopen `plan_debt` rows when snapshot `plan_pending` includes normalized todo id
   - Close only when todo `status=completed`/`done` and not in `plan_pending`
   - Dedupe prefers shortest normalized `plan_todo_id`; runs before reconcile

2. **Registry re-ingest**
   - `plan_debt_reconcile`: reopened 4 httpd rows; closed 0 (wrk todos still pending)
   - Canonical `gap-plan-pending-httpd-gap-phase2-{perf-wrk-soak,streaming-wrk}` → **open**

---

## Gate verification

| Command | Result |
|---------|--------|
| `python3 scripts/test-swarm-gap-ingest-reconcile.py` | exit **0** |
| `python3 scripts/swarm-gap-ingest.py --dry-run` | exit **0** |
| `HTTPD_BENCH_SKIP_TIMING=0 ./scripts/check-tier5-perf-wrk-soak.sh` | exit **1** — `build/li-httpd` missing |
| `HTTPD_BENCH_SKIP_TIMING=0 ./scripts/check-tier5-streaming-soak.sh` | exit **1** — `build/li-httpd` missing |

Close #477 and matching registry rows after green gates on `httpd-phase2-nightly` workflow.

---

## Handoff

**swarm_observer** — run `swarm-gap-apply-actions.py` after merge; close httpd plan_debt rows when nightly gates green.
