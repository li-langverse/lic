# Numerics researcher pass — 2026-05-20 (run `84241347`)

**Agent:** `numerics_researcher`  
**Branch:** `chore/agent-numerics_researcher-84241347`  
**Preflight:** `ecosystem_audit` (2026-05-20T19:49Z), `ecosystem_explorer`  
**Dashboard (stale ingest):** https://li-langverse.github.io/benchmarks/  
**Org tracking:** https://github.com/li-langverse/benchmarks/issues/31  
**Related PRs (human merge):** benchmarks [#47](https://github.com/li-langverse/benchmarks/pull/47), lic [#85](https://github.com/li-langverse/lic/pull/85) (horner anti-DCE)

---

## Target selection

| Source | Command / filter |
|--------|------------------|
| Preflight `benchmarks.red` | `horner_pure_li` ratio **88.82×** (ingest 2026-05-16) |
| Preflight `near_threshold` | `matmul_blocked`, `nbody_gravity`, `double_pendulum`, `wave_equation_1d`, `harmonic_oscillator_chain` (1.02–1.04× on dashboard) |
| **Local tier-1** (this run) | `./scripts/benchmark-failures-report.sh` after `bench.py --tier 1` |

**Local failures report** (`git_sha=c3deeeb`, 3 runs, `THRESHOLD_RATIO_CPP=1.2`):

| Catalog id | li/cpp | Status |
|------------|--------|--------|
| `matmul_naive` | **1.30×** | RED (not on stale dashboard — wrapper/link overhead) |
| `matmul_blocked` | **1.02×** | near-limit |
| `horner_pure_li` | **0.40×** | misleading green — **DCE** (see below) |
| `reduce_sum`, `simd_dot` | ≤1.0× | green |

Tier-2 harness on this tree failed at `md_lennard_jones` Li build (`disjoint_elem` missing); near-limit physics ratios below are from **dashboard ingest** until tier-2 verify is unblocked.

---

## Mode A — SOTA survey

### 1. Horner / scalar FMA chains (`horner_pure_li`) — P0

**Learned from**

1. Press et al., *Numerical Recipes* — Horner evaluation (Ch. 5). https://numerical.recipes/
2. LLVM loop passes — LICM and dead-code elimination at `-O3`. https://llvm.org/docs/Passes.html
3. Li autoresearch — lexer `+` → `Minus` falsification. [autoresearch-horner-lexer-2026-05-18.md](autoresearch-horner-lexer-2026-05-18.md)
4. Compiler benchmark hygiene — volatile checksum sink (C `horner_core.c`) vs pure-Li `return 0` without observable `acc` (lic #85).

**Map:** **PH-5b** (fp policy / fair compare), **PH-7e** (pure-Li loop codegen must retain timed work).

**Root cause (2026-05-20):** Dashboard **88×** is dominated by (a) historical lexer bug (fixed; `li-tests` → `lexer_parser/plus_minus_binop.li`) and (b) **benchmark honesty**: `horner_pure_li/li/main.li` returns constant `0` while C++ stores `acc` through `volatile` (`horner_core.c`). Local run without anti-DCE reports **0.40×** — a false green; verify line shows `native checksum=inf` for Li (stale/zero path).

**Implementation path (lic — `bench_improver`, not threshold edits):**

| Step | Artifact |
|------|----------|
| 1 | Merge lic #85: `li_rt_volatile_sink_f64` + thread `acc` into `return` / sink in `horner_pure_li/li/main.li` |
| 2 | Extend `bench.py` pure_li guard (reject `li_time < 0.45 × native`) |
| 3 | Re-ingest; expect honest ratio ≫1× until PH-7e SIMD/unroll (then optimize) |

**Do not** lower `threshold_ratio_cpp`.

---

### 2. Blocked dense GEMM (`matmul_blocked`, `matmul_naive`)

**Learned from**

1. Goto & van de Geijn, “Anatomy of High-Performance Matrix Multiplication,” *ACM TOMS* 2008. https://www.cs.utexas.edu/~flame/pubs/GotoTOMS.pdf
2. BLIS — Goto-style micro-kernel + macro-kernel layering. https://github.com/flame/blis
3. Van Zee & Smith, BLIS IPDPS 2014 — five loops around register micro-kernel. https://www.cs.utexas.edu/users/flame/pubs/blis3_ipdps14.pdf
4. Eigen 3.4+/5.0 — expression templates + optional BLAS. https://eigen.tuxfamily.org/ (policy: lic #33)

**Map:** **PH-5b**, **PH-7e**, **G-math** (`C += A @ B`, 512³ with `LI_MB_BK=64` blocks per `matmul_blocked_core.c`).

**Gap:** Li column still `extern` C (`matmul_blocked/li/main.li`). Plan: math-only Li in `docs/superpowers/plans/2026-05-16-li-math-linalg-surface.md`.

**Implementation path:**

| Step | Owner | Deliverable |
|------|-------|---------------|
| Blocked `@` + `@vectorized` inner | codegen PH-7e | Pure-Li `matmul_blocked` matching i-k-j tile |
| Reference ABI | lic #33 | Pin Eigen/BLIS for optional cpp column |
| Contracts | li-tests | `math_linalg/matmul/` rows (planned) |
| Near-limit 1.02× | bench_improver | Profile Li **wrapper** vs `li_matmul_blocked_kernel` — may be link/startup, not algebra |
| RED `matmul_naive` 1.30× | bench_improver | Same wrapper path; naive kernel is smaller — overhead dominates |

---

### 3. Direct N-body (`nbody_gravity`)

**Learned from**

1. Barnes & Hut, *Nature* 1986 — O(N log N) tree. https://doi.org/10.1038/324446a0
2. Greengard & Rokhlin 1987 — fast multipole (large-N). https://doi.org/10.1016/0021-9991(87)90118-9
3. Li policy — T1 Verlet / T2 Barnes–Hut: `docs/physics/numerical-policy.md`

**Map:** **G-math** (force sum), **G-par** (outer `i` parallel loop, decorator → OpenMP per lic #34).

**Implementation path:** Short term — `@parallel` on outer particle index with disjoint forces array; tier-2 — Barnes–Hut in `packages/li-std-physics-*`. Implicit PDE track stays hypre/PETSc (#108), not N-body.

---

### 4. Symplectic tier-2 (`double_pendulum`, `harmonic_oscillator_chain`)

**Learned from**

1. Hairer, Lubich, Wanner, *Geometric Numerical Integration*. https://www.springer.com/series/7021
2. Leimkuhler & Reich, *Simulating Hamiltonian Dynamics* (Verlet family).

**Map:** **G-math** — structure-preserving integrators per `numerical-policy.md` T1/T2 table.

**Implementation path:** Velocity Verlet in shared `*_core.c`; squeeze 1.02–1.03× via PH-7e pure-Li integrator loops + `@cpu` hot-path codegen + `benchmarks/harness/stability.py` energy drift rows.

---

### 5. Hyperbolic 1D wave (`wave_equation_1d`)

**Learned from**

1. LeVeque, *Finite Volume Methods for Hyperbolic Problems* (CFL, leapfrog). https://www.cambridge.org/core/books/finite-volume-methods-for-hyperbolic-problems/

**Map:** **G-math** (stencil), **G-par** (interior spatial loop).

**Implementation path:** Align Li driver stencil with `wave_core.c`; add `parallel(disjoint=…)` when 2D rows mature (lic #15 Kokkos-class memory spaces).

---

## Evidence pack (mandatory)

| Kind | Id / path | Command / result |
|------|-----------|------------------|
| li-tests | `lexer_parser/plus_minus_binop.li` | `./li-tests/run_all.sh lexer_parser` → **5 passed** (this run) |
| Bench harness | tier-1 rows | `LIC=build/compiler/lic/lic python3 benchmarks/harness/bench.py --tier 1 --runs 3` |
| Failures script | `scripts/benchmark-failures-report.sh` | `./scripts/benchmark-failures-report.sh` |
| Numerics doc | **this file** | `docs/numerics/2026-05-20-researcher-pass.md` |
| CSV row ids | `horner_pure_li`, `matmul_blocked`, `matmul_naive` | `benchmarks/results/latest.csv` (local; gitignored) |
| Dashboard | stale red | https://li-langverse.github.io/benchmarks/ — refresh after lic #85 + ingest |

---

## Coordination

| Work | Agent | Blocker |
|------|-------|---------|
| horner anti-DCE + honest timing | **bench_improver** | lic #85 |
| SOTA prose on org repo | **benchmarks** | PR #47 |
| `@` / blocked matmul lowering | **code_implementer** | PH-7e, lic #20 |
| tier-2 `disjoint_elem` build | **code_implementer** | blocks `bench.py --tier 2` |
| Novel pure_li algos only after SOTA exhausted | **autoresearch** | — |

---

## Recommended issues

1. **lic:** `numerics-research: horner_pure_li — merge anti-DCE (lic #85) before PH-7e SIMD` — labels `numerics-research`, `PH-7e`, `PH-5b`
2. **lic:** `numerics-research: matmul_naive wrapper 1.30× — profile link path vs blocked GEMM plan` — labels `numerics-research`, `G-math`, `PH-7e`
3. **lic:** `numerics-research: tier-2 bench.py — export disjoint_elem for physics Li drivers` — labels `numerics-research`, `G-par`
4. **benchmarks:** Refresh ingest after lic #85; close/update #31

---

## Test plan

```bash
# Evidence slice (green this run)
./li-tests/run_all.sh lexer_parser

# Tier-1 timings + failures report
cmake -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j
LIC=build/compiler/lic/lic python3 benchmarks/harness/bench.py --tier 1 --runs 7
./scripts/benchmark-failures-report.sh

# Tier-2 (blocked until disjoint_elem)
LIC=build/compiler/lic/lic python3 benchmarks/harness/bench.py --tier 2 --runs 3

# Org dashboard ingest (benchmarks repo)
cd benchmarks && ./scripts/benchmark-failures-report.sh
```

**Done criteria:** Dashboard `horner_pure_li` reflects **honest** post-#85 ratio; near-limit five ≤1.0× or documented compiler gap; no `threshold_ratio_cpp` change.
