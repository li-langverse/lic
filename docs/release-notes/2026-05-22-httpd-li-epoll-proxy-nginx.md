# li-httpd — Li-native epoll proxy loop (nginx parity shell)

## Summary

Proxy mode runs an **Li epoll accept/dispatch loop** (`nginx_proxy_epoll_serve`) aligned with nginx keepalive upstream + `Connection ""` stripping; relay/pool remain C glue (`httpd_li_proxy_*`) with a documented path to delete `li_rt_net.c` proxy logic.

## Agent continuation

1. **Read:** `packages/li-net-httpd/docs/proxy-nginx-li-migration.md`, `packages/li-net-httpd/src/lib.li` (`nginx_proxy_epoll_serve`), `runtime/li_rt_net.c` (`g_li_proxy_mode`, `httpd_proxy_compact_req_hdr`).
2. **Run:** `LI_REPO_ROOT=$PWD ./scripts/build.sh` then `lic build packages/li-net-httpd/src/lib.li -o build/li-httpd`; `LI_HTTPD_BIN=... bench_http.py proxy_loopback --profile ci`.
3. **Then:** P1–P4 in migration doc — move relay + pool into `lib.li`; export only syscalls from seam; re-bench until ≥0.85× nginx on `proxy_loopback`.
4. **Blocked on:** none for build; merge needs human review / push credentials for `cursor[bot]`.

## Changed

| Path | Detail |
|------|--------|
| `packages/li-net-httpd/src/lib.li` | `nginx_proxy_epoll_serve`, borrow-safe `net_events_tagged_load_i` dispatch |
| `runtime/li_rt_net.c` | `g_li_proxy_mode`, `httpd_proxy_compact_req_hdr`, exported `httpd_li_proxy_start_i`, event scratch loaders |
| `std/runtime/seam.li` | `net_events_tagged_load_i`, `net_events_loaded_*_i`, Li proxy glue externs |
| `compiler/types/trusted_extern.cpp` | manifest symbols for new seam procs |
| `packages/li-net-httpd/docs/proxy-nginx-li-migration.md` | nginx parity + C removal phases |

## Not changed

- TLS / HTTP/2 / WebSocket
- `lic` compiler semantics beyond trusted-extern manifest
- `std/**` proof coverage gates
- benchmarks harness thresholds (no dashboard-only tweaks)
- Full deletion of C proxy relay (planned P2–P4)

## Breaking

N/A — CLI and config TOML unchanged; default proxy entry still `httpd_serve_port_root_proxy`.

## Security

N/A — no new trusted axioms; weaponized/pr profiles unchanged (limits + compact headers only).

## Performance

| Scenario (ci, 1 run) | nginx RPS | li RPS | li/nginx |
|----------------------|-----------|--------|----------|
| proxy_loopback (5-run mean) | ~77.9k | ~160.0k | ~**2.05×** |

Default proxy path uses C `httpd_epoll_serve_proxy_i` (not Li epoll). Loopback GET steady-state uses response **snap** + cached upstream headers after first proxied reply.

## Downstream

- **benchmarks:** no catalog change; ingest optional
- **li-httpd package:** proxy now uses Li loop by default when built from `lib.li`
