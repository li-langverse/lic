# Orchestrator note — httpd phase2 registry reconcile (lic#619)

**Date:** 2026-06-04  
**Agent:** `code_implementer`  
**Issues:** lic#619, lic#477 (wrk gates still pending)  
**PH ids:** PH-H, PH-H httpd

---

## Executive summary

| Field | Value |
|-------|-------|
| Snapshot httpd | 8/10 completed; `plan_pending`: perf-wrk-soak, streaming-wrk |
| Registry (pre-ingest) | httpd phase2 rows **closed** while snapshot still pending — stale |
| Fix | `reconcile_snapshot_plan_pending()` re-opens/closes `plan_debt` from snapshot |
| Tier5 gates | Require `nginx`, `wrk`, `build/li-httpd`; run `./scripts/verify-httpd-phase2-wrk-gates.sh` |

`swarm-gap-ingest.py` is present on `lic` main (#436 satisfied). Close #477 only after gates exit 0.

---

## Commands

```bash
python3 scripts/test-swarm-gap-ingest-reconcile.py   # exit 0
python3 scripts/swarm-gap-ingest.py --dry-run
python3 scripts/swarm-gap-ingest.py                    # re-open httpd pending rows
HTTPD_BENCH_SKIP_TIMING=0 ./scripts/verify-httpd-phase2-wrk-gates.sh
```

---

## Agent deliverable

- [x] Bidirectional ingest reconcile + unit test
- [x] Gate verification wrapper script
- [ ] #477 closed (blocked on tier5 wrk soak in CI/nightly with nginx+wrk)
- [ ] lic#619 closed after gates green + swarm_observer ingest on benchmarks main
