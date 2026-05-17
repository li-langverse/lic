# Numerics researcher evidence — red / near-limit benches (2026-05-17)

**Agent:** `numerics_researcher` · **Label:** `numerics-research` · **Org pillars:** proof → easy → fast ([vision](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/vision-and-roadmap.md))

## Dashboard & repro

- **Live dashboard:** [li-langverse.github.io/benchmarks](https://li-langverse.github.io/benchmarks/)
- **Failure report (sibling `benchmarks` checkout):**

```bash
cd benchmarks
./scripts/benchmark-failures-report.sh
```

**Snapshot used for this note** (`generated_at` from report): `2026-05-16T15:10:14.562929+00:00` — **RED (1):** `horner_pure_li` (~88.8× vs cpp, tier 1, `PH-5b`, `PH-7e`). **Near threshold (ratio > 1.0× cpp):** `matmul_blocked`, `nbody_gravity`, `double_pendulum`, `wave_equation_1d`, `harmonic_oscillator_chain`, `heat_equation_2d`, `reduce_sum`.

**Lic harness paths:** `benchmarks/tier1_micro/horner_pure_li/` (pure Li driver), `benchmarks/tier1_micro/matmul_blocked/`, `benchmarks/tier1_micro/reduce_sum/`; tier-2 physics dirs under `benchmarks/tier2_physics/<id>/`.

## Mode A — SOTA references (learned from)

| # | Reference | URL | Relevance |
|---|-----------|-----|-----------|
| 1 | *Numerical Recipes* — polynomial evaluation nested form (Horner) | [Numerical Recipes C routines index](https://numerical.recipes/routines/instc.html) (see ch. 5 *Evaluation of Functions* in the book) | Canonical reduction for the **horner** micro-bench semantics; Li must match FP semantics while closing the **pure Li codegen** gap vs hand-written C. |
| 2 | BLIS — GEMM micro-kernels & packing | [BLIS `KernelsHowTo.md`](https://github.com/flame/blis/blob/master/docs/KernelsHowTo.md) | **Blocked matmul** and future `simd_dot` / GEMM parity: register blocking, micro-kernel contract, cache-friendly packing — maps to **PH-5b** numerics baselines and **PH-7e** codegen targets. |
| 3 | Eigen — efficient matrix products & vectorization | [Eigen: Writing efficient matrix product expressions](https://eigen.tuxfamily.org/dox/TopicWritingEfficientProductExpression.html) | Reference for `.noalias()`, GEMM detection, and vectorized reduction patterns that C++ enjoys at **-O3**; informs **G-math** lowering and contract tests vs reference builds. |
| 4 | PETSc — `TS` time stepping | [PETSc TS manual pages](https://petsc.org/release/manualpages/TS/) | **Tier-2 physics** near-limit rows (oscillator chain, wave/heat, n-body): implicit/explicit split, symplectic vs BDF classes, sensitivity hooks — policy alignment with `docs/physics/numerical-policy.md` and future **physics packages** (not a license to weaken `threshold_ratio_cpp`). |

## Map to plan tracks

| Bench id | Approx. ratio (snapshot) | PH-5b | PH-7e | G-math | G-par |
|----------|--------------------------|-------|-------|--------|-------|
| `horner_pure_li` | ≫ 1 (red) | Baseline FP policy | Pure-Li SIMD / FMA / loop opts | Scalar polynomial eval surface | Optional `parallel for` + simd metadata ([decorators spec](../superpowers/specs/2026-05-16-li-execution-decorators.md)) |
| `matmul_blocked`, `reduce_sum` | ~1.03–1.00 | BLAS-like parity | Micro-kernel + vector reduction | `@` / linalg surface | Parallel tiling of outer loops |
| `nbody_gravity`, `double_pendulum`, `harmonic_oscillator_chain`, `wave_equation_1d`, `heat_equation_2d` | ~1.02–1.04 | Integrator + stencil correctness | Hot-loop vectorization | Physics numerics API | Kokkos-class execution mapping ([lic#15](https://github.com/li-langverse/lic/issues/15)) |

## Proposed implementation path in **lic** (for `bench_improver` / codegen)

1. **`horner_pure_li`:** Treat as **PH-7e** codegen proof: fused multiply-add chains, reduction of loop overhead, optional **Estrin**-style reassociation *only* if **IEEE-consistent** with bench contract and golden checksum; coordinate with `li-tests` / harness checksum for the existing `horner` C reference in `common/horner_core.c`.
2. **`matmul_blocked` / `reduce_sum`:** Follow BLIS-style **macro-kernel + micro-kernel** decomposition in emitted LLVM; ensure alignment and `noalias` analog in Li IR; benchmark row `matmul_blocked` stays the gate (no threshold tweaks).
3. **Tier-2 physics near green:** Profile for alloc/alias boundaries; align timestep/stencil modules with PETSc `TS` catalog *method classes* for documentation and future optional C reference — pure Li remains the shipped path per ecosystem rules.

## Control plane note

Recent `numerics_researcher` runs in `agent_runs`: several `error` statuses around `2026-05-17T16:51–17:04Z`; one `finished` at `2026-05-17T16:55:11.851Z`. Investigate run logs separately if automation retries fail.

## Deferred

- Novel reassociation / non-standard fast-math paths → **autoresearch** agent, not this note.
- FFT / roofline row ([benchmarks#18](https://github.com/li-langverse/benchmarks/issues/18)) — separate catalog/harness work.
