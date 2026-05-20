# Changelog

All notable changes to Li are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versioning follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Fixed-width scalars: `float4`–`float512`, `int4`–`int512` (and aliases); width mismatch is a type error; see `docs/language/scalar-precision.md`.
- Literal suffixes: `3.14f32`, `42i32`, `42u`, `255u8`; binary type + `0b…` literals; `std/binary/binary.li`.
- Documentation: [docs/language/scalar-precision.md](docs/language/scalar-precision.md) (canonical), `packages/li-physics-core/docs/scalar-precision.md`, `std/binary/README.md`; mkdocs + handbook nav; **“You set precision yourself”** (per-module types, suffixes, `li.toml`, physics metadata — no org-wide enforcement).
- `physics.core`: `ScalarPrecision` (`weights_encoding` for binary weights) and profile bit-width metadata (not org-enforced).

### Changed

- **Breaking:** **E0303** — `ensures true` is rejected on non-`unit` return types (non-`extern`); packages and `li-tests` updated with `ensures result == …` or domain bounds. See `docs/release-notes/2026-05-19-enforce-strict-ensures.md`.
- Composable imports: workspace `packages/*` (via `import_name` in `li.toml`) resolve before `std/` facades for the same ergonomic path (e.g. `physics.rigid`).
- Docs: `composable-by-default.md`, `import-style.md`, `li-net-httpd` README — `def` + `import net.httpd` (not `li_httpd`).
- Physics docs use monorepo package paths (`li-physics-*`, `import physics.*`); composable `import_physics_runtime.li` integrates `physics.rigid` once.

### Fixed

- MIR: `object` field access (`a.x`), field assignment, `var` allocation for multi-field objects, and expanded `CallProc` / parameter lists for object-typed arguments (`compiler/mir/lower.cpp`); regression `li-tests/objects/object_field_smoke.li`.
- MIR: `var dst: Obj = src` copies flattened object slots when `src` is an identifier of the same object type (`emit_copy_object_slots_r`); regression `li-tests/objects/object_copy_init.li`.
- MIR + codegen: object-typed procedure returns use LLVM **struct** returns (`ReturnObject`, `MirFn::return_object_layout`); `CallProc` unpacks struct into `__li_o___cr*` temp slots; `var w: T = foo()` when `foo` returns `T` (`li-tests/objects/object_return_call.li`). Implicit fall-through returns for object procedures return a zero-valued struct.
- MIR: whole-object assignment `dst = src` and `dst = foo()` when `dst` is an `object`-typed local/param and `src`/`foo` match (`collect_object_local_types`, `emit_copy_object_slots_r`); regression `li-tests/objects/object_whole_assign.li`.
- MIR: `emit_copy_object_slots_r` copies fixed `array[N, int]` / `array[N, float]` fields element-wise; nested object array slots register in `g_arr_ctx` for index/assign; `Index` / array `Assign` accept `FieldAccess` array bases; regression `li-tests/objects/object_array_field_copy.li`.
- MIR + codegen: `return_object_layout` / LLVM struct returns include fixed `array[N, int|float]` as `[N x T]` members; `ReturnObject` / `CallProc` unpack and expanded params use aggregates; regressions `li-tests/objects/object_array_return_call.li`, `li-tests/objects/object_mixed_scalar_array_return.li`, `li-tests/objects/object_mixed_param_pass.li`.
- Workspace import: `parse_workspace_members` no longer treats `[workspace]` as the `members` array — `import physics.rigid` loads `packages/li-physics-rigid` instead of the std facade stub.
- Parser: multiline `def` parameter lists (indent after `(` / between parameters); bare `return` for `-> unit` procs.
- Windows CI discovers `LLVM_DIR` via `llvm-config` or `find` when Chocolatey layout differs.
- `packages/li-math-numerics`: remove duplicate `extern proc` contract clauses.
- `packages/li-physics-runtime`: `substep_inv` field and `var PhysicsWorld` step APIs (typecheck; codegen crash on full lib build is a known follow-up).

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
