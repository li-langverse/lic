# Changelog

All notable changes to Li are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versioning follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Phase 7e-b (partial):** Tier 1 `matmul_naive` pure-Li `@` bench (`li_pure=True`); see `docs/release-notes/2026-05-21-7eb-matmul-pure-li.md`.
- **Phase 2i-c:** 2D `array[M, array[K, float]] @` — shape check, MIR `ArrayMatMul2DF64`, nested index load/store; `li-tests/math_linalg/matmul_*.li`; see `docs/release-notes/2026-05-21-oop-2i-matrix-matmul.md`.
- **Phase 2j-f:** Method call-site `requires` (E0304) + AutoVC for `obj.method()` → `Type_method`; see `docs/release-notes/2026-05-21-oop-2jf-method-vcs.md`.
- **Phase 2j-e:** `type Hash = trait` + `def f[T: Hash]` bounds; static trait impl via `Type_method` procs; see `docs/release-notes/2026-05-21-oop-2je-traits.md`.
- **Phase 2j-d:** `type Derived = object of Base` — flattened layout, static subtyping, `@override` signature checks; `inheritance_*.li` / `override_mismatch.li`; see `docs/release-notes/2026-05-21-oop-2jd-inheritance.md`.
- **Phase 2j-b/c:** `private def` (not exported on `import`); MIR **in-out write-back** for `var` object receivers (`lower_callproc_with_optional_inout`); **7d-c** parallel disjoint via AST `check_module_policies`; see `docs/release-notes/2026-05-21-oop-2jb-2jc-7dc.md`.
- **Cursor rule:** `.cursor/rules/li-test-driven-validation.mdc` — merge review premise (pass/fail `li-tests` prove capabilities).
- **Phase 2j-a:** `obj.method(args)` → `Type_method(self, …)` — parser, typecheck, MIR; `li-tests/encapsulation/def_method_*.li`; see `docs/release-notes/2026-05-20-oop-2ja-method-calls.md`.
- **Phase 2j OOP roadmap** — methods/`self`, traits, inheritance, write-back — `docs/superpowers/plans/2026-05-20-li-oop-roadmap.md`.
- **Language naming conventions** — PascalCase `ClassName` for `type` / `object`; snake_case for `def`, variables, fields; see `docs/language/naming-conventions.md`.
- **Phase 7d-c (partial):** proof builtins `disjoint_elem`, `disjoint_row`, `disjoint_slice`, `row_ok` in typecheck + prelude reserve; see `docs/release-notes/2026-05-20-disjoint-builtins-and-codegen-fixes.md`.

### Fixed

- **`CallProc` codegen:** no store on `-> unit` calls; float literal args + f32/i32 coercion; generic return **E0202**; `str`→`ptr` for bootstrap `strcmp`.
- **Composable physics smoke:** `import_physics_runtime.li` **verify_ok** with stmt-call integrate + post-step `pz` (MIR write-back, exit 0).

### Added

- **`httpd_serve_routed_once`** — M1 one-shot accept + `match_route` for `GET /health` (oracle; parallel with httpd-m1-impl/perf PRs); see `docs/release-notes/2026-05-20-httpd-serve-routed-once.md`.

- **`lic httpd validate-config`** — **E0501–E0504** for io/route key/traversal/overlap; `httpd_serve_once` + `route_key_valid`; see `docs/release-notes/2026-05-20-httpd-validate-serve.md`.

- **`lic httpd explain-config`** — desugar `[routes]` to canonical form; golden `check-httpd-explain-config.sh` (C vs Python); see `docs/release-notes/2026-05-20-httpd-explain-config-cli.md`.

- **Phase H M1:** TOML `[routes]` loader — `load_routes_from_toml`, `match_route`, `load_routes_from_routing_fixture` in `packages/li-http`; `runtime/li_rt_httpd.c`; `li-tests/routing/match_routes_toml.li`; see `docs/release-notes/2026-05-20-httpd-toml-route-loader.md`.

### Changed

- Docs: post-PR **#83** sync — [proof-corpus-roadmap](docs/verification/proof-corpus-roadmap.md) run results (16/16 `contracts_verify`); [httpd-prerequisites](docs/ecosystem/httpd-prerequisites.md) P0-lean partial; master plan + httpd plan tables; see [2026-05-20-post-83-docs-sync](docs/release-notes/2026-05-20-post-83-docs-sync.md).

### Added

- Call-site callee **`requires`**: VCs for all resolved callees (incl. **`extern`** + imports); **E0304** with plain-language precondition text when provably false; const-local discharge (`var y = 5`); **`lic build` fails on open `AutoVC`** unless `LI_ALLOW_OPEN_VC=1`; see `docs/release-notes/2026-05-20-call-site-requires-full-gate.md`.
- **Refinement types** at calls and `var` inits: `{x: int | …}` / aliases (e.g. `NonNeg`); **E0305** when provably outside the bound; **`if n >= 0`** branch discharge; call-site Lean VCs; see `docs/language/refinement-types.md` and `docs/release-notes/2026-05-20-refinement-call-check.md`.
- **2f (branch):** `LI_BUILD_VERIFY_LEAN=1` runs `lean-verify-stub.sh` after build; CI uses `LI_BUILD_VERIFY_LEAN_STRICT=1`.
- **Phase H M1 (branch):** `match_route_fixture` in `packages/li-http`; routing tests + `check-httpd-route-fixture.sh`; see `docs/release-notes/2026-05-20-phase-h-m1-routing-match.md`.
- **`packages/li-http`** workspace package (`import http`) — `parse_request` + GET method-line probe via `li_rt_str_byte_at`.
- Phase H P0 runtime: `bytes_len`/`bytes_slice` in `runtime/li_rt.c`, stub `tcp_*` in `runtime/li_rt_net.c`, `li_rt_str_byte_at` for bounded ASCII inspection.
- Fixed-width scalars: `float4`–`float512`, `int4`–`int512` (and aliases); width mismatch is a type error; see `docs/language/scalar-precision.md`.
- Literal suffixes: `3.14f32`, `42i32`, `42u`, `255u8`; binary type + `0b…` literals; `std/binary/binary.li`.
- Documentation: [docs/language/scalar-precision.md](docs/language/scalar-precision.md) (canonical), `packages/li-physics-core/docs/scalar-precision.md`, `std/binary/README.md`; mkdocs + handbook nav.
- `physics.core`: `ScalarPrecision` (`weights_encoding` for binary weights) and profile bit-width metadata (not org-enforced).

### Changed

- Docs: [docs/compiler/llvm-abi.md](docs/compiler/llvm-abi.md) — MIR → LLVM → clang link map; `str`/`bytes` as `i8*`; `extern` checklist; cross-link from [build-pipeline.md](docs/compiler/build-pipeline.md).
- **Breaking:** **E0303** — `ensures true` is rejected on non-`unit` return types (non-`extern`); see `docs/release-notes/2026-05-19-enforce-strict-ensures.md`.
- Composable imports: workspace `packages/*` (via `import_name` in `li.toml`) resolve before `std/` facades (e.g. `physics.rigid`).
- Docs: `composable-by-default.md`, `import-style.md`, `li-net-httpd` README — `def` + `import net.httpd` (not `li_httpd`).
- Physics docs use monorepo package paths (`li-physics-*`, `import physics.*`); philosophy example uses `def`.
- Composable `import_physics_runtime.li` integrates `physics.rigid` semi-implicit step; `rigid_integrate_semi_implicit` takes `b: var RigidBody`.
- `packages/li-net-httpd`: path deps on `li-http` + `li-net`; `httpd_serve` calls `tcp_listen` (stub).

### Fixed

- **`horner_pure_li` harness honesty** — `li_rt_volatile_sink_f64` prevents LLVM from deleting the pure-Li Horner loop; tier-1 verify rejects pure_li timings < 0.45× native (DCE guard). See `docs/numerics/bench-improver-horner-2026-05-20.md`.
- Proof witnesses: `return callee(lit)` / `return callee(ident)` / multi-return procedures discharge `ensures`; call-site refinement VCs use `collect_caller_proof_facts` (const locals + `if n >= 0`); stdlib coverage harness uses `LI_ALLOW_OPEN_VC=1`.
- Codegen: two-pass LLVM emit so `CallProc` to later MIR functions (e.g. imported `match_route_fixture`) is not dropped; `StringLit` / `bytes` call args use `i8*`; `li-tests/routing/match_routes.li` binary exits 0 (`run_httpd_config.sh`); `import_http_lib` / `parse_request_smoke` compile.
- `std_module_to_path`: single-segment `std.bytes` / `std.csv` now resolve to `std/<name>/<name>.li` (was `std/<name>.li`, breaking `import std.bytes`).
- `import_resolve`: parse full workspace `members = [...]` TOML array; absolute importer paths; error on unresolved imports.
- `li-tests/encapsulation/import_parse.li`: local `import_fixture` module (strict import resolve; replaces placeholder `std_math`).
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
