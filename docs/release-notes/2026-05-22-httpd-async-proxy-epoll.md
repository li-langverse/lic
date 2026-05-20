# li-httpd — non-blocking async upstream proxy (epoll)

## Summary

`runtime/li_rt_net.c` multiplexes reverse-proxy upstream I/O on the same epoll set as clients (edge-triggered relay state machine) so one blocked upstream no longer stalls the reactor; `proxy_loopback` ci ~**57k** li RPS vs ~**73k** nginx (~**0.79×**, up from ~0.46× sync tunnel).

## Agent continuation

1. **Read:** `runtime/li_rt_net.c` — `httpd_proxy_start_async`, `httpd_proxy_pump_relay`, `httpd_proxy_relay_maybe_done`, `g_httpd_epfd`.
2. **Run:** `LI_REPO_ROOT=$PWD ./build/compiler/lic/lic build packages/li-net-httpd/src/lib.li -o build/li-httpd` then `LI_HTTPD_BIN=$PWD/build/li-httpd python3 ../benchmarks/vendor/lis-tier5/benchmarks/tier5_http/harness/bench_http.py proxy_loopback --profile ci`.
3. **Then:** chunked POST async path (today still `httpd_proxy_forward` blocking); optional `splice` body relay; parse upstream `Content-Length` for stricter relay completion.
4. **Blocked on:** none for this tranche; tier5 `lb_peer_down` verify flake is harness/backend-kill timing (separate).

## Changed

| Area | Detail |
|------|--------|
| Async proxy | `httpd_slot_t` proxy phases (`SEND_REQ` / `SEND_BODY` / `RELAY`); upstream fd on `g_httpd_epfd`; `httpd_try_drain_once` returns `0` while proxy active |
| Relay done | `httpd_proxy_relay_maybe_done` after first upstream bytes + `poll(POLLIN,0)<=0` (keep-alive safe, not EOF-only) |
| Pool | `proxy_up_reuse = client keep-alive`; drain readable bytes on pool acquire/release; ET immediate `httpd_proxy_pump_relay` on `RELAY` entry |
| Bench | `proxy_loopback` / `lb_*` ci rows emit `lang=li` RPS again (urllib verify no longer poisons pool) |

## Not changed

- Chunked client bodies on proxy (still blocking `httpd_proxy_forward`)
- TLS / HTTP/2 / WebSocket
- `lic` compiler, `std/**`, master-plan PH order
- benchmarks exploit TOMLs (weaponized still passes unchanged)

## Breaking

N/A — internal runtime seam only; CLI unchanged.

## Security

N/A — exploit profiles (`pr`, `weaponized`) still 0 fail with limits-based handling.

## Performance

| Scenario (ci) | nginx RPS | li RPS | li/nginx |
|---------------|-----------|--------|----------|
| proxy_loopback | ~73k | ~58k | ~0.79× |
| lb_round_robin | ~69k | ~54k | ~0.78× |
| static_small | ~84k | ~128k | ~1.5× |

Evidence: local `harness/bench_http.py --profile ci` after `build/li-httpd`.

## Downstream

- **benchmarks:** ingest optional; dashboard category `tier5_http` unchanged
- **li-httpd package:** no `lib.li` API change; still `httpd_epoll_serve_i` entry
