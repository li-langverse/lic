# Orchestrator note — httpd plan_debt reconcile (#619)

**Date:** 2026-06-04  
**Agent:** `code_implementer`  
**Issue:** [lic#619](https://github.com/li-langverse/lic/issues/619) · tracks [lic#477](https://github.com/li-langverse/lic/issues/477)

## Executive summary

| Field | Value |
|-------|-------|
| Snapshot httpd | 8/10 completed; `plan_pending`: `gap-phase2-perf-wrk-soak`, `gap-phase2-streaming-wrk` |
| Registry drift | Canonical `gap-plan-pending-httpd-*` rows were **closed** while snapshot still pending |
| Fix | `swarm-gap-ingest.py`: `reconcile_snapshot_plan_state` + dedupe prefers normalized gap id |
| Gates | `check-tier5-perf-wrk-soak.sh` / `check-tier5-streaming-soak.sh` require `build/li-httpd` + nginx + wrk (not run in agent sandbox) |

## Actions

1. Fixed syntax error in `ingest_verticals_stubs` (blocked ingest on main).
2. Reconcile reopens plan_debt when `plan_pending` includes todo; closes when todo `status: completed` and not pending.
3. Dedupe keeps `gap-plan-pending-{runner}-{slug(norm)}` as canonical, closes triple-prefix mirror rows.
4. Post-ingest: `gap-plan-pending-httpd-gap-phase2-perf-wrk-soak` and `…-streaming-wrk` → **open**.

## Deferred

- Close #477 when `HTTPD_BENCH_SKIP_TIMING=0` gates green on CI/nightly host.
- `swarm_observer` handoff: re-run ingest after httpd plan-loop marks phase2 todos completed.
