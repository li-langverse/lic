# li-httpd — Li proxy P5 (snap fast path + epoll spin)

## Summary

When `LI_HTTPD_PROXY_LI=1`, the Li epoll loop serves warmed GET proxy responses from the shared snap buffer and spin-drains ready epoll events after each blocking wait, matching the C `httpd_epoll_serve_i` pattern.

## Agent continuation

1. **Read:** `packages/li-net-httpd/docs/proxy-nginx-li-migration.md` (P5 checklist), `proxy_handle_client_in` / `nginx_proxy_epoll_serve` in `lib.li`.
2. **Run:** `LI_HTTPD_PROXY_LI=1 LI_HTTPD_BIN=build/li-httpd python3 <benchmarks>/vendor/lis-tier5/benchmarks/tier5_http/harness/bench_http.py proxy_loopback --profile ci`.
3. **Then:** make Li epoll default when bench parity holds; remove C proxy branches from `httpd_try_drain_once`; full chunked-req in Li.
4. **Blocked on:** first-request warm-up still does full Li relay before snap is ready; chunked POST bodies still `httpd_li_proxy_start_i` → C.

## Changed

| Path | Detail |
|------|--------|
| `runtime/li_rt_net.c` | `httpd_li_proxy_try_snap_i`, `httpd_li_proxy_snap_ready_i`, `epoll_wait_tagged_spin_i`; snap recording in `mark_active`; `httpd_li_try_start_proxy_i` no longer calls C `httpd_li_proxy_start_i` |
| `packages/li-net-httpd/src/lib.li` | Snap try in `proxy_handle_client_in`; spin loop in `nginx_proxy_epoll_serve` |
| `std/runtime/seam.li` | New trusted externs |
| `compiler/types/trusted_extern.cpp` | Manifest entries |
| `packages/li-net-httpd/docs/proxy-nginx-li-migration.md` | P5 row + checklist |

## Not changed

- Default proxy path without `LI_HTTPD_PROXY_LI` (still C epoll + snap ~2× nginx on loopback)
- TLS, HTTP/2, static file serving outside proxy
- Deletion of `httpd_proxy_forward` / full C proxy removal

## Breaking

N/A — opt-in via `LI_HTTPD_PROXY_LI=1`.

## Security

N/A — same snap bounds (`HTTPD_PROXY_SNAP_MAX`) and header limits as C path.

## Performance

| Mode | Notes |
|------|--------|
| `LI_HTTPD_PROXY_LI=1` | ~154k li vs ~74k nginx (`proxy_loopback` ci, 2026-05-22) |
| Default C | ~158k li vs ~77k nginx (same host, same profile) |

## Downstream

- benchmarks: no catalog change; same `proxy_loopback` scenario
