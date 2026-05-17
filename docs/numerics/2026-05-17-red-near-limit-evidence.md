# Numerics researcher evidence: red / near-limit rows (2026-05-17)

Dashboard: https://li-langverse.github.io/benchmarks/

## Benchmark IDs (preflight / org audit snapshot)

| Status | Catalog / bench `id` | `ratio_vs_cpp` (reported) | PH tags (dashboard) |
|--------|----------------------|---------------------------|---------------------|
| **Red** | `horner_pure_li` | ~88.8× | PH-5b, PH-7e |
| Near limit | `matmul_blocked` | ~1.035 | PH-5b (G-math) |
| Near limit | `nbody_gravity` | ~1.035 | Physics tier-2 |
| Near limit | `double_pendulum` | ~1.032 | Physics tier-2 |
| Near limit | `wave_equation_1d` | ~1.024 | Physics tier-2 |
| Near limit | `harmonic_oscillator_chain` | ~1.018 | Physics tier-2 |

Org PR in flight for lexer/codegen (per merge plan): [lic#40](https://github.com/li-langverse/lic/pull/40) — **do not lower `threshold_ratio_cpp`** to green the dashboard.

## Reproduce locally (lic repo)

Prerequisite: compiler build

```bash
./scripts/build.sh
```

Tier-1 micro (includes `horner_pure_li`, `matmul_blocked`):

```bash
python3 benchmarks/harness/bench.py --tier 1 --runs 3
```

Tier-1 + tier-2 physics:

```bash
python3 benchmarks/harness/bench.py --tier 12 --runs 3
```

Results: `benchmarks/results/latest.csv`. Competitive review flow: `docs/benchmarks/competitive-landscape.md`.

**Upstream failure report (separate `benchmarks` checkout):** when present,

```bash
cd ../benchmarks   # sibling of lic per bench policy
./scripts/benchmark-failures-report.sh
```

## Learned-from references (SOTA / canonical)

1. **N. J. Higham — *Accuracy and Stability of Numerical Algorithms*** (SIAM); polynomial evaluation and error analysis for Horner-style accumulation — https://doi.org/10.1137/1.9781611978027
2. **Eigen — “Writing efficient matrix product expressions”** (blocking / expression fusion aligned with GEMM cache blocking) — https://eigen.tuxfamily.org/dox/TopicWritingEfficientProductExpression.html
3. **PETSc User Guide** — semi-discrete PDE + `TS` time integration stack (reference for `wave_equation_*`, implicit stencils) — https://petsc.org/main/manual/
4. **BLIS** — portable BLAS-like framework and BLISlab teaching stack for hierarchical micro-kernels (reference for `matmul_*` / SIMD policy) — https://github.com/flame/blis and https://github.com/flame/blislab

## Map to roadmap axes

| Axis | `horner_pure_li` | `matmul_blocked` | Near-limit physics (`nbody_*`, oscillators, `wave_equation_1d`) |
|------|------------------|------------------|-------------------------------------------------------------------|
| **PH-5b / G-math** | Dense float loop shape + FMA-friendly scheduling vs naive scalar codegen | Blocked GEMM / cache-aware macro-kernel parity with Eigen/BLIS-class libs | Kernel arithmetic intensity vs memory traffic in integration loops |
| **PH-7e** | Pure-Li SIMD vectorization, reduction of loop overhead, `noinline` parity with reference C | SIMD micro-kernels + panel packing contracts | Optional `std`-level vector hints without unsafe user `__li_simd_*` in physics APIs |
| **G-par** | Single-thread; no change | Future threaded GEMM / `parallel for` policies | Particle/grid parallelism patterns (Kokkos / OpenMP policy analogue) |

## Proposed lic implementation path (contracts + bench evidence)

1. **Codegen / lexer correctness** — land PH-7e/5b fixes with `horner_pure_li` median ratio trending toward ≤1.2× vs `cpp` on the published harness; keep checksum smoke for pure-Li benches (`bench.py` verify path).
2. **`matmul_blocked`** — document blocking parameters in `params.toml` vs Eigen/BLIS reference block sizes; extend `li-std-math` / lowering to emit cache-blocked inner loops + FMA where provable.
3. **Physics near-limit** — for each bench, tie integrator stencil to `docs/physics/numerical-policy.md` tier; add or tighten Tier-0 stability rows (`benchmarks/harness/stability.py`) before parallel speedups.
4. **G-par** — map `std/execution` decorators to LLVM OpenMP / MLIR `omp` lowering (see lic issues **#15**, **#34**); bench evidence stays on shared fixtures first.

## Verification slice attempted (this workspace)

```text
python3 benchmarks/harness/bench.py --tier 1 --runs 1 --skip-verify
# RuntimeError: lic missing at …/build/compiler/lic/lic — run ./scripts/build.sh
```
