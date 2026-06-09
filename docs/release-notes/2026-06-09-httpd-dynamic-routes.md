# li-httpd dynamic route table (2026-06-09)

Runtime route matching no longer uses a compile-time `HTTPD_MAX_ROUTES` cap. The C loader in `runtime/li_rt_net.c` keeps routes in a heap table that grows by doubling (initial capacity 32).

## Config: `[limits] max_routes`

| Value | Behavior |
|-------|----------|
| omitted or `0` | **Unlimited** dynamic growth (default). Routes are never silently dropped. |
| `N > 0` | Pre-allocate capacity `N` and **hard-cap** the table. Extra `route=` lines in `runtime.conf` are rejected with a stderr error; config load fails. |

Flattened key in `runtime.conf`: `max_routes=N` (emitted only when `N > 0`).

TOML example:

```toml
[limits]
max_body = "1m"
max_header = "16k"
proxy_max_response_body = "64m"
# max_routes = 0   # default: unlimited (omit or set 0)
# max_routes = 512 # optional hard cap for memory-bound edges
```

Python flatten: `scripts/httpd_limits.py` (`limits.max_routes`). Homelab edge builds no longer patch `HTTPD_MAX_ROUTES` in `build-edge-li-httpd.sh`.
