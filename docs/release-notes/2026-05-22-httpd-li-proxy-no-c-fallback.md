# li-httpd — Li proxy default, no C async fallback

## Summary

Reverse proxy mode defaults to the **Li epoll loop**; request bodies (Content-Length and chunked) are handled through `proxy_li_start` / `proxy_li_pump_send` without calling `httpd_proxy_start_async`. Legacy C epoll is opt-in via `LI_HTTPD_PROXY_C=1`.

## Agent continuation

1. **Read:** `packages/li-net-httpd/docs/proxy-nginx-li-migration.md`, `proxy_li_pump_send` in `lib.li`.
2. **Run:** `LI_HTTPD_BIN=build/li-httpd bench_http.py proxy_loopback --profile ci` (default Li). Compare with `LI_HTTPD_PROXY_C=1` for legacy C.
3. **Then:** delete unused C-only proxy dispatch in `httpd_try_drain_once` when Li-only is permanent; trim `httpd_li_proxy_on_*` dead exports if any remain.
4. **Blocked on:** syscall pumps (`httpd_proxy_try_send_*`) still live in `li_rt_net.c` as shims — not a second orchestration path.

## Changed

| Path | Detail |
|------|--------|
| `lib.li` | Removed `httpd_li_proxy_start_i` branch; `proxy_li_pump_send`, `proxy_li_on_client` for SEND_BODY |
| `runtime/li_rt_net.c` | `httpd_li_proxy_init_req_i`; removed `httpd_li_proxy_start_i` / `on_up_i` / `on_client_i`; default Li via `LI_HTTPD_PROXY_C` opt-out |
| `std/runtime/seam.li` | `init_req_i`, `phase_i`; dropped C fallback externs |

## Not changed

- `httpd_proxy_try_send_req` / chunked pump implementation (C shims, Li-orchestrated)
- Static file serving, TLS, HTTP/2
- Full deletion of `httpd_epoll_serve_proxy_i` (still available with `LI_HTTPD_PROXY_C=1`)

## Breaking

Default proxy loop is **Li epoll** (was C unless `LI_HTTPD_PROXY_LI=1`). Use `LI_HTTPD_PROXY_C=1` to restore previous default C path.

## Security

N/A — same body limits (`HTTPD_MAX_BODY`) and header parsing as before.

## Performance

Default Li path: ~154k li vs ~74k nginx on `proxy_loopback` ci (same order as P5).

## Downstream

- benchmarks: no harness change; tier-5 oracle unchanged
