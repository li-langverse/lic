# li-httpd — full HTTP methods, limits-based hardening, proxy tunnel

## Summary

Proxy/loopback now **forwards the client’s raw request** (all methods, Content-Length and chunked bodies within caps) instead of rebuilding GET-only; static paths return proper **4xx** responses. Smuggling mitigated by **duplicate CL / CL+TE conflict** and size limits, not by banning chunked. Proxy RPS ~**36k** vs ~**78k** nginx on `proxy_loopback` ci (~**+20%** vs prior keep-alive-only fix).

## Agent continuation

1. **Read:** `runtime/li_rt_net.c` — `parse_request_line_c`, `httpd_proxy_forward`, `request_headers_unsafe_c`.
2. **Run:** `LI_HTTPD_BIN=$PWD/build/li-httpd python3 ../benchmarks/vendor/lis-tier5/benchmarks/tier5_http/harness/bench_http.py proxy_loopback --profile ci`.
3. **Then:** epoll-multiplexed upstream (non-blocking relay state machine) for next tranche toward nginx parity.
4. **Blocked on:** splice + upstream fds in same epoll set (not started).

## Changed

| Area | Detail |
|------|--------|
| Protocol | GET/HEAD/POST/PUT/DELETE/PATCH/OPTIONS; chunked + Content-Length bodies up to 1 MiB |
| Harden | Max 128 header lines, 16 KiB headers, 1 MiB body; 400 on smuggling class; 413 on huge CL |
| Proxy | Raw header forward + body pump + 64 KiB relay buffer |
| Static | OPTIONS 204 + Allow; POST without proxy → 405 after body drain |

## Not changed

- TLS, HTTP/2, WebSocket
- Full async upstream epoll (still blocks per connection during proxy relay)

## Breaking

N/A for bench CLI; behavior change: POST/chunked no longer silently dropped — returns 405/413/400.

## Security

Weaponized + pr exploit profiles pass with limits-based handling (chunked bomb → 405/drain, not protocol deny).

## Performance

| Scenario | nginx | li | li/nginx |
|----------|-------|-----|----------|
| proxy_loopback | ~78k | ~36k | ~0.46× |
| static_small | ~85k | ~148k | 1.7× |

## Downstream

benchmarks: update `chunked_encoding_bomb.toml` expectations; re-run `TIER5_EXPLOIT_PROFILE=weaponized`.
