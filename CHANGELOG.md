# Changelog

All notable changes to Li are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versioning follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- **PH-UX vertical gap #1:** Studio UI bench registry and `bench-studio-viewport-perf.sh` reference `packages/lig` (`wgpu_smoke` hook) instead of removed `packages/li-gpu` — [2026-05-25-vertical-gap-bench-lig.md](docs/release-notes/2026-05-25-vertical-gap-bench-lig.md).

### Added

- **G-proof-db (gap2):** three `L-MATH-*` catalog registrations + `proof-db-gap2-report.sh` — [2026-05-25-gap2-proof-db.md](docs/release-notes/2026-05-25-gap2-proof-db.md).
- **Studio MCP gap #6/#7 (contracts):** eight tool IDs (`am_export_print`, `chem_dft_run`, `studio_adaptive_layout`), `studio_mcp_tool_dispatch` stub, `li-chem` `chem_dft_run_smoke`, smokes `studio_mcp_extended.li` / composable chem — [2026-05-25-vertical-gap-mcp-chem.md](docs/release-notes/2026-05-25-vertical-gap-mcp-chem.md).

- **Vertical gap #4/#9 sim step physics** — `sim_scientific_tick_stub`, `studio_game_step_hook`, `studio_md_particle_tier_select_ok`, smokes `studio_sim_step_by_profile.li` / `import_studio_sim_step_by_profile.li` — [2026-05-25-vertical-gap-sim-step-physics.md](docs/release-notes/2026-05-25-vertical-gap-sim-step-physics.md).

- **Vertical gap #2/#10 native present (partial):** `STUDIO_DEMO_PROFILE` env wiring, `li_rt` lig host present restore, `li-studio-demo` verticals capture preference — [2026-05-26-vertical-gap-native-present.md](docs/release-notes/2026-05-26-vertical-gap-native-present.md).

### Added

- **PH-SIM vertical gap #3:** domain profile stubs `li-sim-automotive`, `li-sim-robotics`, `li-sim-additive`, `li-sim-drug-design` (`import sim.*`, contract + studio id constants, `lic check` smokes) — [2026-05-26-vertical-sim-domain-stubs.md](docs/release-notes/2026-05-26-vertical-sim-domain-stubs.md).

- **PH-UX vertical gap #5:** Full `lig-kernels.toml` catalog rows (`md_force_short`, `heat_stencil_2d_f32`, …), `cuda`/`hip`/`metal` = `N/A` until `LIG_EMIT_*`, parity harness emits all `kernel_ids` — [2026-05-25-vertical-gap-lig-kernels.md](docs/release-notes/2026-05-25-vertical-gap-lig-kernels.md).


- **PH-HW integration (`lig` + studio gap):** Rollup for multi-vendor GPU work packages WP1–WP5 ([#217](https://github.com/li-langverse/lic/pull/217), [#218](https://github.com/li-langverse/lic/pull/218), [#213](https://github.com/li-langverse/lic/pull/213), [#220](https://github.com/li-langverse/lic/pull/220), [#222](https://github.com/li-langverse/lic/pull/222)) and merged `studio-gap-close-wave1` (UX/MCP/sim/world) on `feat/ph-hw-multi-vendor` — [2026-05-25-lig-ph-hw-integration.md](docs/release-notes/2026-05-25-lig-ph-hw-integration.md).

- **2i / G-math (tracker):** `norm_non_array.li` compile_fail for scalar `norm` — `docs/release-notes/2026-05-25-2i-norm-plan-tracker.md`.

### Added

- **Gap closure queue (Phase 2a audit):** `docs/verification/GAP_CLOSURE_QUEUE.md` — prioritized open gaps excluding open PRs — [2026-05-25-gap-closure-queue.md](docs/release-notes/2026-05-25-gap-closure-queue.md).

### Added

- **G-dec (partial):** `check_mir_vectorized_decorator.sh` in `contracts_discharge_corpus.sh` + master-plan gates; provability-gaps **G-dec** / **P-dec** sync — `docs/release-notes/2026-05-25-g-dec-gap-close-corpus.md`.

### Added

- **Vertical gap #4/#9 sim step physics** — `sim_scientific_tick_stub`, `studio_game_step_hook`, `studio_md_particle_tier_select_ok`, smokes `studio_sim_step_by_profile.li` / `import_studio_sim_step_by_profile.li` — [2026-05-25-vertical-gap-sim-step-physics.md](docs/release-notes/2026-05-25-vertical-gap-sim-step-physics.md).

### Fixed

- **PH-UX vertical gap #1:** Studio UI bench registry and `bench-studio-viewport-perf.sh` reference `packages/lig` (`wgpu_smoke` hook) instead of removed `packages/li-gpu` — [2026-05-25-vertical-gap-bench-lig.md](docs/release-notes/2026-05-25-vertical-gap-bench-lig.md).

### Added

- **P-physics proof database:** `docs/verification/proof-database/entries/physics-*.toml` (`P-AX-*`, `P-LM-*`); tier-2 bench refs; scalar lemmas in `Discharge.lean` — [2026-05-25-proof-db-physics-axioms.md](docs/release-notes/2026-05-25-proof-db-physics-axioms.md).
- **Proof-db sweep reporter:** `scripts/proof-db-report.sh`, `proof-db/expected.json`, `discrepancies.toml`, `reporter.md` — [2026-05-25-proof-db-sweep-reporter.md](docs/release-notes/2026-05-25-proof-db-sweep-reporter.md).

### Added

- **Proof DB lemma rebuild:** `scripts/proof-db/rebuild_lemmas.sh` → `data/proof-db/latest-report.{json,md}` from `docs/verification/proof-database/entries/` — [2026-05-25-proof-db-rebuild-pipeline.md](docs/release-notes/2026-05-25-proof-db-rebuild-pipeline.md).
- **Proof-db discrepancy analyzer:** `scripts/proof-db/compare_reference.py`, `proof-database/DISCREPANCIES.md` — [2026-05-25-proof-db-discrepancies.md](docs/release-notes/2026-05-25-proof-db-discrepancies.md).
- **Proof-db CI release gate:** `proof-db/baseline.jsonl`, `scripts/check-proof-db.sh`, advisory `LI_PROOF_DB_STRICT` in `scripts/ci.sh` — [2026-05-25-proof-db-ci-gate.md](docs/release-notes/2026-05-25-proof-db-ci-gate.md).
- **Proof-db sweep reporter:** `scripts/proof-db-report.sh`, `proof-db/expected.json`, `discrepancies.toml`, `reporter.md` — [2026-05-25-proof-db-sweep-reporter.md](docs/release-notes/2026-05-25-proof-db-sweep-reporter.md).

### Added

- **Classical math proof database:** `docs/semantics/proof-db/math/`, `docs/verification/proof-database/entries/math-*.toml` (`M-AX-*`, `M-LM-*`), `lake build ProofDbMath` — [2026-05-25-proof-db-math-axioms.md](docs/release-notes/2026-05-25-proof-db-math-axioms.md).

### Added

- **Execution surface docs:** specs `2026-05-25-li-execution-surface.md`, `2026-05-25-li-execution-resources.md`; handbook `docs/language/parallelism.md` — [2026-05-25-execution-surface-docs.md](docs/release-notes/2026-05-25-execution-surface-docs.md).
- **Proof DB lemma rebuild:** `scripts/proof-db/rebuild_lemmas.sh` → `data/proof-db/latest-report.{json,md}` — [2026-05-25-proof-db-rebuild-pipeline.md](docs/release-notes/2026-05-25-proof-db-rebuild-pipeline.md).
- **Proof-db discrepancy analyzer:** `scripts/proof-db/compare_reference.py`, `proof-database/DISCREPANCIES.md` — [2026-05-25-proof-db-discrepancies.md](docs/release-notes/2026-05-25-proof-db-discrepancies.md).
- **Proof database (v0):** `docs/verification/proof-database.md`, `proof-db/` manifest (axioms/lemmas + `release_pin`), `scripts/check-proof-db.sh` CI smoke — [2026-05-25-proof-database-arch.md](docs/release-notes/2026-05-25-proof-database-arch.md).
- **P-physics proof database:** `docs/verification/proof-database/entries/physics-*.toml` (`P-AX-*`, `P-LM-*`); tier-2 bench refs; scalar lemmas in `Discharge.lean` — [2026-05-25-proof-db-physics-axioms.md](docs/release-notes/2026-05-25-proof-db-physics-axioms.md).
- **G-trust (Partial+):** **T-GetElem** (`typing_getElem`) in `docs/semantics/Core.lean` — [2026-05-25-g-trust-core-getelem.md](docs/release-notes/2026-05-25-g-trust-core-getelem.md).

### Added

- **Proof DB (2f slice):** `proof-db/index.json` + `proof-db/lean/ProofDB.lean` — five standard lemmas (4 proved, 1 `sorry`); `lake build ProofDB` — [2026-05-25-proof-db-lean-bridge.md](docs/release-notes/2026-05-25-proof-db-lean-bridge.md).

### Added

- **Proof DB (2f slice):** `proof-db/index.json` + `proof-db/lean/ProofDB.lean` — five standard lemmas (4 proved, 1 `sorry`); `lake build ProofDB` — [2026-05-25-proof-db-lean-bridge.md](docs/release-notes/2026-05-25-proof-db-lean-bridge.md).

### Added

- **Proof DB (2f slice):** `proof-db/index.json` + `proof-db/lean/ProofDB.lean` — five standard lemmas (4 proved, 1 `sorry`); `lake build ProofDB` — [2026-05-25-proof-db-lean-bridge.md](docs/release-notes/2026-05-25-proof-db-lean-bridge.md).

### Changed

- **Plan checkboxes (wave):** sync `docs/superpowers/plans/*.md` exit gates with shipped Phases 0–5, Pkg, P-linalg loop witness, and C++ compiler evidence — [2026-05-25-plan-checkbox-audit-wave.md](docs/release-notes/2026-05-25-plan-checkbox-audit-wave.md).
- **LLVM toolchain:** pin **22** (was 18) — `scripts/llvm-env.sh`, `scripts/ci-install-llvm.sh`, CMake gate — [2026-05-22-llvm-22-toolchain-bump.md](docs/release-notes/2026-05-22-llvm-22-toolchain-bump.md).

### Added

- **G-test-verify Done:** `prove_lean_ok` in `li-tests/run_all.sh`; 14 closed `contracts_verify` specimens — `docs/release-notes/2026-05-25-g-test-verify-prove-lean-ok.md`.

- **Ecosystem phase 0:** `algorithms-and-libraries-plan.md`, `lic-ecosystem-baseline.md`, agent skill `run-local-ci-gha-quota` — `docs/release-notes/2026-05-22-lic-ecosystem-phase0-baseline.md`.
- **2i broadcast (partial):** `array[1, T]` element-wise broadcast to `array[N, T]` — `docs/release-notes/2026-05-22-2i-broadcast-len1.md`.
- **P-float (partial):** `sqrt_open_bound.li` calls `li_rt_sqrt`; tight `abs` ensures still open — `docs/release-notes/2026-05-22-p-float-sqrt-runtime.md`.
- **7d/7e (partial):** `@parallel(disjoint=)` on `def` inherits to inner `parallel for`; tier-1 `bench.py` uses `--allow-open-vc` — `docs/release-notes/2026-05-22-7d-7e-bench-parallel.md`.
- **Tier-1 matmul benches:** hoist `A`/`B` init out of hot loop in `matmul_naive` / `matmul_blocked` Li drivers — `docs/release-notes/2026-05-22-tier1-matmul-bench-hotloop.md`.

### Fixed

- **CI `test-auth-bearer`:** `build-li-httpd.sh` links `main.li` so `li-httpd` runs `httpd_run_from_argv` (was stub `main` returning 0) — [2026-05-25-ci-test-auth-bearer-main-li.md](docs/release-notes/2026-05-25-ci-test-auth-bearer-main-li.md).

- **HTTPd M1 bearer auth gate:** non-Linux `epoll_ctl_add_listen_i` stub, `build-li-httpd.sh`, plan gates run `test-auth-bearer.sh` on `build/li-httpd` — [2026-05-22-httpd-m1-bearer-auth-gate.md](docs/release-notes/2026-05-22-httpd-m1-bearer-auth-gate.md).
- **HTTPd routing CI:** rebase plan-loop branch on `main`; `run_httpd_config.sh` — `--allow-open-vc` + `HTTPD_SKIP_LI_ROUTING_BIN` — `docs/release-notes/2026-05-22-httpd-rebase-main-post-164.md`.
- **G-lean / P-linalg:** `mat2_at2_float_spec_proved` — closed via `mat2_at2_eval` + `rfl` (no `sorry`); AutoVC ensures use eval not free `result` — `docs/release-notes/2026-05-22-mat2-float-spec-closed.md`.
- **MIR BinOpInt literals:** `rhs_is_literal` default no longer makes `r != 1` compare to `0`; `lic build --allow-open-vc <file> -o <out>` accepts flags before the input path — `docs/release-notes/2026-05-22-binop-int-literal-ne-fix.md`.

### Changed

- **Proof CLI flags:** `lic build` / `lic verify` use `--allow-open-vc` and `--no-lean-verify` instead of `LI_ALLOW_OPEN_VC` / `LI_BUILD_VERIFY_LEAN*` env bypasses (env vars ignored with warning).

### Added

- **HTTPd autonomous plan loop:** `scripts/httpd-plan-loop.py`, `httpd-plan-gates.sh`, baseline doc, goal-directed `code_implementer` via li-cursor-agents — [2026-05-22-httpd-plan-autonomous-loop.md](docs/release-notes/2026-05-22-httpd-plan-autonomous-loop.md).
- **HTTPd M1 core (rate limits):** `limits.rate_limit_rps` required for `proxy:` routes in Python validator + desugar; goal-directed `code_implementer` plan loop — [2026-05-22-httpd-m1-core-rate-limits.md](docs/release-notes/2026-05-22-httpd-m1-core-rate-limits.md).
- **HTTPd M1 ingress headers:** route-key header extras must match ingress allowlist; reject `x-upstream-*` / hop-by-hop — [2026-05-22-httpd-m1-ingress-headers.md](docs/release-notes/2026-05-22-httpd-m1-ingress-headers.md).

- **HTTPd M1 TOML desugar:** `li-tests/config_desugar/` goldens (prefix_strip, header extras), `check-httpd-config-desugar.sh`, C runtime route-key extras — [2026-05-22-httpd-m1-toml-desugar.md](docs/release-notes/2026-05-22-httpd-m1-toml-desugar.md).
- **HTTPd M1 routing tests:** `li-tests/routing/` table cases, `config_reject/routing_overlap.toml`, `run_routing.sh`, green `match_routes.li` gate — [2026-05-22-httpd-m1-routing-tests.md](docs/release-notes/2026-05-22-httpd-m1-routing-tests.md).
- **HTTPd autonomous plan loop:** `scripts/httpd-plan-loop.py`, `httpd-plan-gates.sh`, baseline doc, `httpd_implementer` agent — [2026-05-22-httpd-plan-autonomous-loop.md](docs/release-notes/2026-05-22-httpd-plan-autonomous-loop.md).
- **HTTPd M1 plan continue:** overlap reject, `validate-httpd-config` / `flatten-httpd-config`, Bearer 401 runtime + example — [2026-05-22-httpd-m1-plan-continue.md](docs/release-notes/2026-05-22-httpd-m1-plan-continue.md).
- **P-loop (2f):** Close `linalg_dot4_int_loop_open` AutoVC via static loop witness; `Li.Discharge.dot4_int_loop_eval_spec` — `docs/release-notes/2026-05-22-p-loop-dot-closed.md`.
- **li-log M1:** `packages/li-log`, `runtime/li_rt_log.c` access sink + redaction; `li-tests/log/redact_bearer.li` — [2026-05-22-li-log-m1-package.md](docs/release-notes/2026-05-22-li-log-m1-package.md).
- **HTTPd M1 static recv:** serve files without mandatory `index.html` cache; config-file proxy uses epoll loop — [2026-05-21-httpd-m1-static-recv-continue.md](docs/release-notes/2026-05-21-httpd-m1-static-recv-continue.md).
- **Compiler E0360 extern ptr ABI:** `verify_mir_extern_abi` before LLVM emit; `li-tests/runtime/argv_ptr_abi.li` — [2026-05-21-extern-ptr-abi-guard.md](docs/release-notes/2026-05-21-extern-ptr-abi-guard.md).
- **HTTP proxy epoll + seam + ptr codegen:** `httpd_li_proxy_*_epoll_i` flushes `proxy_rbuf` on client `EPOLLOUT`; new `std/runtime/seam.li`; `lic` stores full-width `ptr` from `CallExtern` (fixes argv segfault / `verify_fail_li:/`) — [2026-05-21-httpd-proxy-epoll-fix.md](docs/release-notes/2026-05-21-httpd-proxy-epoll-fix.md).
- **HTTP epoll + proxy/LB benches:** land `li_rt_net.c` epoll server, `li-net-httpd` proxy argv routing, snap race fix (reverts broken wave-8 proxy header relay) — [2026-05-22-httpd-proxy-bench-fix.md](docs/release-notes/2026-05-22-httpd-proxy-bench-fix.md).
- **2f AutoVC:** Recursive `decreases`/`requires` call-site VCs typecheck in Lean; parallel-for obligations use `_parN` suffix; `f64` ensures use `Float`; Lean keyword params escaped (`by_`); Linux link skips `-fopenmp` without `omp.h` — `docs/release-notes/2026-05-21-autovc-open-phases.md`.
- **PH-7e:** Loop-based `ArrayMatMul2DF64` (large tiles); `FmaFloatF64` + 16× horner while unroll; tier-1 `matmul_naive` / `horner_pure_li` ≤1.2× C++ (`check-tier1-li-vs-cpp.sh`).
- **G-lean default:** `lic build` runs lake + AutoVC typecheck when `lake` is installed (`--no-lean-verify` to skip); see `docs/release-notes/2026-05-21-glean-default-lean-2i-7e.md`.
- **2i:** `linalg_mat2_at2_float_closed.li` — full 2×2 `@` as `Li.Discharge.mat2_at2_float_spec`; loop-dot closed via static witness + `dot4_int_loop_eval_spec`.
- **2i-b / 7e / 2f slice:** prelude `axpy`, array `**`, reductions; `dot()` VC witness; 2D matrix **CallProc**; `linalg_mat2_callproc_float_closed`; `lic build --strict-lean`; IKJ matmul + release `-ffp-contract=fast`; see `docs/release-notes/2026-05-21-2i-7e-2f-math-surface.md`.
- **Gap closure (2f/2i-b/7d-c/H):** loop-dot VC witness, prelude `norm`, AST parallel race policy, httpd routing contract; see `docs/release-notes/2026-05-21-gap-closure-order.md`.
- **Doc:** master-plan tracker + [provability-gaps](docs/verification/provability-gaps.md) **Still open** section synced to `main` (#151, #148, #150); see `docs/release-notes/2026-05-21-master-plan-gaps-sync.md`.
- **P-linalg proofs (2f partial):** `contracts_verify/linalg_*` — closed int dot/sum/matmul-entry VCs + open loop-dot specimen; `discharge_linalg_int_lean.sh`; see `docs/release-notes/2026-05-20-p-linalg-proofs.md`.
- **Phase 7d-c (partial):** `@vectorized` on `for` — scoped `ArraySimdScope` overrides `@no_vectorize` in loop body; see `docs/release-notes/2026-05-21-7dc-vectorized-for-scope.md`.
- **CallProc array params:** `array[N, T]` and object array fields pass by pointer; see `docs/release-notes/2026-05-21-callproc-array-params.md`.
- **Phase 7d-b (partial):** `@vectorized(lanes=4)` policy + `@no_vectorize` disables array SIMD codegen; `@vectorized` on `for` parses; see `docs/release-notes/2026-05-21-7db-vectorized-codegen.md`.
- **Phase 7e-e (partial):** Safe `f64x4` gather/scatter for `ArrayBinOpF64`; see `docs/release-notes/2026-05-21-7ee-array-binop-simd.md`.
- **Phase 7e-b (partial):** Tier 1 `matmul_blocked` pure-Li IKJ tiles (`li_pure=True`); see `docs/release-notes/2026-05-21-7eb-matmul-blocked-pure-li.md`.
- **Phase 7e-d (partial):** Safe `f64x4` gather codegen for `ArrayDotF64` (insertelement, no vector load from alloca); see `docs/release-notes/2026-05-21-7ed-simd-dot-codegen.md`.
- **Phase 2i-a:** Element-wise `+ - * /` on matching 1d arrays; `sum(a * b)`; see `docs/release-notes/2026-05-21-2ia-array-elementwise.md`.
- **Phase 7e-c (partial):** Math-first HPC docs (`docs/guide/math-hpc-examples.md`, gallery/README/fast-math refresh); see `docs/release-notes/2026-05-21-7ec-math-hpc-docs.md`.
- **Phase 7e-a (partial):** `dot(a,b)` prelude + `simd_dot` pure-Li `a @ b` bench (no `__li_simd_*`); see `docs/release-notes/2026-05-21-7ea-simd-dot-math.md`.
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

- **CI `test-auth-bearer`:** `build-li-httpd.sh` links `main.li` so `li-httpd` runs `httpd_run_from_argv` (was stub `main` returning 0) — [2026-05-25-ci-test-auth-bearer-main-li.md](docs/release-notes/2026-05-25-ci-test-auth-bearer-main-li.md).

- **G-lean (2f):** AutoVC emits `LiArray α n` (not Lean builtin `Array`); `docs/semantics/Core.lean` + `lake build AutoVC` in CI/`lean-verify-stub.sh`; see `docs/release-notes/2026-05-21-glean-liarray-lake.md`.
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

- **CI `test-auth-bearer`:** `build-li-httpd.sh` links `main.li` so `li-httpd` runs `httpd_run_from_argv` (was stub `main` returning 0) — [2026-05-25-ci-test-auth-bearer-main-li.md](docs/release-notes/2026-05-25-ci-test-auth-bearer-main-li.md).

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
