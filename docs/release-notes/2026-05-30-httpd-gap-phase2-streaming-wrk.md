# HTTP gap-phase2 streaming wrk soak (`gap-phase2-streaming-wrk`)

## Gate

- `./scripts/check-tier5-streaming-soak.sh` — `HTTPD_BENCH_SKIP_TIMING=0`, `parity_streaming` with `sse_long_stream` + `ws_fanout` timing (not verify-only)

## Runtime (li-httpd proxy)

- Fresh upstream TCP for `/stream/*` — bypass keep-alive pool reuse on acquire and force `proxy_up_reuse=0` on release
- Reset proxy slot state on client slot reuse after stream responses

## Harness

- `bench_http_parity.py` — restore `rps_handshake_bound` + `stream_ok_ratio` bars for streaming soak scenarios
- `streaming_soak_load.py` — robust SSE reads (`IncompleteRead`, `Accept: text/event-stream`, bounded timeouts)
- `verify_http.py` — SSE verify sends `Accept: text/event-stream`

## Evidence

```bash
./scripts/build-li-httpd.sh
HTTPD_BENCH_DURATION_SEC=6 HTTPD_BENCH_SKIP_TIMING=0 ./scripts/check-tier5-streaming-soak.sh
HTTPD_RUN_PHASE2_GATES=1 ./scripts/httpd-plan-gates.sh
```
