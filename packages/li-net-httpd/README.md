# li-httpd

Proved AI/agent HTTP gateway (Phase H). **M1 `.li` routing not implemented** — **2e–2f proof gate ready on branch** `cursor/refinement-call-check-57b4` (merge then start M1); see [httpd plan](../../docs/superpowers/plans/2026-05-16-li-httpd-plan.md) and [phase completion](../../docs/ecosystem/phase-completion-2026-05-20.md).

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
