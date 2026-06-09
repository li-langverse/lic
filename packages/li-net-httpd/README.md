# li-httpd

Proved AI/agent HTTP gateway (Phase H). **M1 not implemented** — blocked on full **2e–2f** Lean gate; see [httpd plan](../../docs/superpowers/plans/2026-05-16-li-httpd-plan.md) and [httpd prerequisites](../../docs/ecosystem/httpd-prerequisites.md).

**Composable by default:** `import net.httpd` from any program; lifecycle lives in `src/lib.li`. `src/main.li` is a thin demo only. See [composable-by-default](../../docs/ecosystem/composable-by-default.md).

Path deps: `li-net`, `li-bytes` (planned), workspace in `lic` `packages/li.toml`.

## Composable API (aspirational — stubs today)

```li
import net.httpd

def main() -> int
  requires true
  ensures result == 0
  decreases 0
=
  var cfg: HttpdConfig
  cfg.port = 8080
  var h: int = httpd_serve(cfg)
  if not httpd_ready(h):
    return 1
  httpd_stop(h)
  return 0
```

Other packages embed the same calls in their own `def main` — no copy-paste of server loop.

## Runtime limits (`[limits]`)

| TOML key | `runtime.conf` key | Default |
|----------|-------------------|---------|
| `max_body` | `max_request_body_bytes` | `1m` |
| `max_header` | `max_header_bytes` | `16k` |
| `proxy_max_response_body` | `max_proxy_response_body_bytes` | `64m` |
| `max_routes` | `max_routes` | `0` (unlimited dynamic route table) |

Set `max_routes` to a positive integer to pre-allocate and cap the route table; config load fails if the flattened config has more routes than the cap.

## Build

```bash
lic build src/lib.li -o /dev/null
lic build src/main.li -o li-httpd-demo   # optional thin demo
```

From the monorepo root, ensure `lic` is built: `./scripts/build.sh`.

## Traceability

| ID | Link |
|----|------|
| Package | `PKG-li-httpd` |
| Org repo | https://github.com/li-langverse/li-httpd |
| Governance | [Ecosystem governance](https://li-langverse.github.io/li-language/ecosystem/governance/) |

See `PUBLISH.md` and `docs/traceability.md`.

## License

Apache-2.0 OR MIT
