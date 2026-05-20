# li-httpd proxy perf + weaponized exploit hardening

## Summary

Proxy/LB paths keep client **keep-alive** after upstream forward, **pre-warm 32** upstream sockets per peer, and reject **chunked/POST/oversized headers**; tier-5 **weaponized** exploit profile (20 attacks × 3 oracles) passes with 0 failures.

## Agent continuation

1. **Read:** `runtime/li_rt_net.c` (`httpd_try_drain_once` proxy return, `upstream_pool_prewarm_all`, `request_headers_unsafe_c`).
2. **Run:** `LI_HTTPD_BIN=$PWD/build/li-httpd python3 ../benchmarks/vendor/lis-tier5/benchmarks/tier5_http/harness/bench_http.py --profile ci` — compare `proxy_loopback` li vs nginx.
3. **Then:** non-blocking upstream epoll state machine for next ~2× proxy RPS jump.
4. **Blocked on:** full async proxy without blocking `read()` in `httpd_proxy_forward`.

## Changed

| Area | Path |
|------|------|
| Perf | `HTTPD_POOL_PER_PEER` 32, `upstream_pool_prewarm_all`, proxy keep-alive return `1` |
| Harden | reject chunked TE, duplicate CL, >64 header lines, non GET/HEAD |
| Bench | `suite_exploits.toml` profile `weaponized`, `harness/drivers/http_weaponized.py` |
| CI | `ci.yml` runs weaponized after pr |

## Not changed

- Static / pipelining hot path (already beats nginx).
- TLS, HTTP/2, non-blocking upstream multiplex (M2).

## Breaking

N/A

## Security

Weaponized tier W: chunked bomb, cache poison headers, pipeline stuffing, smuggling variants — see benchmarks exploit CSV.

## Performance

Re-bench `proxy_loopback` / `lb_*` after keep-alive + pool prewarm (target: cut gap vs nginx).

## Downstream

benchmarks PR: weaponized profile + CI gate.
