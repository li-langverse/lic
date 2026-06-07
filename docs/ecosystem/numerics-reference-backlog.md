# Numerics reference backlog — vendor pins (math-r)

**Plan:** [2026-06-07-eigen-numerics-reference-policy.md](../superpowers/plans/2026-06-07-eigen-numerics-reference-policy.md)  
**Issue:** [lic#33](https://github.com/li-langverse/lic/issues/33)  
**Cadence umbrella:** [benchmarks#27](https://github.com/li-langverse/benchmarks/issues/27)

Status: **planned** — pin matrix drafted; gates land after `plan-approved`.

---

## Pin block (canonical — do not drift)

| Vendor / axis | Pinned version | C++ / ABI | CI default |
|---------------|----------------|-----------|------------|
| **Eigen (current)** | **3.4.1** | C++17 | Yes — `cpp_eigen` stub target |
| **Eigen (forward)** | **5.0.0** | C++17; BLAS wrapper ABI change | Optional profile `eigen-5-blaspinned` |
| **BLAS** | **OpenBLAS** 0.3.x | `cblas_*` / `sgemm`/`dgemm` | Yes |
| **BLAS (optional)** | Intel **MKL** | Same ABI family | Competitive column only |
| **NumPy** | See `results/ph-ml-competitive.json` | dispatches to OpenBLAS/MKL | PH-ML rows |

---

## Column honesty (tier-1 matmul)

| Column | Implementation | `ratio_vs_cpp` primary? |
|--------|----------------|-------------------------|
| `cpp` / hand-rolled | `common/matmul_*_core.c` IKJ | **Yes** |
| `cpp_eigen` | Eigen `MatrixXd` GEMM | **No** (advisory until built) |
| `python_numpy` | NumPy → BLAS | PH-ML only |

---

## Open work packages

| ID | Deliverable | Status |
|----|-------------|--------|
| wp-math-r1-backlog | This doc + bump procedure | **planned** |
| wp-math-r2-pinned-md | benchmarks `PINNED.md` | pending |
| wp-math-r3-gate-script | `check-numerics-reference-pins.sh` | pending |
| wp-math-r4-cpp-eigen-stub | optional Eigen build | pending |
| wp-math-r5-std-math-docs | `li-std-math` cross-links | pending |
| wp-math-r7-eigen5-migration | Eigen 5 BLAS ABI study | deferred |

---

## Release bump procedure

1. Watch [Eigen releases](https://libeigen.gitlab.io/releases/) and [benchmarks#27](https://github.com/li-langverse/benchmarks/issues/27).
2. Minor/patch bump → update pin block + re-run tier-1 ingest (no threshold change).
3. Major bump (e.g. 3.4 → 5.0) → numerics study + human ack before default flip.
4. Never weaken `threshold_ratio_cpp` to absorb reference drift.
