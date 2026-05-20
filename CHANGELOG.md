# Changelog

All notable changes to Li are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versioning follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Fixed-width scalars: `float4`–`float512`, `int4`–`int512` (and aliases); width mismatch is a type error; see `docs/language/scalar-precision.md`.
- Literal suffixes: `3.14f32`, `42i32`, `42u`, `255u8`; binary type + `0b…` literals; `std/binary/binary.li`.
- Documentation: [docs/language/scalar-precision.md](docs/language/scalar-precision.md) (canonical), `packages/li-physics-core/docs/scalar-precision.md`, `std/binary/README.md`; mkdocs + handbook nav; **“You set precision yourself”**; **integer inner loops / fixed-point rescale** + compiler warning roadmap.
- Compiler: **W0601** / **E0303** — vacuous `ensures` on value-returning `def` (warn by default; error with `--strict-contracts` or `LI_STRICT_CONTRACTS=1`); includes tautologies (`result == result`, `true or …`), structural `Expr` equality; see `docs/language/contracts-and-proofs.md`.
- Scripts: **`scripts/audit-strict-good-contracts.sh`** — spot-check proof-style `.li` under strict mode.
- Docs: release note `docs/release-notes/2026-05-20-strict-trivial-ensures.md`.
- Docs: [numerics-in-practice.md](docs/language/numerics-in-practice.md) with real-world `x` examples and macOS-style terminal renderings (`terminal.css`).
- `physics.core`: `ScalarPrecision` (`weights_encoding` for binary weights) and profile bit-width metadata (not org-enforced).

### Changed

- Composable imports: workspace `packages/*` (via `import_name` in `li.toml`) resolve before `std/` facades for the same ergonomic path (e.g. `physics.rigid`).
- Docs: clarify `def` / `while` **`=`** as body delimiter (not assignment to `decreases`) in `overview.md`, `hello-world.md`, `control-flow-and-functions.md`, `contracts-and-proofs.md`.
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
