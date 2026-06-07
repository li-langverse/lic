# HTTP tier5 nginx perf regression gate (gap-nginx-perf-regression-gate)

## Summary

Adds a **unified CI/nightly gate** that runs tier5 agent-gateway parity, Next.js toy proxy parity, live exploit runtime, and nginx-vs-li exploit compare. The gate fails when **li p99 > 2× nginx** on bench scenarios or when an exploit row **regresses** (nginx passed, li failed).

## Gates

| Command | When |
|---------|------|
| `./scripts/check-tier5-nginx-perf-regression-gate.sh` | Local + `httpd-plan-gates.sh` (verify-only by default) |
| `HTTPD_BENCH_SKIP_TIMING=0 HTTPD_BENCH_DURATION_SEC=30 ./scripts/check-tier5-nginx-perf-regression-gate.sh` | Full wrk parity (needs wrk, nginx, node) |
| GitHub Actions `httpd-tier5-regression.yml` | PR: verify-only; schedule/nightly: 30s wrk timing |

## Changed

- `scripts/check-tier5-nginx-perf-regression-gate.sh` — orchestrates parity + nextjs + exploit checks.
- `benchmarks/harness/exploit_http.py` — `--fail-on-regression` with `--compare-nginx`.
- `scripts/httpd-plan-gates.sh` — single `HTTPD_RUN_PERF_REGRESSION_GATE` hook.
- `.github/workflows/httpd-tier5-regression.yml` — path-filtered PR + nightly schedule.

## Pass bars

- Agent-gateway (`parity` profile): RPS ≥ 0.95× nginx, p99 ≤ 2× nginx.
- Next.js toy (`nextjs_parity`): RPS/TTFB ≥ 0.85× nginx, p99 ≤ 2× nginx (see `nextjs_parity_variants.toml`).
- Exploits (`pr` profile): every row passes on live `li-httpd`; no nginx-pass / li-fail regression.
