# Red / near-limit benchmarks — evidence pack (numerics researcher)

**Bench dashboard:** https://li-langverse.github.io/benchmarks/

**Snapshot (dashboard / ecosystem audit):** Tier-1 `horner_pure_li` is red (pure-Li variant, ~\(88×\) vs C++; target ≤1.2×). Tier-2 rows `matmul_blocked`, `nbody_gravity`, `double_pendulum`, `wave_equation_1d`, `harmonic_oscillator_chain` reported as near threshold (\(\approx\)1.03–1.07× vs C++).

---

## Mandatory repro (lic checkout)

Requirements: toolchain + `scripts/ci.sh` (or equivalent) so `build/compiler/lic/lic` exists.

| Scope | Command |
|-------|---------|
| Tier-1 micro (includes `horner_pure_li`, `matmul_blocked`) | `python3 benchmarks/harness/bench.py --tier 1 --runs 3` |
| Tier-1 + tier-2 physics | `python3 benchmarks/harness/bench.py --tier 12 --runs 3` |
| CI-shaped smoke | `./scripts/ci-bench.sh` |

**Bench IDs covered here:**  
`horner_pure_li`, `matmul_blocked`, `nbody_gravity`, `double_pendulum`, `wave_equation_1d`, `harmonic_oscillator_chain`.

> **Upstream harness note:** Separate `benchmarks` org checkouts advertise `./scripts/benchmark-failures-report.sh`; this path is **not** present inside the `lic` monorepo’s `benchmarks/` tree — use `bench.py` as above here.

---

## Mode A — SOTA survey (“learned from”)

1. **[Numerical Recipes — *Numerical Recipes: The Art of Scientific Computing* (book portal)](https://numerical.recipes/book.html)**  
   Classical reference for **stable polynomial evaluation via Horner’s rule** (single multiply-add recurrence). Maps the `horner_pure_li` arithmetic pattern (loop `acc = acc*x + const`) to standard numerics lore—gap is compiler/codegen parity with `-O3 -ffast-math` fused paths, not a missing algorithm.

2. **[Kazushige Goto & Robert A. van de Geijn, “Anatomy of high-performance matrix multiplication”](https://doi.org/10.1145/1356052.1356053)**  
   Canonical treatment of **cache blocking / packing hierarchy** driving `matmul_blocked` class performance near the machine roofline—Li should converge microkernel/block parameters with this model, then prove stability under contract semantics.

3. **[Eigen docs — Writing efficient Matrix product expressions](https://eigen.tuxfamily.org/dox/TopicWritingEfficientProductExpressions.html)**  
   Industry pattern for **expression-template + SIMD dispatch** dense linear algebra—the policy surface lic should mirror for **G-math** (`matrix @`, fixed-size codegen) vs reference C++ benches.

4. **[Field G. Van Zee & Robert A. van de Geijn, “BLIS: A Framework for Rapidly Instantiating BLAS Functionality” (ACM)](https://doi.org/10.1145/2568219.2568263)**  
   Decomposes GEMM into **micro-kernel plus portable loop nests**—implementation checklist for SIMD matmul and blocked variants without weakening `threshold_ratio_cpp`.

Portable parallel / mesh-adjacent work for tier-2 physics (later tranche): [Kokkos programming model](https://kokkos.github.io/kokkos-core-wiki/), [PETSc Users Manual overview](https://petsc.org/release/manual/).

---

## Roadmap mapping (Li master-plan axes)

| Signal | Benchmark IDs | Primary plan hooks |
|--------|----------------|--------------------|
| Pure-Li float loop codegen / FMA fusion / strip-mining into SIMD | `horner_pure_li` | **PH-7e** (pure-Li SIMD / competitive codegen); **PH-5b** (numerics correctness under fast-math discipline) |
| Blocked GEMM locality + kernel shape | `matmul_blocked` (tier-1 exemplar); near-limit echoes in dense physics | **G-math** (GEMM/matmul lowering); **PH-5b** ABI & reference pinning vs Eigen/BLAS |
| SIMD + threaded neighbor / pair loops once pure-Li escapes `extern` hot paths | `nbody_gravity`, `harmonic_oscillator_chain`, `wave_equation_1d`, `double_pendulum` | **G-par** (decorators → OpenMP/IR policy); physics package track |
| Solver / scalable implicit time stepping (stretch, not regressing reds) | PDE-heavy rows in catalog | Align with PETSc/Kokkos exascale patterns — **li-langverse/lic#28**, **li-langverse/lic#35** |

---

## Proposed `lic` implementation path (coordinate with bench_improver)

1. **`horner_pure_li` contracts + lowering**  
   - Emit LLVM `fmul+fadd` fused where numerics permits; forbid unsafe `sorry`.  
   - Add micro-regression slice in `benchmarks/results` ingestion or compiler tests tied to emitted IR/feature flags (**do not raise** `threshold_ratio_cpp`; fix codegen).

2. **`matmul_blocked` near-limit**  
   - Tune block/MC/NC/KC analogs per target; cross-check Goto/BLIS loop order vs current `tier1_micro/matmul_blocked` shared C baseline. Document chosen parameters in harness comments only if they affect reproducibility.

3. **Tier-2 near-limit greens**  
   - Today Li often wraps `extern` kernels; performance delta is call + scalar memory traffic. Path: **PH-7e** vectorize inner loops in generated Li or shared microkernels, then **G-par** optional `parallel_for` over independent bodies once proofs carry.

4. **Bench evidence loop**  
   - Every merge that claims speedup must cite **bench row id** + command above + dashboard link (see org numerics PR gates).

---

## Control-plane note (agent health)

Recent `numerics_researcher` SDK runs in `li-control-plane-db` show `status=error` with `error = "SDK run status: error"` (no stack trace column populated). Treat as automation reliability debt; rerun from Cursor heap or escalate to platform—not a proof failure for the benchmarks themselves.
