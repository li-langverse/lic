# Linear algebra surface

User code should express numerical kernels as **math**, not compiler intrinsics.

## Implemented (v1)

| Form | Types | Lowering |
|------|-------|----------|
| `a @ b` / `dot(a, b)` | `array[N, float]` × `array[N, float]` → `float` | `ArrayDotF64` (4-wide SIMD gather when `N ≥ 4`) |
| `C = A @ B` | `array[M, array[K, float]]` × `array[K, array[N, float]]` → `array[M, array[N, float]]` | `ArrayMatMul2DF64` |
| `sum(a)` | `array[N, int]` or `array[N, float]` | `ArraySumF64` / `ArraySumI64` |
| `a + b`, `a - b`, `a * b`, `a / b`, `a ** b` | matching 1d numeric arrays, or `array[1, T]` broadcast to `array[N, T]` | `ArrayBinOpF64` / `ArrayBinOpI64` (+ `array_broadcast_*_len1` when one side has length 1) |
| `sum(a * b)` | product array then reduce | element-wise + `ArraySumF64` |

Inner-dimension mismatches on `@` fail at compile time (`li-tests/math_linalg/matmul_dim_mismatch.li`, `array_dot_mismatch.li`).

### `@` shape resolution (v1)

`@` resolves by **operand rank and element type** at typecheck; no runtime dispatch. Element-wise multiply is `*`, never `@`.

| Left | Right | Result | Rule |
|------|-------|--------|------|
| `array[N, float]` | `array[N, float]` | `float` | **1d dot** — same `N` |
| `array[M, array[K, float]]` | `array[K, array[N, float]]` | `array[M, array[N, float]]` | **2d GEMM** — inner `K` must match |
| inner `K` mismatch | — | — | **compile_fail** |
| `array[N, float]` | `array[M, float]` where `N ≠ M` | — | **compile_fail** |
| `array[N, int]` × any | — | — | **compile_fail** — v1 requires `float` elem |
| rank ≥ 3 nested `array` | — | — | **compile_fail** — deferred to Phase 3 `tensor` |

See [PH-2i plan](../superpowers/plans/2026-06-07-ph2i-matrix-at-shape-lowering.md) for the full test matrix and **PH-7e** handoff ([#27](https://github.com/li-langverse/lic/issues/27)).

### Lowering map

| `@` form | `MirOp` | Notes |
|----------|---------|-------|
| 1d dot | `ArrayDotF64` | 4-wide SIMD gather when `N ≥ 4` |
| 2d GEMM | `ArrayMatMul2DF64` | naive IKJ loop |
| sized 2d GEMM | `ArrayMatMulBlocked2DF64` | blocked hook (**PH-7e** partial) |

## Examples and benches

- Handbook: [Math-first HPC examples](../guide/math-hpc-examples.md)
- Tier 1 pure-Li: `benchmarks/tier1_micro/simd_dot/li/main.li`, `matmul_naive/li/main.li`

## Planned

```li
# target (Phase 2i / 7e)
C += A @ B
y[i] = alpha * x[i] + y[i]   # AXPY via index loop until `@vectorized`
```

- Full NumPy rank broadcast (only length-1 → longer 1d arrays today; `broadcast_len1_*.li`, `broadcast_invalid_len2_vs_len4.li`)
- `@vectorized` / `@parallel` lowering on math loops (**7d** / **7e-a**)
- `tensor[(M,N), f64]` when Phase 3 lands

See [math/linalg spec](../superpowers/specs/2026-05-16-li-math-linalg-surface.md) and **G-math** in [provability-gaps](../verification/provability-gaps.md).
