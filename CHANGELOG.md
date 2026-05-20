# Changelog

All notable changes to Li are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versioning follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **M0 li-httpd bench binary:** `runtime/li_rt_net.c` (POSIX `tcp_*`, static HTTP server), `packages/li-net-httpd` → `build/li-httpd` for tier-5 nginx oracle comparison (`LI_HTTPD_BIN`).
- **Li-native tier-5 httpd:** `packages/li-net-httpd/src/lib.li` — accept loop, keep-alive, pipeline drain, static GET; build with `lic build packages/li-net-httpd/src/lib.li -o build/li-httpd`.
- **Compiler:** two-pass LLVM emit declares imported `extern` before Li bodies; `ptr` returns/params for C handles; `import_name` workspace resolution errors when a module is missing.

### Changed

- **li-httpd runtime seam:** `runtime/li_rt_net.c` — primitives + `*_i` intptr helpers + `httpd_send_*_i` only (no monolithic C `httpd_serve_static_blocking`).
- **li-httpd M1 perf (tier-5):** prior C epoll/M1 loop removed with monolith; loopback RPS regressed until epoll is reintroduced in Li or a thin extern driver (see `docs/release-notes/2026-05-20-li-native-httpd.md`).

### Changed

- Composable imports: workspace `packages/*` (via `import_name` in `li.toml`) resolve before `std/` facades for the same ergonomic path (e.g. `physics.rigid`).
- Docs: `composable-by-default.md`, `import-style.md`, `li-net-httpd` README — `def` + `import net.httpd` (not `li_httpd`).
- Physics docs use monorepo package paths (`li-physics-*`, `import physics.*`); philosophy example uses `def` (no rigid integrate composable test yet).

### Fixed

- Windows CI discovers `LLVM_DIR` via `llvm-config` or `find` when Chocolatey layout differs.
- `packages/li-math-numerics`: remove duplicate `extern proc` contract clauses.

### Changed

- **Breaking:** Li procedure declarations must use `def`; bare `proc` is rejected (keep `extern proc` for FFI). See `docs/release-notes/2026-05-19-enforce-def-syntax.md`.
- Removed agent/history header comments from `li-tests/`, `packages/*/src/`, `std/` facades, and package scaffold template (kept CWE labels in `li-tests/cve_patterns/`).
- `std/` facades use `def`; composable `import physics.relativity` test calls `physics_relativity_std_tag()`.
- Package mirror CI runs `scripts/check-li-def-syntax.sh`; org mirrors `li-std-core`, `li-std-math`, `li-httpd`, `li-net`, `li-demo` have open sync PRs.

### Added

- Agent-first JSON diagnostics: `lic check --format=json`, `lic diagnose` (`docs/schemas/diagnostic-v1.json`)
- LLM-first design research stub, agent handover comparison, `li-agent-manifest.toml`
- `scripts/lic-fix-suggest.sh`, `scripts/gen-li-agent-manifest.sh`, `li-tests/tooling/diagnose_json_smoke.sh`
- Cursor rule `li-llm-first.mdc`, skill `agent-diagnose-fix-li`

## [0.1.0] - 2026-05-14

### Added

- C++ `lic` compiler skeleton: lexer, parser, typechecker, MIR, LLVM codegen
- Mandatory contracts gate (`requires` / `ensures` / `decreases`)
- `li-tests` manifest harness (47 cases)
- Tier-0 benchmark verify + MD stability stress suite
- Cross-language physics benchmark harness (shared C kernels)
- MkDocs documentation site and CI/local-ci tooling

[0.1.0]: https://github.com/li-langverse/lic/releases/tag/v0.1.0
