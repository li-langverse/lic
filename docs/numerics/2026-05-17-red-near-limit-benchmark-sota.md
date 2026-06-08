# Red / near-limit benchmark SOTA map (2026-05-17)

**Issue:** [lic#39](https://github.com/li-langverse/lic/issues/39) · **Agent:** `code_implementer` / `numerics_researcher`  
**Evidence type:** numerics doc (bench ids + repro; **no** `threshold_ratio_cpp` change)  
**North star fit:** PH-5b (proved numerics baseline), PH-7e (pure-Li codegen), G-math (method lowering), G-par (parallel execution policy)  
**Dashboard:** [li-langverse benchmarks Pages](https://li-langverse.github.io/benchmarks/)  
**Org tracker:** [benchmarks#31](https://github.com/li-langverse/benchmarks/issues/31)

---

## Executive summary

Org preflight (2026-05-17 ingest) flagged one **red** tier-1 row (`horner_pure_li`, stale ~88.8× vs C++) and five **near-limit** tier-1/2 rows (~1.02–1.04×). Post-PR #123 honesty work ([bench-improver-horner-2026-05-20.md](./bench-improver-horner-2026-05-20.md), [autoresearch-horner-lexer-2026-05-18.md](./autoresearch-horner-lexer-2026-05-18.md)) shows the catastrophic dashboard ratio was a **lexer/codegen defect**, not a missing algorithm. Honest pure-Li Horner is **~3–10×** C++ (DCE-guarded) or **~1–2.3×** after further PH-7e emit work — still above the ≤1.2× tier-1 advisory cap but no longer org-red at 88×. Near-limit physics rows use shared C kernels; gaps are codegen/parallel policy, not threshold cheats.

---

## Bench table (dashboard snapshot + local repro)

### Dashboard preflight (2026-05-17 ingest — stale for `horner_pure_li`)

| Status | Bench id | `ratio_vs_cpp` (dashboard) | Tier | Variant | Notes |
|--------|----------|------------------------------|------|---------|-------|
| **red** | `horner_pure_li` | **88.8208×** | 1 | `pure_li` | Pre-lexer-fix; loop counter used `-` not `+` |
| near threshold | `matmul_blocked` | 1.0349 | 1 | pure_li | Goto/BLIS-class blocked C oracle |
| near threshold | `nbody_gravity` | 1.0346 | 2 | shared/pure mix | N-body integrator + force eval |
| near threshold | `double_pendulum` | 1.0319 | 2 | physics | Symplectic / Hamiltonian chain |
| near threshold | `wave_equation_1d` | 1.0236 | 2 | PDE stencil | Explicit wave equation |
| near threshold | `harmonic_oscillator_chain` | 1.0183 | 2 | ODE chain | Verlet-class integrator |

**Policy targets:** tier-2 shared-kernel **≤ 1.2× C++**; tier-1 `pure_li` tracked under **PH-7e / Phase 2i** ([`benchmarks/results/README.md`](../../benchmarks/results/README.md)).

### Honest local ratios (post-#123, lic main lineage)

| Bench id | Source | li/cpp | Status vs 1.2× cap | Evidence |
|----------|--------|--------|--------------------|----------|
| `horner_pure_li` | PR #123 DCE pass | **~10.7×** | red (honest) | [bench-improver-horner-2026-05-20.md](./bench-improver-horner-2026-05-20.md) |
| `horner_pure_li` | PH-7e emit follow-up | **~3×** | red (honest) | same doc §Status |
| `horner_pure_li` | autoresearch sweep 2026-05-30 | **2.33×** | red (honest) | [studies/2026-05-30-autoresearch-proactive-sweep.md](./studies/2026-05-30-autoresearch-proactive-sweep.md) |
| `horner_pure_li` | autoresearch sweep 2026-05-29 | **1.0×** | green (local) | [studies/2026-05-29-autoresearch-proactive-sweep.md](./studies/2026-05-29-autoresearch-proactive-sweep.md) |
| `matmul_blocked` | local tier-1 2026-05-30 | **1.76×** | yellow | [studies/2026-05-30-autoresearch-proactive-sweep.md](./studies/2026-05-30-autoresearch-proactive-sweep.md) |
| `matmul_blocked` | local tier-1 2026-05-29 | **1.25×** | near limit | [studies/2026-05-29-autoresearch-proactive-sweep.md](./studies/2026-05-29-autoresearch-proactive-sweep.md) |
| tier-2 near-limit rows | dashboard 2026-05-17 | **1.02–1.04×** | green (shared C) | ingest snapshot; no harness change required |

> **Ingest hygiene:** treat dashboard `horner_pure_li` 88× as **historical** until org `benchmarks` ingest refreshes after lexer + DCE fixes land on the tracked branch.

---

## Repro (lic checkout)

Pure-Li harness: [`benchmarks/tier1_micro/horner_pure_li/li/main.li`](../../benchmarks/tier1_micro/horner_pure_li/li/main.li)  
Reference core: [`benchmarks/tier1_micro/horner_pure_li/common/horner_core.c`](../../benchmarks/tier1_micro/horner_pure_li/common/horner_core.c)

Requirements: `build/compiler/lic/lic` exists (`./scripts/build.sh` or `scripts/ci.sh`).

```bash
# Tier-1 micro (horner_pure_li, matmul_blocked, …)
python3 benchmarks/harness/bench.py --tier 1 --runs 5

# Tier-1 + tier-2 physics (near-limit rows)
python3 benchmarks/harness/bench.py --tier 12 --runs 5

# Advisory tier-1 Li vs C++ ratio report
./scripts/check-tier1-li-vs-cpp.sh

# Strict gate (≤1.2×)
LI_TIER1_PERF_STRICT=1 ./scripts/check-tier1-li-vs-cpp.sh
```

**Separate org repo** — failure ordering report:

```bash
cd ../benchmarks   # sibling li-langverse/benchmarks checkout
./scripts/benchmark-failures-report.sh
```

---

## Learned-from references (Mode A — SOTA survey)

| # | Topic | Reference | Li lever |
|---|-------|-----------|----------|
| 1 | Horner nested evaluation (floating policy) | [Numerical Recipes — book index](https://numerical.recipes/bookindex.html); [Horner's method (Wikipedia)](https://en.wikipedia.org/wiki/Horner%27s_method) | Canonical recurrence for `horner_pure_li`; gap is **codegen/lowering**, not a novel formula |
| 2 | Expression lowering / fused temporaries (**G-math**) | [Eigen: Lazy Evaluation and Aliasing](https://libeigen.gitlab.io/eigen/dox-devel/TopicLazyEvaluation.html); [Eigen: Expression Templates](https://libeigen.gitlab.io/eigen/docs-5.0/TopicEigenExpressionTemplates.html) | Fused `@`/shape lowering once [lic#20](https://github.com/li-langverse/lic/issues/20) lands |
| 3 | GEMM blocking / micro-kernels (**near-limit micro**) | Goto & van de Geijn — [Anatomy of High-Performance Matrix Multiplication (PDF)](https://www.cs.utexas.edu/~flame/pubs/GotoTOMS_final.pdf); BLIS — [ACM 10.1145/2755561](https://dl.acm.org/doi/10.1145/2755561) | `matmul_blocked` C oracle uses cache-blocked IKJ; Li `@` still lowers to naive IKJ |
| 4 | Portable parallel backends (**G-par / PH-7e analog**) | PETSc Kokkos vectors: [`VECKOKKOS`](https://petsc.org/release/manualpages/Vec/VECKOKKOS/); [PETSc Vectors overview](https://petsc.org/release/manual/vec/) | Execution-space split for tier-2 physics loops → [lic#34](https://github.com/li-langverse/lic/issues/34) |

Supplementary: Hairer/Lubich/Wanner *Geometric Numerical Integration* (symplectic integrators for `double_pendulum`, `harmonic_oscillator_chain`); Barnes & Hut (1986) for `nbody_gravity` tree policy when tier upgrades.

---

## Map to roadmap tracks

| Li track | Bench signal | Lever from references | Tracking issues |
|----------|--------------|----------------------|-----------------|
| **PH-7e** (pure-Li codegen quality) | `horner_pure_li` red (honest 3–10×) | Clang-like scalar loop lowering; FMA emission for recurrence; avoid per-iteration FFI materialization | [lic#11](https://github.com/li-langverse/lic/issues/11) (planner), [lic#9](https://github.com/li-langverse/lic/issues/9) (implement) |
| **PH-5b** (tier-1 numerics competitiveness) | `matmul_blocked` near-yellow (1.03–1.76×) | Goto/BLIS micro-panel inner kernel in lowering or LIC intrinsics shim | bench_improver + blocked `@` MIR |
| **G-math** | All tier-1 + near-limit tier-2 | Eigen-style fused evaluation for small temporaries once `@`/shape lowering exists | [lic#20](https://github.com/li-langverse/lic/issues/20) |
| **G-par** | Future SIMD + physics-wide loops | Kokkos/PETSc execution-space split: Li parallel loops → OpenMP/IR | [lic#34](https://github.com/li-langverse/lic/issues/34) |

### Per-bench roadmap matrix

| Bench id | PH-5b | PH-7e | G-math | G-par |
|----------|-------|-------|--------|-------|
| `horner_pure_li` | Baseline parity vs C Horner/FMA | **Primary owner** — IR, register pressure, loop opts | Float pipeline + lowering contracts | Optional outer-loop `std/execution` policy |
| `matmul_blocked` | Match blocked reference | SIMD tile + pack (BLIS micro-kernel story) | Shape rules (`@`), [lic#20](https://github.com/li-langverse/lic/issues/20) | Parallel M/C tiles when decorators map to OpenMP |
| `nbody_gravity` | Catalog honest vs C++ | Pure-Li force loop vectorization | Softening / MAC invariants | Tree build + traversal parallelism |
| `double_pendulum`, `harmonic_oscillator_chain` | Symplectic integrator baseline | SIMD batched dof | Energy drift vs `numerical-policy.md` | Decorator → OpenMP lowering |
| `wave_equation_1d` | CFL explicit stencil baseline | SIMD stencil peels | Discrete stability proof hooks | Tiled `par_for` codegen |

---

## Proof → easy → fast (contracts + bench evidence path)

1. **Contract parity:** Preserve golden checksum parity vs `cpp` / `shared_c_kernel` lanes for each catalog row (`horner` structurally mirrors C core — see cores above). Pure-Li verify rejects DCE (`li_rt_volatile_sink_f64`, `bench.py` 0.45× native floor).
2. **Bench evidence:** Extend `benchmarks/competitive/registry.toml` only with harnessed drivers (no cheat thresholds); rerun `benchmarks/harness/bench.py` and publish CSV row cited on [dashboard](https://li-langverse.github.io/benchmarks/).
3. **Codegen focus for `pure_li` red:** Delegate micro-optimization to **`bench_improver`** + compiler (LLVM pipeline), not catalog ratio edits; escalate novel IR if still red after textbook optimizations → **`autoresearch`** per org policy.

### Proposed `lic` implementation path (out of scope for this doc-only issue)

| Priority | Action | Owner | Evidence |
|----------|--------|-------|----------|
| P0 | `horner_pure_li` FMA chain + strip-mine emit; no `sorry`/`unsafe` | bench_improver / [lic#9](https://github.com/li-langverse/lic/issues/9) | `check-tier1-li-vs-cpp.sh` + dashboard row |
| P1 | Blocked `@` lowering (`ArrayMatMulBlocked2DF64`) for `matmul_blocked` | bench_improver / PH-7e | tier-1 CSV ≤1.2× |
| P2 | Tier-2 pure-Li inner loops (physics near-limit) | code_implementer + G-par | tier-2 harness + stability matrix |
| P3 | Ingest refresh so dashboard drops stale 88× | benchmarks repo ingest | [benchmarks#31](https://github.com/li-langverse/benchmarks/issues/31) |

**Do not:** weaken `threshold_ratio_cpp`; ship `sorry`/`unsafe` for speed; copy harness into benchmarks repo without registry row.

---

## Related issues

- [lic#11](https://github.com/li-langverse/lic/issues/11) — PH-7e / G-math — pure-Li Horner codegen (planner)
- [lic#9](https://github.com/li-langverse/lic/issues/9) — PH-7e Horner implement
- [lic#20](https://github.com/li-langverse/lic/issues/20) — G-math `@`/shape lowering
- [lic#34](https://github.com/li-langverse/lic/issues/34) — G-par parallel loop lowering
- [benchmarks#31](https://github.com/li-langverse/benchmarks/issues/31) — Numerics researcher pass (evidence coordination)

---

## Control-plane note

Recent `numerics_researcher` Cursor-SDK automation runs show status `error` with `reason` `SDK run status: error` (no JVM-style stack trace in `agent_run_events`; `tool_call_count: 0` on sampled rows). Treat as **automation reliability debt** — rerun from Cursor heap or escalate to platform. Numerics conclusions in this doc are anchored on harness output + dashboard + prior merged honesty passes (PR #123), not control-plane error rows.

---

## Evidence index

| Type | Path |
|------|------|
| **This study (canonical)** | `docs/numerics/2026-05-17-red-near-limit-benchmark-sota.md` |
| Horner honesty pass | `docs/numerics/bench-improver-horner-2026-05-20.md` |
| Lexer regression fix | `docs/numerics/autoresearch-horner-lexer-2026-05-18.md` |
| Proactive sweeps | `docs/numerics/studies/2026-05-29-autoresearch-proactive-sweep.md`, `2026-05-30-autoresearch-proactive-sweep.md` |
| Tier-1 ratio gate | `scripts/check-tier1-li-vs-cpp.sh` |
| Harness workloads | `benchmarks/tier1_micro/horner_pure_li/`, `benchmarks/tier1_micro/matmul_blocked/` |
