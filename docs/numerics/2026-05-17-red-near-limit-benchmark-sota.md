# Red / near-limit benchmark SOTA map (2026-05-17)

**Goal:** `numerics-research` evidence pack for org red / near-limit rows  
**Issue:** [lic#39](https://github.com/li-langverse/lic/issues/39)  
**Agent:** `code_implementer` · **Worker:** `c73d2afc`  
**North star fit:** PH-7e (pure-Li codegen), PH-5b (tier-1 numerics), G-math (fused temporaries), G-par (parallel backends)  
**Dashboard:** [li-langverse benchmarks Pages](https://li-langverse.github.io/benchmarks/)  
**Mode:** study-only — no `threshold_ratio_cpp` or registry ratio edits

---

## Bench IDs and ratios

| Status | Bench id | Dashboard (2026-05-17 ingest) | Local honest (post-#123) | Notes |
|--------|----------|-------------------------------|--------------------------|-------|
| **red** | `horner_pure_li` | **88.82×** (stale) | **2.3–10.7×** | Pre-#123 dashboard used bogus DCE-green loop; lexer fix + volatile sink restored honest timing — see [bench-improver-horner-2026-05-20.md](./bench-improver-horner-2026-05-20.md) |
| near threshold | `matmul_blocked` | 1.035× | **1.0–1.76×** | C oracle uses BK=64 blocked IKJ; Li `@` → naive `ArrayMatMul2DF64` — see [studies/2026-05-30-autoresearch-proactive-sweep.md](./studies/2026-05-30-autoresearch-proactive-sweep.md) |
| near threshold | `nbody_gravity` | 1.035× | ~1.03× | Tier-2 shared-kernel physics; within ≤1.2× policy |
| near threshold | `double_pendulum` | 1.032× | ~1.03× | Tier-2 symplectic integrator |
| near threshold | `wave_equation_1d` | 1.024× | ~1.02× | Tier-2 stencil / explicit wave |
| near threshold | `harmonic_oscillator_chain` | 1.018× | ~1.02× | Tier-2 chain dynamics |

**Policy targets:** Tier-2 shared-kernel **≤ 1.2× C++**; Tier-1 `pure_li` tracked until **PH-7e / Phase 2i** (see `benchmarks/results/README.md` in sibling [benchmarks](https://github.com/li-langverse/benchmarks) repo).

### Repro (within `lic` checkout)

Pure-Li Horner harness: [`benchmarks/tier1_micro/horner_pure_li/li/main.li`](../../benchmarks/tier1_micro/horner_pure_li/li/main.li)  
Reference core: [`benchmarks/tier1_micro/horner_pure_li/common/horner_core.c`](../../benchmarks/tier1_micro/horner_pure_li/common/horner_core.c)

```bash
# From lic repo root (after ./scripts/build.sh)
python3 benchmarks/harness/bench.py --tier 12 --runs 5

# Tier-1 slice (red + near-limit micro)
python3 benchmarks/harness/bench.py --tier 1 --only horner_pure_li,matmul_blocked --runs 5

# Optional strict gate (no threshold edits)
./scripts/check-tier1-li-vs-cpp.sh
LI_TIER1_PERF_STRICT=1 ./scripts/check-tier1-li-vs-cpp.sh
```

**Org ingest repro** (sibling `benchmarks` checkout):

```bash
cd benchmarks
./scripts/benchmark-failures-report.sh
```

---

## Learned-from references

| # | Topic | Reference |
|---|-------|-----------|
| 1 | Horner nested evaluation (floating policy) | [Numerical Recipes — book index](https://numerical.recipes/bookindex.html); [Wikipedia — Horner's method](https://en.wikipedia.org/wiki/Horner%27s_method) |
| 2 | Expression lowering / fused temporaries (**G-math**) | Eigen: [Lazy Evaluation and Aliasing](https://libeigen.gitlab.io/eigen/dox-devel/TopicLazyEvaluation.html); [Expression Templates](https://libeigen.gitlab.io/eigen/docs-5.0/TopicEigenExpressionTemplates.html) |
| 3 | GEMM blocking / kernels (**near-limit micro**) | Goto & van de Geijn — [Anatomy of High-Performance Matrix Multiplication (PDF)](https://www.cs.utexas.edu/~flame/pubs/GotoTOMS_final.pdf); BLIS — [ACM 10.1145/2755561](https://dl.acm.org/doi/10.1145/2755561) |
| 4 | Portable parallel backends (**G-par / PH-7e analog**) | PETSc Kokkos vectors: [`VECKOKKOS`](https://petsc.org/release/manualpages/Vec/VECKOKKOS/); [PETSc Vectors overview](https://petsc.org/release/manual/vec/) |

---

## Map to Li roadmap tracks

| Li track | Bench signal | Lever from references | Tracking issues |
|----------|--------------|----------------------|-----------------|
| **PH-7e** (pure-Li codegen quality) | `horner_pure_li` red (honest 2–11×) | Clang-like scalar loop lowering; FMA emission for Horner recurrence; avoid per-iteration FFI materialization | [lic#11](https://github.com/li-langverse/lic/issues/11), [lic#9](https://github.com/li-langverse/lic/issues/9) |
| **PH-5b** (tier-1 / numerics competitiveness) | `matmul_blocked` near-yellow | Goto/BLIS-style micro-panel inner kernel in lowering or LIC intrinsics shim (no threshold tweak) | bench_improver / codegen |
| **G-math** | All tier-1 + near-limit tier-2 | Eigen-style fused evaluation for small temporaries once `@`/shape lowering exists | [lic#20](https://github.com/li-langverse/lic/issues/20) |
| **G-par** | Future SIMD + physics-wide loops | Kokkos/PETSc execution-space split: Li parallel loops → OpenMP/IR | [lic#34](https://github.com/li-langverse/lic/issues/34) |

---

## Proposed **lic** implementation path (contracts + bench evidence)

### 1. `horner_pure_li` (red — P0)

- **Contract:** Generated LLVM matches canonical Horner FMA chain (NR-style); no DCE of the recurrence loop; checksum parity vs `horner_core.c` and Python oracle.
- **Evidence:** Green or honest-red row on [dashboard](https://li-langverse.github.io/benchmarks/) after codegen PR; local `bench.py --tier 1 --only horner_pure_li`.
- **Route:** `bench_improver` + compiler (PH-7e FMA/Horner emit). Prior lexer fix: [autoresearch-horner-lexer-2026-05-18.md](./autoresearch-horner-lexer-2026-05-18.md). Escalate to `autoresearch` only for novel schemes beyond textbook Horner.

### 2. `matmul_blocked` (near limit — tier-1)

- **Contract:** Blocked `M×K×N` tiling documented in G-math plans; Li `@` lowering should match BLIS/Eigen blocking structure without threshold edits.
- **Evidence:** Stable `ratio_vs_cpp` ≤ 1.2× after blocked `@` lowering or explicit tiled loops in pure-Li harness.
- **Route:** `bench_improver` — blocked `ArrayMatMul2DF64` or hand-tuned tile recipe; see [studies/2026-05-30-bench-improver-matmul-tier1.md](./studies/2026-05-30-bench-improver-matmul-tier1.md).

### 3. Tier-2 physics near-limit (`nbody_gravity`, `double_pendulum`, `wave_equation_1d`, `harmonic_oscillator_chain`)

- **Contract:** Timestep / stencil choices in `docs/physics/numerical-policy.md`; shared C kernels preserve checksum parity.
- **Evidence:** Per-bench harness + dashboard ingest; parallel variants defer to **G-par** (`std/execution/decorators.li`).
- **Route:** Monitor only while ≤1.2×; optimize after tier-1 reds close.

---

## Proof → easy → fast (org policy)

1. **Contract parity:** Preserve golden checksum vs `cpp` / `shared_c_kernel` lanes for each catalog row.
2. **Bench evidence:** Extend `benchmarks/competitive/registry.toml` only with harnessed drivers; rerun `bench.py` and publish CSV cited on dashboard.
3. **Codegen focus for `pure_li` red:** Delegate micro-optimization to `bench_improver` + compiler — not catalog ratio edits.

---

## Related issues

- [lic#11](https://github.com/li-langverse/lic/issues/11) — PH-7e / G-math — pure-Li Horner codegen  
- [lic#9](https://github.com/li-langverse/lic/issues/9) — PH-7e implement  
- [benchmarks#31](https://github.com/li-langverse/benchmarks/issues/31) — Numerics researcher pass (evidence coordination)

---

## Mandatory agent proof (this file)

| Field | Value |
|-------|-------|
| **Path** | `docs/numerics/2026-05-17-red-near-limit-benchmark-sota.md` |
| **Bench ids** | `horner_pure_li`, `matmul_blocked`, `nbody_gravity`, `double_pendulum`, `wave_equation_1d`, `harmonic_oscillator_chain` |
| **Repro** | `python3 benchmarks/harness/bench.py --tier 12 --runs 5` (lic); `cd benchmarks && ./scripts/benchmark-failures-report.sh` (org ingest) |
| **Prior art** | Closed-unmerged [PR #43](https://github.com/li-langverse/lic/pull/43) (5 duplicate filenames deduped here); Horner honesty [PR #123](https://github.com/li-langverse/lic/pull/123) |
