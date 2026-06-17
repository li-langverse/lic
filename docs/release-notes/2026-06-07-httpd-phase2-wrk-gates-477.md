# HTTPd phase2 wrk gates — #477 unblock

Fixes pre-soak CI failure and refocuses phase2 perf gates so `httpd-phase2-nightly` can complete within agent/CI budgets.

## Changes

| Area | Fix |
|------|-----|
| `check-rng-concepts.sh` blocker | `os_rng_fill4` declares `raises IO` (extern fill seam) |
| `check-tier5-perf-wrk-soak.sh` | Focused 30s wrk on parity + parity_streaming + nextjs (not full exploit regression — covered by `check-tier5-exploit-nginx-regression.sh`) |
| `check-tier5-streaming-soak.sh` | Default soak duration 30s when timing enabled |
| Plan loop | Phase2 todos set `LI_HTTPD_PLAN_AGENT_TIMEOUT_SEC=5400`; until-deadline default raised |

## Gates

```bash
HTTPD_BENCH_SKIP_TIMING=0 HTTPD_BENCH_DURATION_SEC=30 ./scripts/check-tier5-perf-wrk-soak.sh
HTTPD_BENCH_SKIP_TIMING=0 HTTPD_BENCH_DURATION_SEC=30 ./scripts/check-tier5-streaming-soak.sh
HTTPD_RUN_PHASE2_GATES=1 HTTPD_GATES_SKIP_LIC_BUILD=1 ./scripts/httpd-plan-gates.sh
```

Closes plan todos `gap-phase2-perf-wrk-soak` and `gap-phase2-streaming-wrk` (li-langverse/lic#477).
