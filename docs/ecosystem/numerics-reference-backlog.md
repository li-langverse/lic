# Numerics reference backlog — vendor pins (math-r)

**Plan:** [2026-06-07-eigen-numerics-reference-policy.md](../superpowers/plans/2026-06-07-eigen-numerics-reference-policy.md)  
**Issue:** [lic#33](https://github.com/li-langverse/lic/issues/33)  
**Cadence umbrella:** [benchmarks#27](https://github.com/li-langverse/benchmarks/issues/27)  
**Tier-1 handoff spec:** [tier1-matmul-pinned-spec.md](../benchmarks/tier1-matmul-pinned-spec.md)

Status: **active** — pin matrix enforced by `scripts/check-numerics-reference-pins.sh` (wired into `check-hpc-competitive.sh`).

---

## Pin block (canonical — do not drift)

| Vendor / axis | Pinned version | C++ / ABI | CI default |
|---------------|----------------|-----------|------------|
| **Eigen (current)** | **3.4.1** | **C++17** (`-std=c++17`) | Yes — `cpp_eigen` stub target |
| **Eigen (forward)** | **5.0.0** | **C++17**; BLAS wrapper ABI change | Optional profile `eigen-5-blaspinned` |
| **BLAS** | **OpenBLAS** 0.3.x | `cblas_*` / `sgemm`/`dgemm` | Yes |
| **BLAS (optional)** | Intel **MKL** | Same ABI family | Competitive column only |
| **NumPy** | See `results/ph-ml-competitive.json` | dispatches to OpenBLAS/MKL | PH-ML rows |

---

## Column honesty (tier-1 matmul)

| Column | Implementation | `ratio_vs_cpp` primary? |
|--------|----------------|-------------------------|
| `cpp` / `cpp_handrolled` | `common/matmul_*_core.c` hand-rolled IKJ C | **Yes** — not Eigen |
| `cpp_eigen` | Eigen `MatrixXd` GEMM | **No** (advisory until built) |
| `python_numpy` | NumPy → BLAS (`blas_labeled`) | PH-ML only |

The tier-1 `cpp` column is **hand-rolled C** (BLIS-style IKJ), not Eigen or vendor BLAS. Do not relabel as `cpp_eigen` without a pinned Eigen build.

---

## Work package status

| ID | Deliverable | Status |
|----|-------------|--------|
| wp-math-r1-backlog | This doc + bump procedure | **done** |
| wp-math-r2-pinned-md | benchmarks `PINNED.md` (sibling repo) | pending — see [tier1-matmul-pinned-spec.md](../benchmarks/tier1-matmul-pinned-spec.md) |
| wp-math-r3-gate-script | `check-numerics-reference-pins.sh` + HPC gate | **done** |
| wp-math-r4-cpp-eigen-stub | optional Eigen build (benchmarks) | pending |
| wp-math-r5-std-math-docs | `li-std-math` cross-links | **done** |
| wp-math-r6-provability | `provability-gaps.md` G-math slice | **done** |
| wp-math-r7-eigen5-migration | Eigen 5 BLAS ABI study | deferred |

---

## Release bump procedure

1. Watch [Eigen releases](https://libeigen.gitlab.io/releases/) and [benchmarks#27](https://github.com/li-langverse/benchmarks/issues/27).
2. **Patch/minor bump** (e.g. 3.4.1 → 3.4.2): update pin block here + benchmarks `PINNED.md` in the same PR; re-run tier-1 ingest. Do **not** change `threshold_ratio_cpp`.
3. **Major bump** (e.g. 3.4 → 5.0): file numerics study (`docs/numerics/studies/`) + human ack before default flip; test `EIGEN_USE_BLAS` ABI on CI image.
4. Re-run `./scripts/check-numerics-reference-pins.sh` and `./scripts/check-hpc-competitive.sh` after any pin change.
5. Never weaken `threshold_ratio_cpp` to absorb reference drift — investigate ratio shift instead.

---

## Gate

```bash
./scripts/check-numerics-reference-pins.sh   # exit 0 when pins present
./scripts/check-hpc-competitive.sh           # includes numerics pin gate
```
