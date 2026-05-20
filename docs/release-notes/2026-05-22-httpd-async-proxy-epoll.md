# li-httpd — non-blocking async upstream proxy (epoll)

## Summary

`runtime/li_rt_net.c` async epoll proxy covers chunked bodies, response framing, splice relay, and **loopback perf pass** (no hot-path `poll`, CL splice pump, conditional pool drain, epoll slot tags, keep-alive pipeline recv); `proxy_loopback` ci ~**58k** li vs ~**76k** nginx (~**0.77×**, was ~0.66×).

## Agent continuation

1. **Read:** `runtime/li_rt_net.c` — `httpd_proxy_try_send_chunked`, `httpd_proxy_resp_feed`, `httpd_proxy_resp_finish_headers`, `httpd_proxy_splice_once`, `proxy_client_epoll_events`.
2. **Run:** `LI_REPO_ROOT=$PWD ./build/compiler/lic/lic build packages/li-net-httpd/src/lib.li -o build/li-httpd` then `LI_HTTPD_BIN=$PWD/build/li-httpd python3 <benchmarks>/vendor/lis-tier5/benchmarks/tier5_http/harness/bench_http.py proxy_loopback --profile ci`.
3. **Then:** client pipelining during active proxy; non-blocking pool connect under saturation; optional Apache `mod_proxy` oracle in harness (benchmarks repo).
4. **Blocked on:** none for tranches 1–2; follow [proxy-nginx-li-migration.md](../../packages/li-net-httpd/docs/proxy-nginx-li-migration.md) for Li epoll loop + C removal.

## Changed

| Area | Detail |
|------|--------|
| Async proxy | `httpd_slot_t` proxy phases (`SEND_REQ` / `SEND_BODY` / `RELAY`); upstream fd on `g_httpd_epfd`; `httpd_try_drain_once` returns `0` while proxy active |
| Chunked req | `httpd_proxy_try_send_chunked` — async pass-through; blocking `httpd_proxy_forward` removed from `httpd_try_drain_once` |
| Response parse | `httpd_proxy_resp_feed` + `parse_response_body_meta_c`; forwards full upstream headers then body with CL/chunked/close completion |
| Splice | `httpd_proxy_pump_cl_relay` + `splice` from 512 B; dedicated CL pump until `body_left==0` |
| Epoll | `HTTPD_EPOLL_*_TAG` slot tags; cached MOD masks; finish_ok recv+drain for pipelined keep-alive |
| Pool | `FIONREAD` before drain on acquire/release (skip idle syscalls) |
| Relay done | `httpd_proxy_relay_maybe_done` uses `proxy_resp_body_left` / chunked terminal chunk, not poll-only |
| Pool | `proxy_up_reuse = client keep-alive`; drain on pool acquire/release |

## Not changed

- Blocking `httpd_proxy_forward` still exists for non-epoll fallback paths (unused on Linux epoll serve)
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
| proxy_loopback | ~76k | ~58k | ~0.77× (3-run mean) |
| lb_round_robin | ~69k | ~55k | ~0.80× |
| static_small | ~84k | ~128k | ~1.5× |

Evidence: local `harness/bench_http.py --profile ci` after `build/li-httpd`.

## Downstream

- **benchmarks:** ingest optional; dashboard category `tier5_http` unchanged
- **li-httpd package:** no `lib.li` API change; still `httpd_epoll_serve_i` entry
