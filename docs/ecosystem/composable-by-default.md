# Composable by default

Every substantial Li feature — HTTP gateway, benchmark runner, package tooling — must ship as a **small, easy-to-compose API** so other Li programs can spawn, control, and tear down services without copy-paste.

**Strict-by-default still applies:** composable surfaces use the same `requires` / `ensures` / `decreases` contracts as any other `proc`. `lic build` remains the certificate path.

## Philosophy

Libraries are **verbs for agents and programs**, not monolithic binaries:

| Verb | Meaning |
|------|---------|
| `serve(config)` | Start a long-lived service (returns a handle) |
| `stop(handle)` | Tear down listeners and workers |
| `ready(handle)` | Await or poll until the service accepts work |

Callers own lifecycle: integration tests, agents, and `def main` in other packages import the library and drive these verbs explicitly.

## Package layout (binding)

| Path | Role |
|------|------|
| `src/lib.li` | **Canonical API** — exported `proc`s, types, lifecycle docs |
| `src/main.li` | **Thin demo only** — imports `lib.li`, wires CLI flags, exits |
| `li-tests/` | Import **`lib`**, not “run the binary and parse stdout” |

Anti-pattern: all logic in `main.li`, no importable module, or a C-only entry with no Li API.

## Anti-patterns

| Anti-pattern | Why it fails composability |
|--------------|----------------------------|
| Monolithic `main` with server loop inline | Other programs cannot `import` and embed |
| Hidden globals (`var g_server`) | No explicit handle; teardown is undefined |
| C-only `main` + no `lib.li` | Li agents cannot prove against or call the feature |
| “Run this shell script to start X” | Not a theorem-checked API |
| Test suite that only execs a binary | Misses import graph and contract surface |

## httpd example (aspirational)

**M1 is not complete** — the shapes below are the target API in `packages/li-httpd/src/lib.li`:

```nim
import li_httpd

def main() -> int
  requires true
  ensures result == 0
  decreases 0
=
  let cfg = HttpdConfig(port=8080)
  let h = httpd_serve(cfg)
  discard httpd_ready(h)
  # ... run tests against h ...
  httpd_stop(h)
  return 0
```

Workspace import name: `li_httpd` (from package `li-httpd`). Network I/O remains behind `raises Net` / `raises Async` until P0 gates in [httpd-prerequisites.md](httpd-prerequisites.md) land.

## Gates for new packages

See [engineering-standards.md](engineering-standards.md) (composability row) and skill `.cursor/skills/composable-li-library/SKILL.md`.

**Checklist before merge:**

1. `src/lib.li` exports lifecycle + config types (even if stubbed).
2. `src/main.li` is optional demo; not the only surface.
3. `li-tests` fixture **imports** the library module (see `li-tests/composable/`).
4. README documents spawn / stop / ready for humans and agents.

## Related

- [httpd-prerequisites.md](httpd-prerequisites.md) — compiler P0 before real `serve`
- [strict-by-default.md](strict-by-default.md) — contracts on composable APIs
- [Language design — Composability](../superpowers/specs/2026-05-14-li-language-design.md#composability-ecosystem-principle)
- Roadmap voice: [contributing-to-roadmap-philosophy.md](contributing-to-roadmap-philosophy.md)
