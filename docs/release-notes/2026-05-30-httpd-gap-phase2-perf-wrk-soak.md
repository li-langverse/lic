# HTTP gap-phase2 perf wrk soak (`gap-phase2-perf-wrk-soak`)

## Gate

- `./scripts/check-tier5-perf-wrk-soak.sh` — `HTTPD_BENCH_SKIP_TIMING=0`, default `HTTPD_BENCH_DURATION_SEC=30`
- Runs tier5 **parity** (`check-tier5-nginx-bench-parity.sh`), **parity_streaming** (`check-tier5-streaming-soak.sh`), **nextjs** (`check-tier5-nextjs-parity.sh`), then exploit nginx compare
- `HTTPD_BENCH_SETTLE_SEC=3` between wrk phases; scenario `bench.toml` `[parity]` RPS/TTFB bars; WS fanout uses `stream_ok_ratio` when `rps_handshake_bound`

## CI

- `.github/workflows/httpd-tier5-regression.yml` — scheduled / `workflow_dispatch` with `full_timing` runs 30s soak via `check-tier5-perf-wrk-soak.sh`
- PR verify uses `check-tier5-nginx-perf-regression-gate.sh` with `HTTPD_BENCH_SKIP_TIMING=1` (8s lean when timing enabled)

## Evidence

```bash
./scripts/build-li-httpd.sh
HTTPD_BENCH_DURATION_SEC=8 HTTPD_BENCH_SETTLE_SEC=1 HTTPD_BENCH_SKIP_TIMING=0 ./scripts/check-tier5-perf-wrk-soak.sh
# exit 0 (2026-05-30T12:15Z, code_implementer re-verify)

HTTPD_GATES_SKIP_LIC_BUILD=1 HTTPD_BENCH_SKIP_TIMING=1 ./scripts/httpd-plan-gates.sh
# exit 0 (2026-05-30T12:15Z)

# Parity highlights (8s lean soak): static_small rps li/nginx=1.27; nextjs_api=1.22; nextjs_ssr=1.26
```

Nightly / plan loop: `HTTPD_RUN_PHASE2_GATES=1 HTTPD_BENCH_DURATION_SEC=30 ./scripts/httpd-plan-gates.sh`
