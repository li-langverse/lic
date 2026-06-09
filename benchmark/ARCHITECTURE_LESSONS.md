# Architecture lessons: parallel TLS relay (li-httpd vs field proxies)

Measured numbers live in [`proxy-comparison/results/`](proxy-comparison/results/) and [`RESULTS.md`](RESULTS.md). This document explains **why** industry proxies survive the GitLab parallel-18 gate and what li-httpd should adopt.

## GitLab failure pattern

Browsers open **many parallel TLS connections** to the edge, each fetching a `Content-Length` body (460 B – 1.3 MB). li-httpd must:

1. Terminate TLS on the client side
2. Open or reuse an upstream HTTP connection
3. Relay headers + body **without truncation** while other connections are active

Truncation appears when one connection’s relay is starved: partial body written, or `Content-Length` not fully delivered (`wc -c != Content-Length`).

## How nginx handles parallel upstream→client relay

| Mechanism | Role under parallel load |
|-----------|--------------------------|
| **Multi-worker** (`worker_processes auto`) | Connections spread across OS processes; one slow client does not block the entire server |
| **Per-connection state** | Each client socket has independent `ngx_connection_t`, upstream peer, and buffer chains |
| **Proxy buffers** (`proxy_buffer_size`, `proxy_buffers`, `proxy_busy_buffers_size`) | Upstream data lands in fixed-size pools per request; default **on** copies upstream→memory→client |
| **`proxy_buffering off`** | Streaming mode: smaller memory footprint, relies on **fair write scheduling** and kernel socket buffers |
| **`sendfile`** | Zero-copy static/file paths; proxy path uses buffered relay |
| **Event loop (epoll)** | Edge-triggered read/write; each fd serviced when ready — no global “one relay at a time” |

nginx does **not** truncate under 18 parallel because each request owns buffer chains and workers isolate load. Memory scales roughly with **workers × concurrent requests × buffer footprint** (typically single-digit MB per worker at edge scale — see benchmark RSS column).

## Caddy (Go)

- **Goroutine per connection** with independent `reverse_proxy` state
- Go scheduler multiplexes blocked I/O; TLS + copy run in separate goroutines
- Default flush/coalescing tuned for streaming; memory higher than nginx per connection (Go stacks + TLS buffers) but isolation is strong

## HAProxy

- **Single-process, event-driven** (epoll); excellent fairness across thousands of sockets
- HTTP mode parses enough to forward; body is byte-streamed with per-session buffers
- Very predictable RSS; CPU-efficient under burst parallel

## Why li-httpd fails parallel-18 (pre-fix)

From `li_rt_net.c` / Li proxy loop (feat/dynamic-httpd-routes):

1. **Single-worker or tick-budget relay** — one epoll sweep may service one connection’s pump before yielding; others stall mid-body
2. **Shared upstream or snap path** — contention on upstream pool or response cache under burst
3. **No per-connection fair write queue** — CL relay can exhaust a per-tick byte budget on one fd
4. **TLS + proxy on same thread** — decrypt and upstream relay compete without worker isolation

Recent fix (`tick budget-exhausted CL relays`) addresses (3) partially; benchmark **before/after** on the same commit documents remaining gap vs nginx.

## What li-httpd should adopt

Priority order (from benchmark evidence + nginx model):

1. **Per-connection buffer pools** — fixed-size upstream read buffer + client write buffer per active relay (nginx `proxy_buffers` analogue)
2. **Worker processes ≥ 2** — match `[server] workers = 2` in config; ensure each worker has independent epoll loop and accept (already configured; verify `LI_HTTPD_WORKERS` not forced to 1 in prod entrypoints)
3. **Fair write scheduling** — round-robin or deficit round-robin across active CL relays each epoll tick; never spend entire budget on one connection
4. **Optional `proxy_buffering` mode** — config flag: buffered (copy upstream to pool, then drain to client) vs streaming (`off`); benchmark both for memory/latency tradeoff
5. **Upstream keepalive pool per worker** — avoid thundering herd of upstream connects at parallel-18 (nginx `keepalive 32`)

## Memory tradeoffs (measured 2026-06-09, WSL Docker)

`docker stats` peak during `parallel_18` burst (`results/20260609T203510Z`):

| Proxy | RSS MB (parallel 18) | parallel_18 success | parallel_18 p95 (s) |
|-------|----------------------|---------------------|---------------------|
| **li-httpd** | **11.6** | **0/18** | 60.0 (timeout) |
| **caddy** | 16.3 | 18/18 | 0.014 |
| **haproxy** | 22.2 | 18/18 | 0.045 |
| **nginx** | 32.5 | 18/18 | 0.024 |

li-httpd uses the **least memory** but fails the GitLab gate; field proxies trade 1.4–2.8× RSS for **100% body integrity** under 18-way parallel TLS relay.

Sequential 1.3 MB: all proxies **100%**; li-httpd p95 **0.017 s** vs nginx **0.010 s** (acceptable); gap appears only under concurrent relay.

CPU peak during parallel_18: nginx 2.5%, caddy 3.1%, haproxy 2.9%, li-httpd 2.2% — not CPU-bound; scheduling/buffer fairness is the limiter.

## References

- nginx proxy buffering: [ngx_http_proxy_module](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_buffering)
- li-httpd migration notes: `packages/li-net-httpd/docs/proxy-nginx-li-migration.md`
- Repro assets: `test/proxy-repro/gen-asset.py` (18 GitLab-sized paths)
- Benchmark harness: `benchmark/proxy-comparison/`
