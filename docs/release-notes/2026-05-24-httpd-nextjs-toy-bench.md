# HTTPd — Next.js toy tier5 proxy bench (gap-nextjs-toy-bench)

## Summary

Adds a **nextjs-toy** Node backend and tier5_http proxy scenarios (`nextjs_api`, `nextjs_ssr`, `nextjs_sse`, `nextjs_ws`) with `check-tier5-nextjs-parity.sh` comparing **li-httpd vs nginx** on RPS, p99, and TTFB (default bar: **≥ 0.85×** nginx unless documented variant).

## Surfaces

| Route | Pattern | Scenario |
|-------|---------|----------|
| `GET /api/hello` | JSON API | `nextjs_api` |
| `GET /ssr/page` | HTML SSR shell | `nextjs_ssr` |
| `GET /api/sse` | SSE | `nextjs_sse` |
| `WS /api/ws` | Upgrade smoke | `nextjs_ws` (verify-only) |

## Paths

| Area | Location |
|------|----------|
| Toy backend | `benchmarks/tier5_http/fixtures/nextjs-toy/server.mjs` |
| Scenarios | `benchmarks/tier5_http/scenarios/nextjs_*/bench.toml` |
| Variants doc | `benchmarks/tier5_http/nextjs_parity_variants.toml` |
| Gate | `scripts/check-tier5-nextjs-parity.sh` |
| Results CSV | `benchmarks/results/tier5_nextjs_parity.csv` |

## Test

```bash
./scripts/build-li-httpd.sh
./scripts/check-tier5-nextjs-parity.sh
HTTPD_BENCH_SKIP_TIMING=0 ./scripts/check-tier5-nextjs-parity.sh   # full wrk parity (needs wrk, nginx, node)
./scripts/httpd-plan-gates.sh
```
