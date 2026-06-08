# Orchestrator note — httpd plan_debt reconcile (#619)

**Date:** 2026-06-06  
**Agent:** `code_implementer`  
**Branch:** `chore/agent-code_implementer-22883483`  
**Issues:** #619 (reconcile), #477 (kept open), #436 (ingest syntax fixed)

---

## Executive summary

| Field | Value |
|-------|-------|
| Snapshot httpd | **8/10** completed; `plan_pending`: `gap-phase2-perf-wrk-soak`, `gap-phase2-streaming-wrk` |
| Tier5 wrk gates | **Not verified green** in agent workspace (no `build/li-httpd`, nginx, wrk) |
| Registry drift | httpd `plan_debt` rows were **closed** while todos still pending |
| Ingest (#436) | `swarm-gap-ingest.py` syntax error on `ingest_verticals_stubs`; fixed + `reconcile_plan_pending_sync` added |

## Gate verification

```bash
HTTPD_BENCH_SKIP_TIMING=0 HTTPD_BENCH_DURATION_SEC=30 \
  ./scripts/check-tier5-perf-wrk-soak.sh
HTTPD_BENCH_SKIP_TIMING=0 ./scripts/check-tier5-streaming-soak.sh
```

Requires: `build/li-httpd`, benchmarks sibling checkout, nginx + wrk on PATH.

## Reconcile actions

1. Fixed `scripts/swarm-gap-ingest.py` syntax + added `reconcile_plan_pending_sync`.
2. Re-ran ingest — reopened canonical httpd `plan_debt` rows for both pending phase-2 todos.
3. **#477 remains open** until tier5 wrk/streaming gates green on CI/bench host.

## Handoff

`swarm_observer`: confirm `swarm-gap-actions.json` reflects reopened httpd rows after merge.
