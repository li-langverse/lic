# li-httpd M1 wave 2 — loopback reverse proxy

## Summary

Adds loopback-only reverse proxy (`httpd_set_proxy_upstream_port_i`, CLI `li-httpd FRONT_PORT DOC_ROOT BACKEND_PORT`) and tier-5 `proxy_loopback` harness scenario (nginx oracle + li row).

## Agent continuation

1. **Read:** `runtime/li_rt_net.c` (`httpd_proxy_forward`, `path_proxy_match`); `packages/li-net-httpd/src/lib.li` (`httpd_serve_port_root_proxy`); `vendor/lis-tier5/.../proxy_loopback/bench.toml`.
2. **Run:** `lic build packages/li-net-httpd/src/lib.li -o build/li-httpd`; backend `li-httpd 18081 $ROOT`; front `li-httpd 18080 $ROOT 18081`; `bench_http.py proxy_loopback --profile ci`.
3. **Then:** upstream keep-alive pool (close perf gap vs nginx); M1 wave 3 LB; route table from validated TOML.
4. **Blocked on:** non-loopback upstream hosts until allowlist + config loader lands.

## Changed

| Path | Evidence |
|------|----------|
| `runtime/li_rt_net.c` | `httpd_set_proxy_upstream_port_i`, `httpd_proxy_forward`, `/v1` prefix or proxy-all |
| `packages/li-net-httpd/src/lib.li` | argv[4] backend port → proxy mode |
| `packages/li-httpd/examples/proxy_loopback.toml` | upstream + route example |
| `scripts/validate-httpd-config.py` | nested `[upstreams.*]`, proxy route allowlist |
| `docs/superpowers/plans/2026-05-16-li-httpd-plan.md` | wave 2 active, proxy status |

## Not changed

- Upstream connection reuse (new TCP per request today).
- Load balancing algorithms (wave 3).
- TLS / HTTP/2.

## Breaking

N/A — opt-in via fourth CLI argument.

## Security

Upstream host restricted to `127.0.0.1` / `::1` in C; config validator rejects non-loopback peer URLs.

## Performance

`proxy_loopback` (`bench_http.py --profile ci`, wrk `/`):

| lang | RPS (approx) |
|------|----------------|
| nginx | 77,284 |
| li | 16,824 |

Li proxy path uses connect-per-request; nginx keeps upstream keepalive. Target for next perf pass.

## Downstream

- **benchmarks:** `catalog.toml` `proxy_loopback`; `suite.toml` includes scenario; harness `bench_proxy_loopback_scenario`.
