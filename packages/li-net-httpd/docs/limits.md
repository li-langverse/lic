# li-httpd limits (`[limits]`)

Configure request, header, and proxy response caps in TOML — same role as common **nginx** `client_max_body_size` / buffer limits, with one extra knob for streamed reverse-proxy egress.

**Key style:** all TOML keys use `snake_case` (e.g. `max_body`, not `maxBody`). Canonical guide: [li-httpd `docs/toml-style.md`](https://github.com/li-langverse/li-httpd/blob/main/docs/toml-style.md).

## Quick start (homelab / GitLab edge)

```toml
[limits]
# Inbound request body (git push, LFS, large POST) — nginx: client_max_body_size
max_body = "512m"
# Request header block — nginx: large_client_header_buffers (order-of-magnitude)
max_header = "32k"
# Max streamed proxied *response* body (webpack/JS/CSS/assets)
proxy_max_response_body = "64m"
```

Omit `[limits]` entirely and the **defaults** below apply.

## Fields

| TOML key | runtime.conf | Default | nginx analogue |
|----------|--------------|---------|----------------|
| `max_body` | `max_request_body_bytes` | `1m` | `client_max_body_size` |
| `max_header` | `max_header_bytes` | `16k` | `large_client_header_buffers` (single recv cap) |
| `proxy_max_response_body` | `max_proxy_response_body_bytes` | `64m` | *(no direct limit; nginx streams)* |

### Size syntax

Suffixes are case-insensitive: **`k`**, **`m`**, **`g`** (1024-based, nginx-style).

```toml
max_body = "512m"      # 536870912 bytes
max_header = "32k"
proxy_max_response_body = "128m"
max_body = "1048576"   # plain bytes also allowed
```

Schema caps (DoS guardrails): `max_body` / `proxy_max_response_body` ≤ **512m**, `max_header` ≤ **256k**.

## Behaviour

| Limit | When enforced | HTTP status |
|-------|----------------|-------------|
| `max_body` | Client request `Content-Length` or chunked body to li-httpd | **413** Payload Too Large |
| `max_header` | Request headers exceed recv buffer while parsing | connection drop / **400** |
| `proxy_max_response_body` | Upstream response `Content-Length` or chunked body via `proxy:*` | **502** Bad Gateway |

**Important:** `max_body` applies to **clients → li-httpd**. `proxy_max_response_body` applies to **upstream → client** pass-through only (not static files served from `document_root`).

## Related TOML (not under `[limits]`)

| TOML | Purpose |
|------|---------|
| `[limits].rate_limit_rps` / `rate_limit_burst` | Global token bucket |
| `[limits].stream_idle_timeout` | SSE/stream idle (M1.5) |
| `[health].fail_timeout` | Upstream peer health |
| `nginx.ingress…proxy-body-size` | **Not** li-httpd — use `[limits].max_body` on the edge |

## Apply

After editing TOML:

```bash
python3 scripts/flatten-httpd-config.py your.httpd.toml -o /tmp/httpd.runtime.conf
```

Flatten **always** emits the three limit lines (explicit values or defaults).

## GitLab on lilangverse

GitLab webpack `main.*.chunk.js` is ~**1.3 MiB**. With the old hard-coded **1 MiB** proxy cap, the edge returned **502** and the UI looked unstyled. Set:

```toml
proxy_max_response_body = "64m"   # default; raise only if you serve huge artifacts through the edge
max_body = "512m"                 # match Omnibus / registry upload expectations
```
