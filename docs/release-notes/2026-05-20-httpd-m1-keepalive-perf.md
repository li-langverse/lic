# li-httpd M1 — keep-alive, pipeline, epoll

## Summary

Upgrades `runtime/li_rt_net.c` so tier-5 `li-httpd` matches or beats stock nginx RPS on loopback static benches via keep-alive, pipelining, epoll, and TCP quickack/single-segment small responses.

## Agent continuation

1. **Read:** `runtime/li_rt_net.c` (`httpd_epoll_loop`, `drain_requests`, `send_static_file`).
2. **Run:** `./build/compiler/lic/lic build packages/li-net-httpd/src/main.li -o build/li-httpd`; `LI_HTTPD_BIN=build/li-httpd python3 …/bench_http.py --profile ci` (lis or benchmarks vendor).
3. **Then:** merge HTTP rows into `benchmarks` `summary.json`; parser proofs / Li-native router (P0-http) remain open.
4. **Blocked on:** `cursor[bot]` push to **lic**/**lis** if 403 — human push branch `cursor/httpd-serve-m0-54aa` or successor.

## Changed

| Path | Evidence |
|------|----------|
| `runtime/li_rt_net.c` | epoll (Linux), keep-alive, pipeline drain, sendfile + small-file coalesce, TCP_QUICKACK |
| `CHANGELOG.md` | Unreleased M1 perf bullet |

## Not changed

- `packages/li-net-httpd/src/*.li` API surface (`httpd_serve_static_blocking` unchanged).
- TLS, HTTP/2, path traversal hardening beyond bench fixture.
- **lis** harness (`bench_http.py`) — no code change required; uses `LI_HTTPD_BIN`.

## Breaking

N/A

## Security

Same M0 seam: loopback bind, static GET only, trusted C for tier-5.

## Performance

Local `bench_http.py --profile ci` (Linux loopback, ~100 B `index.html`):

| Scenario | nginx RPS | li RPS | nginx/li |
|----------|-----------|--------|----------|
| `static_small` | ~65k | ~85k | **< 1** (green) |
| `keepalive_pipelining` | ~72k | ~138k | **< 1** (green) |

Prior gap (~5–9×) was delayed-ACK + `Connection: close` + fork-per-connection, not wrk/nginx config.

## Downstream

- **benchmarks:** re-ingest `vendor/lis-tier5/results/latest.csv` or lis `results/latest.csv` after lic merge.
- Set `LI_HTTPD_EPOLL=0` to force blocking accept loop (debug).
