# li-httpd — Li-native proxy P2–P4 (response parse, relay, pool)

## Summary

When `LI_HTTPD_PROXY_LI=1`, reverse proxy **response header parse**, **CL relay pump** (via `httpd_proxy_splice_cl_i`), and **upstream pool acquire/release** run in `packages/li-net-httpd/src/lib.li`; C provides syscall shims only.

## Agent continuation

1. **Read:** `packages/li-net-httpd/docs/proxy-nginx-li-migration.md`, `packages/li-net-httpd/src/lib.li` (`proxy_li_*`).
2. **Run:** `LI_HTTPD_PROXY_LI=1 LI_HTTPD_BIN=build/li-httpd bench_http.py proxy_loopback --profile ci` (default path omits env → C epoll + snap).
3. **Then:** retire `httpd_proxy_*` handlers from default `httpd_epoll_serve_i` path; port snap fast path into Li loop.
4. **Blocked on:** chunked request bodies still use `httpd_li_proxy_start_i` → C `httpd_proxy_start_async`.

## Changed

| Path | Detail |
|------|--------|
| `lib.li` | `proxy_li_start` (P4 pool), `proxy_li_finish_resp_headers` (P2), `proxy_li_pump_cl` (P3 splice) |
| `runtime/li_rt_net.c` | Thin `httpd_li_proxy_*` accessors, `mark_active`, `forward_bytes`, `store_resp_cache`, scratch register |
| `std/runtime/seam.li` | New trusted externs for Li proxy state |
| Default proxy | Still `httpd_epoll_serve_proxy_i` + snap (~2× nginx on `proxy_loopback`) |

## Not changed

- Default production proxy path (no `LI_HTTPD_PROXY_LI`) — still C epoll + snap
- TLS / HTTP/2
- Full deletion of `httpd_proxy_pump_relay` in C

## Breaking

N/A — opt-in via `LI_HTTPD_PROXY_LI=1`.

## Performance

| Mode | Notes |
|------|--------|
| Default (C + snap) | ~157k li vs ~76k nginx (3-run sample) |
| `LI_HTTPD_PROXY_LI=1` | Li loop; verify on target host before making default |

## Downstream

- benchmarks: no harness change
