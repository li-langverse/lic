# Red / near-limit benchmarks — SOTA map (2026-05-17)

**Agent:** `numerics_researcher`  
**Evidence type:** numerics doc (bench ids + repro; no `threshold_ratio_cpp` change)

## Dashboard / org context

- Published dashboard: <https://li-langverse.github.io/benchmarks/>
- Org tracker issue (bench IDs + SOTA thread): <https://github.com/li-langverse/benchmarks/issues/31>

## Bench IDs (preflight / ingest snapshot)

| Status | Bench id | Ratio vs C++ (reported) | Pillars |
|--------|-----------|-------------------------|---------|
| **Red** | `horner_pure_li` | ~88.8× | PH-5b, PH-7e, G-math |
| Near limit (>1.0) | `matmul_blocked` | ~1.035 | PH-5b, PH-7e, G-math |
| Near limit | `nbody_gravity` | ~1.035 | PH-7e, G-par (when parallel), physics tier-2 |
| Near limit | `double_pendulum` | ~1.032 | Physics tier-2, integrators |
| Near limit | `wave_equation_1d` | ~1.024 | PDE stencils, G-math |
| Near limit | `harmonic_oscillator_chain` | ~1.018 | Symplectic / ODE, G-math |

## Repro (this repo — lic)

Compiler must exist at `build/compiler/lic/lic` (run `scripts/ci.sh` first).

```bash
# Tier-1 micro (includes horner_pure_li, matmul_blocked, …)
python3 benchmarks/harness/bench.py --tier 1 --runs 3

# CI-shaped smoke (requires release build)
scripts/ci-bench.sh
```

**Separate org repo:** full failure report helper lives under `li-langverse/benchmarks`:

```bash
cd ../benchmarks   # sibling checkout
./scripts/benchmark-failures-report.sh
```

## Learned-from references (existing algorithms / stacks)

1. **Horner / polynomial eval (micro correctness & “optimal” flop count)** — [Horner’s method (Wikipedia)](https://en.wikipedia.org/wiki/Horner%27s_method) — canonical algorithm for `horner_pure_li`; Li gap is **codegen / lowering**, not a novel evaluation formula.
2. **Cache-blocked GEMM (near-limit matmul)** — [Eigen — writing efficient matrix product expressions](https://eigen.tuxfamily.org/dox/TopicWritingEfficientProductExpression.html) — expression lowering + GEMM routing; implementation lineage ties to **Goto/BLIS** blocking.
3. **High-performance GEMM structure (blocking + micro-kernel)** — [BLIS: A Framework for Rapidly Instantiating BLAS Functionality (TOMS)](https://www.cs.utexas.edu/users/flame/pubs/blis2_toms_rev2.pdf) — reference for why `matmul_blocked` vs naive is ~1× vs C++ when compiler is close, and what “done” looks like for pure-Li SIMD matmul.
4. **Time integration stack for PDE / ODE tiers** — [PETSc TS manual (ODE/DAE solvers)](https://petsc.org/main/manual/ts/) — maps ecosystem issue space for stiff / implicit steps vs current tier-2 stubs (see lic#35 explorer thread).

## Map to Li roadmap rows

| Topic | PH-5b (HPC numerics baseline) | PH-7e (pure-Li / SIMD codegen) | G-math | G-par |
|-------|-----------------------------|--------------------------------|--------|-------|
| `horner_pure_li` red | Baseline parity target | Primary owner: IR, register pressure, loop opts | Float pipeline + lowering contracts | Optional `std/execution` policy on outer loop once legal |
| `matmul_blocked` yellow | Match blocked reference | SIMD tile + pack like BLIS micro-kernel story | Shape rules (`@`), lowering plan lic#20 | Parallel M/C tiles when decorators map to OpenMP/LLVM |
| Physics near-limit rows | Catalog honest vs C++/shared kernel | Pure-Li kernels per tier variant | Integrators & stencils in numerical-policy | Kokkos-class memory + execution spaces (lic#15, #28) |

## Implementation path in `lic` (contracts + bench evidence)

1. **Contracts:** extend verifier + codegen tests in `li-tests/` for float binops / loops touched by `horner_pure_li`; keep **no** `sorry` / `unsafe` shortcuts (agent guardrail).
2. **Codegen:** treat `horner_pure_li` as the canonical **PH-7e** stress (BinOpFloat + `while`); land lexer/parser fixes if they block correct IR (see failing PR lic#40 in org audit — CI must go green before claiming ratio wins).
3. **Matmul:** drive `matmul_blocked` toward ≤1.2× using blocked lowering aligned with Eigen/BLIS structure; add `li-tests` rows for matrix shape errors per lic#20.
4. **Physics:** for `nbody_gravity` / chains / waves, pair `bench_improver` harness work with **PETSc TS** / SUNDIALS-class references for timestep policy (lic#35); keep shared C kernel variant until pure-Li path proven.
5. **Evidence loop:** every merge that claims improvement must attach **manifest row**, **lit** slice, or **bench catalog** delta — never dashboard-only narrative (org `agent-pr-deliverable-gate`).

## Control-plane note

Recent `numerics_researcher` runs recorded in `agent_runs` include both `finished` and `error` statuses; treat `error` rows as automation/environment signal, not numerics conclusions.
