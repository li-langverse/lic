# Changelog

All notable changes to Li are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versioning follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **li-httpd Li epoll proxy loop (nginx parity shell):** `nginx_proxy_epoll_serve` in `lib.li`, `Connection` header strip toward upstream, migration plan to drop C proxy — [2026-05-22-httpd-li-epoll-proxy-nginx.md](docs/release-notes/2026-05-22-httpd-li-epoll-proxy-nginx.md).
- **li-httpd async upstream proxy (epoll):** chunked/CL response parse, splice CL pump, loopback perf (~0.77× nginx `proxy_loopback`, up from ~0.66×) — [2026-05-22-httpd-async-proxy-epoll.md](docs/release-notes/2026-05-22-httpd-async-proxy-epoll.md).

### Added

- **li-httpd full HTTP + proxy tunnel:** all methods, chunked/CL bodies with limits, raw request forward on proxy — [2026-05-22-httpd-full-http-proxy-tunnel.md](docs/release-notes/2026-05-22-httpd-full-http-proxy-tunnel.md).

### Added

- **li-httpd proxy perf + weaponized hardening:** client keep-alive after proxy, 32-socket upstream prewarm, chunked/POST/header limits — [2026-05-21-httpd-proxy-perf-weaponized.md](docs/release-notes/2026-05-21-httpd-proxy-perf-weaponized.md).

### Added

- **li-httpd M1 wave 4:** `least_conn` LB, `httpd_mark_upstream_peer_down_i`, `path_is_safe` rejects `%` and `\`; `scripts/audit-nginx-mitigations.py` — see [2026-05-21-httpd-m1-wave4-exploits.md](docs/release-notes/2026-05-21-httpd-m1-wave4-exploits.md).

### Added

- **li-httpd M1 wave 3:** upstream keep-alive pool, RR LB (`httpd_set_upstream_ports_csv_i`), `httpd_load_runtime_config_i` + `scripts/flatten-httpd-config.py`; `lb_round_robin` bench.
- **li-httpd M1 wave 2:** loopback reverse proxy (`httpd_set_proxy_upstream_port_i`, CLI `PORT ROOT BACKEND_PORT`); `proxy_loopback` tier-5 scenario; `examples/proxy_loopback.toml`.
- **li-httpd M1 wave 1:** generic static GET + sendfile in `httpd_epoll_serve_i` hot path; `packages/li-httpd/examples/minimal.toml`; `scripts/validate-httpd-config.py`.
- **Trusted runtime ABI:** `std/runtime/seam.li` canonical `extern proc` surface for `li_rt.c` / `li_rt_net.c`; compiler gate **E0331** (`check_trusted_extern_abi`); docs `docs/compiler/trusted-extern-abi.md`.
- **M0 li-httpd bench binary:** `runtime/li_rt_net.c` (POSIX `tcp_*`, static HTTP server), `packages/li-net-httpd` → `build/li-httpd` for tier-5 nginx oracle comparison (`LI_HTTPD_BIN`).
- **Li-native tier-5 httpd:** `packages/li-net-httpd/src/lib.li` — accept loop, keep-alive, pipeline drain, static GET; build with `lic build packages/li-net-httpd/src/lib.li -o build/li-httpd`.
- **Compiler:** two-pass LLVM emit declares imported `extern` before Li bodies; `ptr` returns/params for C handles; `import_name` workspace resolution errors when a module is missing.

### Changed

- **li-httpd runtime seam:** `runtime/li_rt_net.c` — syscall + M1 epoll hot path (`httpd_epoll_serve_i`: recv-until-`EAGAIN`, prebuilt keep-alive blobs, level-triggered `EPOLLIN`, `epoll_wait(0)` spin); Li loop remains fallback when epoll unavailable.
- **li-httpd tier-5 perf:** loopback `bench_http.py --profile ci` — `static_small` li ~160k vs nginx ~85k RPS (~1.9×); `keepalive_pipelining` li ~319k vs nginx ~91k RPS (~3.5×); `static_large` li ~9.6k vs nginx ~9.4k RPS (~1.02×) on 1 MiB `/file.bin` (2026-05-21).
- **li-httpd epoll (tier-5):** `packages/li-net-httpd` routes `httpd_serve_static_blocking` → `httpd_epoll_serve_i`; `httpd_prepare_root_i` caches `index.html` + response blobs; Li epoll loop when cache missing or non-Linux epoll stub.
- **li-net:** expanded `extern proc` surface; use `var ptr` / `var int` on extern params that must not move caller locals (borrow checker).

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
