# Numerics research pass — red + near-limit rows (evidence anchor)

Dashboard: https://li-langverse.github.io/benchmarks/

## Bench IDs (canonical)

| Bench id | Bucket (audit 2026-05-17) | `ratio_vs_cpp` (audit) |
|----------|-----------------------------|-------------------------|
| `horner_pure_li` | red (tier-1 micro, `pure_li`) | ~88.8 |
| `matmul_blocked` | near threshold | ~1.035 |
| `nbody_gravity` | near threshold | ~1.035 |
| `double_pendulum` | near threshold | ~1.032 |
| `wave_equation_1d` | near threshold | ~1.024 |
| `harmonic_oscillator_chain` | near threshold | ~1.018 |

**Policy:** Do not loosen `threshold_ratio_cpp`; fix LIC lowering / harness parity.

## Repro (this repo — `lic`)

Requires built compiler (`scripts/ci.sh` or equivalent; `ci-bench.sh` checks `build/compiler/lic/lic`).

Tier-1 + tier-2 timings (median of runs; writes CSV):

```bash
python3 benchmarks/harness/bench.py --tier 12 --runs 3 --out benchmarks/results/latest.csv
```

Micro-only (`horner_pure_li`, `matmul_blocked`, etc.):

```bash
python3 benchmarks/harness/bench.py --tier 1 --runs 3 --out benchmarks/results/latest.csv
```

Smoke / correctness slice (tier-0 harness via `li-tests`; no wall-clock ratio):

```bash
python3 benchmarks/harness/bench.py --tier 0 --out benchmarks/results/latest.csv
```

Separate **benchmarks** repo users: `cd benchmarks && ./scripts/benchmark-failures-report.sh` (dashboard ingest pipeline).

## SOTA anchors (URLs)

Tracked in markdown digest / issue body; citations are textbooks + library manuals, not new algorithms.

1. Numerical Recipes (commercial book / site) — polynomial evaluation baseline: https://numerical.recipes/book.html (Horner minimizes scalar ops vs naive powers; recurrence is inherently loop-carried).
2. Golub–Van Loan style blocking for GEMM (maps to **`matmul_blocked`**): dense LA practice for cache-friendly `mc×nc×kc` blocking (align with BLIS mental model below).
3. Van Zee & van de Geijn, *BLIS: A Framework for Rapidly Instantiating BLAS Functionality*, ACM TOMS 2015, **DOI** [10.1145/2764454](https://doi.org/10.1145/2764454) — PDF e.g. [UT Austin flame pubs](https://www.cs.utexas.edu/~flame/pubs/blis1_toms_rev3.pdf).
4. Eigen vectorization / expression-templates behavior: [Eigen: Vectorization](https://libeigen.gitlab.io/eigen/docs-3.4/TopicVectorization.html) (reference semantics for SIMD-friendly dense kernels).
5. PETSc iterative solvers baseline (PDE-ish tier-2 path / future stacks): [KSP Manual](https://petsc.org/release/manual/ksp/).

## Li pillars mapping

| Area | Bench ids | PH / G tract |
|------|-----------|----------------|
| Pure float recurrence + codegen | `horner_pure_li` | **PH-7e** SIMD / lowering; **G-math** float IR quality |
| Blocked GEMM | `matmul_blocked` | **PH-5b** numerics parity; **G-math** lowering vs reference |
| SIMD dot / reductions | `simd_dot`, `reduce_sum` | **PH-7e** / **PH-5b** |
| O(N²) loops, chains, waves | `nbody_gravity`, `harmonic_oscillator_chain`, `wave_equation_1d`, `double_pendulum` | **G-par** (parallel policy + memory), **PH-7e** loop nests |

## `horner_pure_li` kernel contract

Li source: `benchmarks/tier1_micro/horner_pure_li/li/main.li` — fused `acc*x+1` while-loop (canonical Horner recurrence on constant `x`).

Clang reference (`horner_core.c`): same recurrence; LIC target is LLVM IR competitiveness (GPR/FPU register reuse, `-ffast-math`-class merges where spec allows **without** weakening tier-0 proof obligations).

Coordinate compiler work with **`bench_improver`**; novel recurrence algorithms → **autoresearch** agent.
