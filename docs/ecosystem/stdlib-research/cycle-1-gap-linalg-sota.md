# Cycle 1 — `gap_vs_sota` (linear algebra stdlibs)

- **Session:** `00de0db9-7e21-4eb3-9b85-f2d5a80294e6`
- **Goal:** `stdlib_ecosystem`
- **Step:** `gap_vs_sota` → linear algebra stdlibs
- **Completed:** 2026-05-27
- **north_star_fit:** ecosystem, scientific_computing, hpc — **PH-2i** (math/linalg surface), **PH-7e** (SIMD lowering), **PH-5b** (tier-1 validity/perf), **G-math** (shape + proof slices)

## Executive summary

- Li’s **production linalg** lives in the **compiler prelude** (`sum`, `dot`, `norm`, `axpy`) and **MIR lowering** (`ArrayDotF64`, `ArrayMatMul2DF64`, `ArrayMatMulBlocked2DF64`) — not in `std.math`, which is a **6-line tag stub** (`lic/std/math/math.li:1-6`).
- **SOTA baseline** (NumPy/BLAS/LAPACK, Eigen, Julia `LinearAlgebra`) exposes dense N-dimensional tensors, rank broadcast, decompositions (LU/QR/Cholesky/SVD), sparse formats, and iterative solvers — Li has **static 1d/2d array `@`**, **length-1 broadcast only**, and **no std/package decompositions**.
- **`li-math` / `li-std-math`** (~280 LOC) cover **graphics spatial math** (`Vec3`, `Quat`, `Mat4`) and thin wrappers over prelude `@`/`sum` — they do **not** replace a scientific `linalg` package (`lic/docs/ecosystem/algorithms-and-libraries-plan.md:213`).
- **`li-math-numerics`** is **integrators/ODE stepping** (Euler, Verlet, RK4 on small arrays) — orthogonal to BLAS-level linear algebra (`lic/packages/li-math-numerics/src/lib.li:21-80`).
- **Tier-1 benches:** `matmul_naive` / `matmul_blocked` are **green**; `simd_dot` is **red** at **1.44×** C++ because the Li driver still calls **C `li_simd_dot_kernel`** externs, not pure prelude `dot` (`lic/benchmarks/tier1_micro/simd_dot/li/main.li:4-22`, `benchmarks/data/latest/benchmark-matrix.json`).
- **Catalog honesty gap:** eight `num_*` linalg bench ids (`num_cg`, `num_cholesky`, `num_eig_symmetric`, `num_gmres`, `num_sparse_mv`, …) have **no harness paths** under `lic/benchmarks/tier1_micro/` (agent-briefing catalog gaps).
- **Proof posture:** **G-math Partial** — closed int P-linalg slices + shape compile_fail tests; float `vec3_dot` Props and full matmul universal certificate still open (`lic/docs/verification/provability-gaps.md`).
- **Handoff:** **package_architect** — place `packages/linalg` + `std.tensor`/`std.sparse` vs prelude-only; **code_implementer** — pure-Li `simd_dot`, `num_*` harness seeds, reconcile `li-std-math` with `std.math` exports (no product code in this run).

## Deliverable / findings

### 1. Li surface map (evidence)

| Layer | Location | What ships | Lines / symbol evidence |
|-------|----------|------------|-------------------------|
| Prelude builtins | `compiler/types/prelude.cpp:35-37` | `sum`, `dot`, `norm`, `axpy` sealed | User cannot shadow |
| MIR / codegen | `compiler/mir/lower.cpp:263-284`, `1163`, `1652`; `compiler/codegen/emit.cpp:1349-1417` | 1d dot (4-wide SIMD gather), 2d `@`, blocked matmul | Static shapes only |
| `std.math` | `lic/std/math/math.li` | `math_std_tag()` only | ```1:6:lic/std/math/math.li``` |
| `std.math.numerics` | `lic/std/math/numerics.li` | Policy header + tag | ```1:10:lic/std/math/numerics.li``` |
| `packages/li-math` | `packages/li-math/src/lib.li` | `Vec2/3/4`, `Quat`, `Mat4`, `vec3_*`, `array_dot_f64` → `@` | Mirrors `li-std-math` |
| `li-std-math` (org) | `li-std-math/src/lib.li` | Same spatial API; `li_std_math_version()` | Publish mirror of `li-math` |
| `li-std-core` | `li-std-core/src/lib.li` | Version stub only | No linalg |
| `li-math-numerics` | `packages/li-math-numerics/src/lib.li` | Time-steppers on `array[3/4, float]` | Not BLAS |
| Tests | `li-tests/math_linalg/` (27 files) | `@`, broadcast len-1, reductions compile_fail | `manifest.toml:951+` |
| Docs (truth) | `docs/language/linear-algebra.md:5-32` | v1 table matches compiler | Planned: full broadcast, `tensor[(M,N)]` |
| Docs (stale) | `docs/language/stdlib.md:53` | Claims no `std/collections` etc. | False since WP0-B — unrelated but confuses std audit |

**Prelude vs package:** Scientific array ops are **language builtins**; `import std.math` does not unlock `@` — see `docs/language/import-style.md:22` (preview). Packages must call prelude forms or duplicate small fixed-size structs.

### 2. SOTA reference (what “done” looks like)

| Capability | NumPy / SciPy | BLAS/LAPACK | Eigen | Julia `LinearAlgebra` | Li today |
|------------|---------------|-------------|-------|----------------------|----------|
| N-dim `ndarray` / tensor | `numpy.ndarray`, ufuncs | — | `MatrixXd` dynamic | `Array{T,N}` | Static `array[N,T]`, nested `array[M,array[K,T]]` for 2d |
| Rank broadcast | full NumPy rules | — | limited | full | **length-1 → N only** (`broadcast_len1_add_float4.li:11-13`) |
| Level-1 BLAS | `dot`, `axpy`, `nrm2` | `*dot*`, `*axpy*` | `Vector` ops | built-in | prelude `dot`/`axpy`/`norm`/`sum` |
| Level-3 GEMM | `A @ B` → OpenBLAS | `dgemm` | `operator*` | `@` | `ArrayMatMul2DF64` / blocked MIR; tier-1 pure-Li loops |
| Decompositions | `linalg.lu/qr/cholesky/svd` | `*getrf*`, `*potrf*`, … | `PartialPivLU`, etc. | `lu`, `cholesky`, `eigen` | **none** in std or packages |
| Sparse | `scipy.sparse` CSR/CSC | sparse BLAS | `SparseMatrix` | `SparseArrays` | **planned** `std/sparse.li` only in preview tree (`stdlib.md:37`) |
| Iterative solvers | `scipy.sparse.linalg.cg` | — | unsupported core | `IterativeSolvers` | catalog ids only; **paths missing** |
| Proof / shape errors | runtime `ValueError` | — | compile-time C++ | some static | **compile-time** mismatch tests (`matmul_dim_mismatch.li`) |

**North-star alignment:** Li correctly prioritizes **compile-time shape failures** over NumPy-style runtime errors — but lacks the **library breadth** HPC users expect once shapes are valid.

### 3. Gap matrix (Li vs SOTA)

| Gap ID | SOTA expectation | Li evidence | Severity | PH / gate |
|--------|------------------|-------------|----------|-----------|
| G-LA-01 | `std.linalg` or `import linalg` for solves/decomps | `algorithms-and-libraries-plan.md:213` — `packages/linalg` **missing** | High | 2i → Phase 3 |
| G-LA-02 | `std.tensor` / rank-N | `stdlib.md:36-37` preview only; `linear-algebra.md:31-32` | High | Phase 3 |
| G-LA-03 | `std.sparse` CSR matvec | No `lic/std/sparse*`; `num_sparse_mv` catalog path missing | High | Phase 3, PH-5b |
| G-LA-04 | Full NumPy broadcast | `master-plan.md:446` — partial len-1 only | Medium | 2i |
| G-LA-05 | Pure-math `simd_dot` bench | `simd_dot/li/main.li` uses C kernel + comment on `-ffast-math` zeroing | **Perf red** | 7e, PH-5b |
| G-LA-06 | `num_*` tier-1 harnesses | briefing: paths missing for `num_cg`, `num_cholesky`, … | Medium | PH-5b |
| G-LA-07 | `std.math` re-exports prelude | tag-only `math_std_tag` vs rich `li-math` | Medium | ecosystem |
| G-LA-08 | Float linalg Lean Props | `vec3_ops.li` scalar loop; P-linalg float closed slices partial | Medium | G-math, 2f |
| G-LA-09 | `@vectorized` on math loops | `execution/decorators.li` doc-only; matmul uses MIR not decorator | Medium | 7d/7e |
| G-LA-10 | Duplicate publish mirrors | `li-math` ≡ `li-std-math` (~same `lib.li`) | Low | lip publish |

### 4. Benchmark / registry cross-check

| Bench id | Status (2026-05-27 matrix) | Li implementation notes |
|----------|----------------------------|---------------------------|
| `matmul_naive` | green 0.64× | Pure-Li 256×256 (`matmul_naive/li/main.li`) |
| `matmul_blocked` | green 1.14× | MIR `ArrayMatMulBlocked2DF64` hook |
| `simd_dot` | **red 1.44×** | Extern C dot, not prelude |
| `reduce_sum` | green | Prelude reduction path |
| `horner_pure_li` | unknown | Separate polynomial track (PH-7e) |
| `num_cholesky`, `num_eig_symmetric`, `num_cg`, `num_gmres`, `num_sparse_mv` | unknown (no harness dir) | Registry placeholder only |

### 5. Package placement recommendation (handoff — no implementation)

| Action | Target | Rationale |
|--------|--------|-----------|
| **Build** | `packages/linalg` (monorepo) + optional `li-std-linalg` publish mirror | Holds Cholesky/CG/GMRES **after** prelude shapes + proofs; keeps `li-math` graphics-only |
| **Improve** | `li-math`, `li-std-math` | Document as **spatial** layer; add `quat_*`/`mat4_mul` per algorithms plan §7.1 — not GEMM |
| **Improve** | `std.math` + `std.math.numerics` | Re-export prelude wrappers + numerics policy; replace tag-only stub when WP1 unblocks |
| **Improve** | `li-math-numerics` | Stay integrators; depend on `linalg` for implicit solves later |
| **std_modules_to_add** | `std.tensor`, `std.sparse`, `std.linalg` (or merge into `std.math.numerics` subtree) | Match `stdlib.md` preview + master plan Phase 3 |
| **Defer** | Vendor BLAS bind until `lic build` certificate story for extern LAPACK | Proof-before-perf pillar |

## Recommended issues/PRs

| Repo | Title | Labels (suggested) |
|------|-------|-------------------|
| **lic** | `feat(linalg): pure-Li simd_dot tier-1 driver (prelude dot/@vectorized)` | `PH-7e`, `PH-5b`, `bench` |
| **lic** | `feat(linalg): scaffold packages/linalg + li-tests smoke (solve/decomp stubs)` | `PH-2i`, `ecosystem` |
| **lic** | `docs(stdlib): refresh stdlib.md shipped tree + linear-algebra import path` | `docs`, `PH-2i` |
| **lic** | `test(math_linalg): tier-1 num_* harness dirs for cholesky/cg/gmres/sparse_mv` | `PH-5b`, `bench` |
| **li-std-math** | `chore: align README/traceability with spatial-only scope vs scientific linalg` | `ecosystem` |
| **benchmarks** | `chore: register num_* linalg paths when lic harness lands` | `catalog` |
| **roadmap** | `proposal: std.tensor/sparse phase gates vs packages/linalg` | `governance` |

## Deferred

- `audit_package` / `li-std-core` deep audit — rolled to cycle 2 or `synthesize_step` merge.
- `synthesize_step` cycle summary — **next queue item** (do not start in this run).
- research-findings whitepaper — **skipped** (`stdlib_ecosystem` has no `publish_subdir` in factory context; digest stays under `lic/docs/ecosystem/stdlib-research/`).
- External BLAS/LAPACK linking and GPU tensor buffers (Phase 3 / `lig`).
- Full NumPy rank broadcast specification and `@vectorized` on user axpy loops.

## Cycle 1 rolling outputs (updated)

```yaml
packages_to_build:
  - packages/linalg          # N×M decompositions, solves, sparse hooks (algorithms plan §7.1)
  - li-std-linalg            # optional org publish mirror after monorepo API stabilizes
packages_to_improve:
  - li-math                  # spatial/quat scope; wire scene transforms; do not absorb GEMM
  - li-std-math              # sync with li-math; clarify vs scientific linalg in README
  - std.math                 # re-export prelude + policy from numerics.li
  - std.math.numerics        # document goldens linkage; grow after linalg package exists
  - li-math-numerics         # keep integrators; depend on linalg for implicit solves later
std_modules_to_add:
  - std.tensor               # Phase 3 — rank-N (stdlib.md preview)
  - std.sparse               # Phase 3 — CSR/CSC
  - std.linalg               # or std.math.linalg — high-level solves API surface
  - std.summary              # PH-IO-7 (from inventory step)
  - std.plot                 # PH-IO-5 (from inventory step)
connections:
  - prelude sum/dot/norm/axpy → compiler MIR (PH-2i) — not std.math files
  - MIR ArrayMatMul* / ArrayDotF64 → tier1_micro matmul_*, reduce_sum
  - simd_dot bench → li_simd_dot_kernel C (gap: not math-only per linalg plan §7e-a)
  - li-math / li-std-math → graphics/physics packages (Vec3, Mat4)
  - li-math-numerics → li-sim-scientific integrators
  - algo_registry num_* ids → missing tier1_micro harness (catalog drift)
  - planned packages/linalg → benchmarks num_cholesky, num_cg, fea/qm verticals
```

## Handoff

- **package_architect:** Confirm `packages/linalg` vs `std.linalg` split; whether `li-std-math` stays spatial-only; lip publish graph for `li-std-linalg`.
- **code_implementer:** Pure-Li `simd_dot`; seed `num_*` harnesses; extend `math_linalg` for float Props; refresh `stdlib.md:53`.
- **numerics_researcher / bench_improver:** `simd_dot` red row; strict tier-1 CSV refresh (`PH-5b`, `PH-7e`).
- **north_star_fit:** Provable static shapes first (Li strength) → then decompositions/solvers in proved packages — no unproved `unsafe` BLAS shortcut in v1.

---

## Addendum (verification pass) — 2026-05-27

This addendum exists to tighten the “file:line evidence” chain for the key linear-algebra stdlib claims.

### Verified: linalg surface is **prelude + lowering**, not `std.math`

- **Prelude proc seal includes** `sum`, `dot`, `norm`, `axpy`:
  - `lic/compiler/types/prelude.cpp:35-38`
- **`std.math` is still a tag-only stub**:
  - `lic/std/math/math.li:1-6`

### Verified: dot/matmul are real MIR ops with LLVM emission (including SIMD gather for dot)

- **MIR lowering emits** `MirOp::ArrayDotF64` when both sides are float arrays with equal static length:
  - `lic/compiler/mir/lower.cpp:263-287`
- **LLVM codegen emits**:
  - `MirOp::ArrayMatMul2DF64` loop/unroll decision + emission (`use_loops` cutover)
  - `MirOp::ArrayMatMulBlocked2DF64` blocked kernel emission
  - `MirOp::ArrayDotF64` with **4-wide vector gather** when enabled and \(N \ge 4\), then scalar tail
  - Evidence: `lic/compiler/codegen/emit.cpp:1349-1417`

### Verified: current `simd_dot` tier-1 Li driver still calls a C kernel

- `lic/benchmarks/tier1_micro/simd_dot/li/main.li:1-3` explains why a pure-Li reduction is deferred under `-ffast-math`.
- `lic/benchmarks/tier1_micro/simd_dot/li/main.li:4-23` shows the benchmark is wired through `extern proc li_simd_dot_kernel()` + checksum sink.

### Confirmed docs drift to fix (affects stdlib research consumers)

- `lic/docs/language/stdlib.md:53` still claims “no `std/collections`, `std/heap`, or `std/algorithms` sources yet” — contradicts shipped files under `lic/std/collections/`, `lic/std/heap/`, `lic/std/algorithms/` (see inventory digest step 1).
