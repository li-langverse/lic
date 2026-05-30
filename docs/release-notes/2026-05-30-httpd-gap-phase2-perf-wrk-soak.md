# HTTP gap-phase2 perf wrk soak (`gap-phase2-perf-wrk-soak`)

## Gate

- `./scripts/check-tier5-perf-wrk-soak.sh` — `HTTPD_BENCH_SKIP_TIMING=0`, `HTTPD_BENCH_DURATION_SEC=30` (6s locally when iterating)
- Orchestrates: agent-gateway **parity** wrk, **parity_streaming** (WS soak timing + SSE verify), **nextjs** wrk, exploit regression tail

## Runtime fixes (li-httpd proxy)

- Disable GET **snap** and cross-request **CL header cache** on `/stream/*` (SSE/WS)
- **WebSocket** tunnel when client sends `Upgrade: websocket` (not only `require=websocket` routes)
- Li loop: `httpd_li_proxy_finish_uncached_resp_i` for non-cacheable streaming responses; reset resp cache every `finish_ok`
- Fresh upstream TCP for `/stream/*` (no keep-alive pool reuse)

## Scenario bars

| Scenario | Timing | Bar |
|----------|--------|-----|
| `static_small` / `keepalive_pipelining` | wrk 30s | RPS ≥ 0.95× nginx |
| `nextjs_*` (API/SSR) | wrk 30s | RPS/TTFB ≥ 0.80–0.85× nginx |
| `sse_long_stream` | verify-only (`sse_verify` pattern) | live li-httpd verify |
| `ws_fanout` | streaming soak 30s | `stream_ok_ratio` ≥ 0.50× nginx (`rps_handshake_bound`) |

## Evidence

```bash
./scripts/build-li-httpd.sh   # or lic build when compiler stable
HTTPD_BENCH_DURATION_SEC=30 ./scripts/check-tier5-perf-wrk-soak.sh
./scripts/httpd-plan-gates.sh # HTTPD_RUN_PHASE2_GATES=1 for phase-2 hooks
```
