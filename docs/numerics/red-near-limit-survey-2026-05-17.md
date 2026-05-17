# Red / near-threshold benchmarks — literature map (numerics researcher pass)

This note satisfies the agent evidence requirement: bench **ids**, **dashboard** link, and **local repro**.

## Bench evidence

| Row | Tier | Ratio vs cpp (dashboard snapshot `2026-05-16T15:10:14Z`) | Dashboard |
|-----|------|----------------------------------------------------------|-----------|
| `horner_pure_li` | 1 | **88.821×** (red) | [Benchmark dashboard](https://li-langverse.github.io/benchmarks/) |
| `matmul_blocked` | 1 | 1.035× (near) | same |
| `reduce_sum` | 1 | 1.003× (near) | same |
| `nbody_gravity` | 2 | 1.035× | same |
| `double_pendulum` | 2 | 1.032× | same |
| `wave_equation_1d` | 2 | 1.024× | same |
| `harmonic_oscillator_chain` | 2 | 1.018× | same |
| `heat_equation_2d` | 2 | 1.004× | same |

Do **not** relax `threshold_ratio_cpp` for greening; regressions belong in codegen/harness (`bench_improver` / compiler).

## Repro commands

From a clone of **`li-langverse/benchmarks`** (sibling repo on the workstation):

```bash
cd benchmarks
./scripts/benchmark-failures-report.sh
```

Pure-Li horner harness in **lic**:

- `benchmarks/tier1_micro/horner_pure_li/li/main.li`
- cpp reference loop: `benchmarks/tier1_micro/horner_pure_li/common/horner_core.c`

## Learned-from references (URLs)

1. **Numerical Recipes** — polynomials / rational functions (Horner baseline, §5-style “evaluation of functions”): routines index at [numerical.recipes/routines](https://numerical.recipes/routines/instc.html) (printed book §5.3 in editions that cover Horner explicitly).
2. **Goto & van de Geijn — GEMM / blocking** (maps to **`matmul_blocked`**): [ACM TOMS “high-performance GEMM” (Goto2008)](https://doi.org/10.1145/1356052.1356057) and UT FLAME reprints ([Goto2008 PDF via cs.utexas.edu FLAME pubs](https://www.cs.utexas.edu/~flame/pubs/GotoTOMS_final.pdf)).
3. **Eigen** — expression templates, lazy fusion, SIMD-friendly dense kernels: [Eigen documentation](https://eigen.tuxfamily.org/).
4. **PETSc TS** — time-stepping stacks for hyperbolic / parabolic PDE surrogates (maps to **`wave_equation_1d`**, **`heat_equation_2d`**): [PETSc TS manual](https://petsc.org/release/manual/ts/).

**Extra (algorithm literacy, pure-Li slowdown is not “wrong math”):** Horner structural definition — [Wikipedia — Horner’s method](https://en.wikipedia.org/wiki/Horner%27s_method).

## Map to Li roadmap ids

| Signal | Benchmark ids | Likely pillar / track |
|--------|---------------|------------------------|
| Pure-Li loop + float accum, no SIMD/FMA parity vs `-O3` C | `horner_pure_li` | **PH-7e** (pure-Li codegen), **PH-5b** (SIMD/IR quality), touches **G-math** (float kernel lowering) |
| Blocked GEMM microkernel | `matmul_blocked` | **G-math** (dense LA), **G-par** if parallel tiling exposed |
| Horizontal / reduction idioms | `reduce_sum` | **PH-5b**, **G-par** |
| N-body pairwise force inner loop | `nbody_gravity` | **G-par**, memory bandwidth (SoA vs AoS), optional Barnes–Hut policy per `docs/physics/numerical-policy.md` (**autoresearch** if changing method class) |
| Symplectic / stability-sensitive ODE chains | `double_pendulum`, `harmonic_oscillator_chain` | Align integrator tier with numerical policy (**G-math**, future **NumericalTargets**); Hairer/Wanner family standard refs (textbook citations in policy issues) |
| Explicit PDE stencils | `wave_equation_1d`, `heat_equation_2d` | **G-math** (stencil correctness), **G-par** (cache blocking, vectorization), compare to PETSc `TS` coupling patterns |

## Proposed lic implementation path (contracts + bench evidence)

1. **`horner_pure_li`**: Treat as a **codegen micro-contract** — match C semantics (`acc * x + 1.0`, same trip count); add `li-tests`/IR checks that the lowered loop emits **FMA-capable LLVM** (`llvm.fmuladd` where fast-math policy allows), **shrinks spills** around the `while`, and avoids excess bounds checks vs proven `steps`. Coordinate with **`bench_improver`** for harness-only parity (same flags as cpp). Novel evaluation graphs (Estrin, SIMD-wide poly) → **autoresearch** if they change the numeric graph.
2. **`matmul_blocked` / `reduce_sum`**: Mirror **BLIS-style** inner-kernel loop nest in emitted code or std numerics stubs; cite Goto blocking + Eigen fusion as acceptance rubric (IPC / L1 tiling), prove via existing bench checksums — no threshold edits.
3. **Tier-2 near rows**: **`nbody_gravity`** — SIMD + SoA prefetch patterns (reference: standard HPC N-body lectures / GPU gems literature in follow-up issue); **`wave`/`heat`** — stencil blocking and explicit stability (CFL) as `requires` where language allows per `numerical-policy.md`.

## Control-plane MCP (recent `numerics_researcher` runs)

Several SDK runs ended in `status=error` with `error='SDK run status: error'` and **no Python stack trace** in `agent_runs.error` — treat as infra/SDK failure unless `run_trace` is populated downstream.
