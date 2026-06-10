# Orchestrator note — httpd phase2 plan_debt reconcile (#619)

**Date:** 2026-06-04  
**Agent:** `code_implementer`  
**Issue:** [lic#619](https://github.com/li-langverse/lic/issues/619) · tracks [lic#477](https://github.com/li-langverse/lic/issues/477)

## Snapshot truth (2026-05-30 ingest source)

| Field | Value |
|-------|-------|
| httpd `plan_completed` | 8 / 10 |
| `plan_pending` | `gap-phase2-perf-wrk-soak`, `gap-phase2-streaming-wrk` |
| Last gate attempts | exit 124, `gates_ok: false` (wrk soak + streaming-wrk) |

Registry rows for those todos had been **closed** while `plan_pending` still listed them — ingest only consulted `state.completed_ids` (empty for httpd), not plan todo `status`.

## Fix (this PR)

- `scripts/swarm-gap-ingest.py`: syntax fix (`verticals.toml` path), safe `BENCHMARKS_COMPETITIVE` default
- Reopen canonical `gap-plan-pending-httpd-*` rows when todo reappears in `plan_pending`
- Close plan_debt only when todo is completed in plan **and** not in `plan_pending`
- `scripts/test_swarm_gap_ingest_reconcile.py` — three reconciliation cases

## Gate verification (workspace)

```bash
# li-httpd not built in agent workspace; full timing gates deferred to httpd plan-loop / CI
HTTPD_BENCH_SKIP_TIMING=0 ./scripts/check-tier5-perf-wrk-soak.sh      # requires build + nginx + wrk
HTTPD_BENCH_SKIP_TIMING=0 ./scripts/check-tier5-streaming-soak.sh    # requires build + nginx
python3 scripts/test_swarm_gap_ingest_reconcile.py                     # exit 0
python3 scripts/swarm-gap-ingest.py --dry-run                          # snapshot_completed reconciles plan truth
```

**#477** remains open until both gates pass with `HTTPD_BENCH_SKIP_TIMING=0` on a host with `build/li-httpd`, nginx, and wrk.

## IDs

**PH-H** · **PH-H httpd** · north_star_fit: proof-before-perf (gates block plan completion)
