# Benchmark SOTA map — red + near-limit rows (2026-05-17)

This note satisfies the **numerics doc** evidence lane: fixed **bench ids**, **repro command**, and pointers to the public dashboard.

## Evidence

| Kind | Value |
|------|--------|
| Dashboard | [li-langverse benchmarks](https://li-langverse.github.io/benchmarks/) |
| Report `generated_at` (local run) | `2026-05-16T15:10:14.562929+00:00` |
| Bench ids (red) | `horner_pure_li` |
| Bench ids (near threshold, >1.0× cpp) | `matmul_blocked`, `nbody_gravity`, `double_pendulum`, `wave_equation_1d`, `harmonic_oscillator_chain`, `heat_equation_2d`, `reduce_sum` |

## Reproduce status slice

From a clone of **`li-langverse/benchmarks`** (sibling to `lic` as in org automation):

```bash
cd benchmarks
./scripts/benchmark-failures-report.sh
```

Expected highlights (threshold policy unchanged — **do not weaken** `threshold_ratio_cpp`):

- **RED:** `horner_pure_li` (~88.8× vs cpp) — tier **1**, variant **pure_li**, PH tags **PH-5b**, **PH-7e**.
- **Near-limit greens:** tier-1/2 kernels listed above (~1.00–1.04× cpp).

---

## Mode A — SOTA survey (“Learned from”, 4 references)

1. **[Numerical Recipes](https://numerical.recipes/)** — Ch. 5-style guidance: evaluate polynomials via **Horner’s method** (stable, minimal muls); baseline for why naive term-by-term accumulation is numerically *and* structurally discouraged in HPC curricula.
2. **Goto & van de Geijn, “Anatomy of high-performance matrix multiplication,”** [*ACM TOMS* PDF (UT Flame group)](https://www.cs.utexas.edu/~flame/pubs/GotoTOMS.pdf) — layered blocking, packing, inner-kernel anatomy; canonical reference for **blocked GEMM** behaviour (`matmul_blocked` gap vs tuned cpp/BLIS-class code).
3. **Hairer, Lubich & Wanner, *Geometric Numerical Integration*** — [Springer book page](https://link.springer.com/book/10.1007/3-540-30666-8) — structure-preserving / **symplectic** integrators and reversible splitting; aligns with `NumericalTargets` drift language for **`double_pendulum`**, **`harmonic_oscillator_chain`**, and other Hamiltonian tiers.
4. **Barnes & Hut (1986), “A hierarchical \(O(N\log N)\) force-calculation algorithm”** — [Nature abstract DOI landing](https://doi.org/10.1038/324446a0) — reference policy already lists Barnes–Hut for N-body tiers; informs acceptable algorithmic knobs (tree rebuild, MAC opening angle) versus brute-force parity in **`nbody_gravity`**.

*(Supplementary stack pointer for grid PDEs when moving to implicit / scalable solvers: [PETSc Users Manual](https://petsc.org/release/manual/).)*

---

## Map to roadmap items

| Bench id | Problem class | **PH-5b** (competitive cpp numerics baseline) | **PH-7e** (pure-Li / SIMD / codegen proofs) | **G-math** (method correctness / error policy) | **G-par** (parallel / execution policy) |
|----------|----------------|-----------------------------------------------|---------------------------------------------|-----------------------------------------------|----------------------------------------|
| `horner_pure_li` | tier-1 polynomial | Baseline parity vs optimised cpp Horner/FMA chains | Primary owner: codegen must fuse ops, SIMD where provable | Horner rounding model vs explicit poly eval; cite NR Ch.5 stance | SIMD horizontal patterns; avoid user `__li_simd_*` in physics stdlib surface |
| `reduce_sum` | tier-1 reduction | Near-limit ⇒ memory bandwidth + assoc. deltas | SIMD + unroll contractual lowering | Assoc/reorder bounds doc (targets vs fast-math posture) | `par_unseq`/decorator lowering (coord. with OpenMP/Kokkos-class issues) |
| `matmul_blocked` | tier-1 GEMM | Compare with BLIS/Goto anatomy (cache-friendly blocks) | Micro-kernel tiling + SIMD | Naive vs blocked numerical equivalence (orthogonal to perf) | Parallel `i,j,k` permutations under policy |
| `nbody_gravity` | tier-2 N-body | BH / FMM class when policy upgrades tier | SIMD vectorization within leaf buckets | Softening \(\epsilon\), Opening-angle MAC invariants | Tree build + traversal parallelism |
| `double_pendulum`, `harmonic_oscillator_chain` | tier-2 ODE / Hamiltonian | Verlet vs RK reference split | SIMD for batched dof if applicable | Symplectic energy drift vs `NumericalTargets` (`numerical-policy.md`) | decorator mapping |
| `wave_equation_1d`, `heat_equation_2d` | tier-2 hyperbolic / parabolic PDE | CFL explicit stencils baseline | SIMD stencil peels | Discrete stability ⇒ proof hooks (`requires` dt bounds) eventually | tiling + `par_for` codegen |
| UNKNOWN `tier0_stability` | Tier-0 gate | Harness correctness prerequisite | — | Stability rows in harness (`stability.py` per skill) | — |

---

## Proposed `lic` implementation path (contracts → bench proof)

Aligned with **`research-li-numerics`** and `docs/physics/numerical-policy.md`:

1. **`horner_pure_li` (P0)**  
   - Compiler/codegen issue (not threshold edits): expose **parity contract** Horner accumulator shape; emit **FMA chains** / minimal spills; optional **simd strip-mine** with proof-friendly bounds.  
   - Evidence: reproducible ratio movement on dashboard row + **`li-tests` matrix row** documenting fixed checksum (coordinate `bench_improver` for harness if ingest path misses `LIC_ROOT`).

2. **Near-limit tier-1** (`matmul_blocked`, `reduce_sum`)  
   - Apply PH-7e micro-kernel + reduction patterns from Goto/BLIS mental model (blocking params in shared `params.toml` across cpp/rust/li if not already enforced).

3. **Near-limit tier-2 physics**  
   - Re-verify integrator choice matches policy table (`Verlet`/symplectic for chains; BH optional mode behind explicit tier flag — no `sorry`/`unsafe`).  
   - Extend **Tier-0 stability** catalogue once `tier0_stability` leaves UNKNOWN.

Cross-repo coordination: benchmarks issue [**#31** — Numerics researcher pass tracker](https://github.com/li-langverse/benchmarks/issues/31); lic issues **#27**, **#33**, **#34**, **#15** for SIMD matmul decorators and reference baselines.

---

## Control plane note (snapshot)

Recent `numerics_researcher` runs in MCP `agent_runs` show intermittent `status=error` with sparse `agent_run_events` payloads (`premature: true`); treat control-plane timelines as **noisy telemetry** unless correlated with CI logs — this pass’s evidence is anchored on **benchmark script output + dashboard + this doc path**.
