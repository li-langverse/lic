# li-httpd M1 wave 3 — upstream pool, LB RR, runtime config

## Summary

Adds keep-alive upstream connection pooling, round-robin multi-peer proxy (`PORT ROOT p1,p2,p3`), flattened runtime config (`li-httpd path.runtime.conf`), and `lb_round_robin` tier-5 scenario.

## Agent continuation

1. **Read:** `runtime/li_rt_net.c` (`upstream_pool_*`, `httpd_proxy_forward`, `httpd_load_runtime_config_i`); `scripts/flatten-httpd-config.py`.
2. **Run:** `python3 scripts/flatten-httpd-config.py examples/proxy_loopback.toml -o /tmp/x.conf`; `./build/li-httpd /tmp/x.conf`; `bench_http.py proxy_loopback lb_round_robin --profile ci`.
3. **Then:** least_conn LB; upstream health; in-process TOML parse or `lic validate-config` hook.
4. **Blocked on:** non-loopback upstream peers until allowlist expansion.

## Changed

| Path | Evidence |
|------|----------|
| `runtime/li_rt_net.c` | Upstream pool (4 conn/peer), Content-Length response drain, RR peer pick |
| `packages/li-net-httpd/src/lib.li` | CSV backends argv[3]; `.conf` single-arg mode |
| `scripts/flatten-httpd-config.py` | TOML → `httpd.runtime.conf` |
| `std/runtime/seam.li`, `trusted_extern.cpp` | New upstream/config symbols |

## Not changed

- `lic validate-config` subcommand (still Python scripts).
- TLS, HTTP/2, least_conn, passive health.

## Performance

| Scenario | nginx RPS | li RPS (approx) |
|----------|-----------|-----------------|
| `proxy_loopback` | 79,902 | 30,280 (was ~17k pre-pool) |
| `lb_round_robin` (3 peers) | 70,842 | 30,146 |

## Downstream

- **benchmarks:** `lb_round_robin` scenario + harness multi-backend + `catalog.toml` row.
