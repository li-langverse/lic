# Orchestrator note — httpd plan_debt reconcile (#619)

**Date:** 2026-06-05  
**Agent:** `code_implementer`  
**Branch:** `chore/agent-code_implementer-36331053`  
**Issues:** #619, #477 (kept open), #436 (ingest syntax fixed)

---

## Executive summary

| Field | Value |
|-------|-------|
| Snapshot httpd | **8/10** completed; `plan_pending`: `gap-phase2-perf-wrk-soak`, `gap-phase2-streaming-wrk` |
| Tier5 wrk gates | **Not green** — `httpd-phase2-nightly` run 26987188234 failed before phase-2 soak (missing `benchmarks/tier5_http/nginx_mitigations.toml` path) |
| Registry drift | httpd `plan_debt` rows were **closed** while todos still pending |
| Ingest (#436) | `swarm-gap-ingest.py` had syntax error on `ingest_verticals_stubs`; fixed |

## Gate verification

```bash
# Local (requires nginx + wrk + li-httpd + benchmarks sibling):
HTTPD_BENCH_SKIP_TIMING=0 HTTPD_BENCH_DURATION_SEC=30 \
  ./scripts/check-tier5-perf-wrk-soak.sh
HTTPD_BENCH_SKIP_TIMING=0 ./scripts/check-tier5-streaming-soak.sh
```

CI reference: `httpd-phase2-nightly` workflow_dispatch **failure** @ 2026-06-05 — did not reach wrk soak steps.

## Reconcile actions

1. Fixed `scripts/swarm-gap-ingest.py` syntax + added `reconcile_plan_pending_sync`.
2. Re-ran ingest — reopened canonical httpd `plan_debt` rows for both pending phase-2 todos.
3. **#477 remains open** until tier5 wrk/streaming gates green on CI.
4. Snapshot/plan YAML already honest (2 pending); no todo reopen needed beyond registry sync.

## Handoff

`swarm_observer`: confirm `swarm-gap-actions.json` reflects reopened httpd rows after benchmarks ingest path lands on main.
