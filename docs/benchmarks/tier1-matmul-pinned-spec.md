# Tier-1 matmul PINNED spec (benchmarks handoff)

**Policy:** [numerics-reference-backlog.md](../ecosystem/numerics-reference-backlog.md)  
**Issue:** [lic#33](https://github.com/li-langverse/lic/issues/33)  
**Benchmarks target paths:** `benchmarks/workloads/tier1_micro/matmul_naive/PINNED.md`, `matmul_blocked/PINNED.md`

This document is the **lic-side canonical spec** for benchmarks `PINNED.md` files (wp-math-r2). Copy or mirror into the benchmarks repo in a sibling PR.

---

## Pinned reference matrix

| Axis | Value |
|------|-------|
| Eigen (CI default) | **3.4.1** |
| Eigen (forward) | **5.0.0** |
| C++ standard | **C++17** (`-std=c++17`) |
| BLAS (default) | **OpenBLAS** 0.3.x |
| BLAS (optional) | Intel MKL (competitive column only) |

---

## Column honesty

| Column id | Build | Primary `ratio_vs_cpp`? |
|-----------|-------|-------------------------|
| `cpp` / `cpp_handrolled` | Hand-rolled IKJ C in `common/matmul_*_core.c` | **Yes** |
| `cpp_eigen` | Eigen `MatrixXd` GEMM (future) | **No** — advisory until built |
| `python_numpy` | NumPy `@` → OpenBLAS/MKL | PH-ML rows only (`blas_labeled`) |

**Important:** The tier-1 `cpp` column is **not Eigen**. It is hand-rolled C (BLIS-style IKJ). Do not claim Eigen parity on the primary cpp gate.

---

## PINNED.md template (per workload)

Each `matmul_naive` / `matmul_blocked` workload should include:

```markdown
# PINNED — tier-1 matmul reference columns

| Column | Implementation | ratio_vs_cpp primary? |
|--------|----------------|----------------------|
| cpp / cpp_handrolled | common/matmul_*_core.c IKJ (hand-rolled C, not Eigen) | Yes |
| cpp_eigen | Eigen 3.4.1 MatrixXd GEMM (planned) | No |
| python_numpy | NumPy → OpenBLAS (PH-ML only) | No |

Policy: lic docs/ecosystem/numerics-reference-backlog.md
C++ baseline: C++17. BLAS: OpenBLAS 0.3.x default.
```

---

## External refs

- [Eigen releases](https://libeigen.gitlab.io/releases/)
- [Eigen 5.0](https://libeigen.gitlab.io/releases/5.0/)
- [Eigen 3.4.1](https://libeigen.gitlab.io/news/eigen_3.4.1_released/)
