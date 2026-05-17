# Red / near-limit benchmark SOTA map (2026-05-17)

Evidence pack for **numerics-research**: ties public dashboard rows to textbook / library / solver practice, maps to Li master-plan anchors, and states a **lic** implementation path without changing `threshold_ratio_cpp`.

## Bench IDs and repro

| Bench id | Dashboard class (preflight 2026-05-17) | `ratio_vs_cpp` |
|----------|----------------------------------------|----------------|
| `horner_pure_li` | **red** (pure Li variant) | ~88.8 |
| `matmul_blocked` | near threshold | ~1.035 |
| `nbody_gravity` | near threshold | ~1.035 |
| `double_pendulum` | near threshold | ~1.032 |
| `wave_equation_1d` | near threshold | ~1.024 |
| `harmonic_oscillator_chain` | near threshold | ~1.018 |

**Reproduce failure / ordering** (sibling [`benchmarks`](https://github.com/li-langverse/benchmarks) checkout):

```bash
cd benchmarks
./scripts/benchmark-failures-report.sh
```

**Published dashboard:** [https://li-langverse.github.io/benchmarks/](https://li-langverse.github.io/benchmarks/)

**In-repo benchmark context:** see `docs/benchmarks.md` and `benchmarks/results/README.md` (pure Li vs shared C variants).

---

## Mode A — Learned-from references (≥2)

1. **Numerical Recipes** — stable polynomial evaluation via nested Horner form (avoid redundant powers); hub: [numerical.recipes book](https://numerical.recipes/book.html).
2. **Eigen** — efficient dense matrix products, `.noalias()`, blocking / GEMM-style lowering: [Writing efficient matrix product expressions](https://eigen.tuxfamily.org/dox/TopicWritingEfficientProductExpression.html).
3. **PETSc** — scalable TS/KSP/SNES/DM stack for ODE/PDE + implicit/stiff paths (north-star for tier-2 physics parity): [PETSc users manual](https://petsc.org/release/manual/).
4. **BLIS** — framework for instantiating high-performance BLAS (micro-kernels + blocking): [BLIS on GitHub](https://github.com/flame/blis); primary write-up [doi:10.1145/2764454](https://doi.org/10.1145/2764454).

---

## Map to Li plan tags

| Area | Primary refs | Li anchors |
|------|--------------|------------|
| Horner / tier-320 micro | NR; codegen patterns | **PH-7e** (pure-Li + SIMD codegen), **PH-5b** (numerics baseline / HPC competitiveness) |
| Blocked matmul / `matmul_blocked` | Eigen GEMM notes; BLIS | **G-math**, **PH-7e** (matrix `@` / kernels); aligns with lic issues on matmul / linalg surface |
| N-body, chains, pendula | Classical MD / symplectic integrators (policy in-repo) | **G-math** (integrators), optional **G-par** when parallel |
| Wave / PDE-style stencils | PETSc TS + mesh/DM patterns | **G-math** (methods), **G-par** (Kokkos-class execution — decorators roadmap) |

---

## Proposed **lic** implementation path (contracts + bench evidence)

1. **`horner_pure_li` (red)**  
   - **Contract:** generated LLVM for the benchmark matches a canonical Horner FMA chain (NR-style), no accidental scalarization from lexer/parser/lowering bugs.  
   - **Evidence:** green row on [benchmarks dashboard](https://li-langverse.github.io/benchmarks/) for `horner_pure_li` after **merge-approved** PR; local: `benchmarks` harness + `lic` CI bench slice.  
   - **Coordination:** treat codegen fixes as **bench_improver** / compiler PRs (e.g. failing PRs in ecosystem audit); **autoresearch** only if a *new* algorithm is required beyond standard Horner lowering.

2. **`matmul_blocked` (near limit)**  
   - **Contract:** blocked `M×K×N` tiling + micro-kernel selection documented in `docs/language/linear-algebra.md` / G-math plans; reference behavior matches Eigen/BLIS-style structure (no threshold tweak).  
   - **Evidence:** stable `ratio_vs_cpp` ≤ policy from catalog after codegen; extend `li-tests` only if manifest-level regression tests are agreed for `@` lowering.

3. **Tier-2 physics near-limit** (`nbody_gravity`, `double_pendulum`, `wave_equation_1d`, `harmonic_oscillator_chain`)  
   - **Contract:** timestep / stencil choices recorded in `docs/physics/numerical-policy.md`; optional PETSc-class references for future implicit tiers (issue stack: stiff ODE / PDE).  
   - **Evidence:** per-bench harness outputs + dashboard; parallel variants defer to **G-par** (`std/execution/decorators.li` → real OpenMP / policy lowering).

---

## Mandatory agent proof (this file)

- **Path:** `docs/numerics/2026-05-17-red-near-limit-benchmark-sota.md`  
- **Bench ids:** `horner_pure_li`, `matmul_blocked`, `nbody_gravity`, `double_pendulum`, `wave_equation_1d`, `harmonic_oscillator_chain`  
- **Repro command:** `cd benchmarks && ./scripts/benchmark-failures-report.sh`

---

## Control-plane note

Recent `numerics_researcher` runs recorded in MCP `agent_runs` include finished runs `numerics_researcher-1779048074959` and `numerics_researcher-1779047532202` (2026-05-17); several earlier `error` rows same day — use run logs for stack traces if a pass failed in automation.
