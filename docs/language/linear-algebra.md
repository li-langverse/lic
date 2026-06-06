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

### Broadcast rules (explicit math only)

Li does **not** implement NumPy-style rank broadcast. Element-wise operators accept:

1. **Same length** — `array[N, T]` with `array[N, T]`.
2. **Length-1 promotion (1d only)** — `array[1, T]` with `array[N, T]` (either side).
3. **Scalar × array** — `float` with `array[N, float]`.

Everything else fails at compile time, including:

| Shape pair | Result | Corpus |
|------------|--------|--------|
| `array[2]` × `array[4]` | **fail** — not length-1 | `broadcast_invalid_len2_vs_len4.li` |
| `array[4]` × `array[8]` | **fail** | `elementwise_len_mismatch.li` |
| `array[M, array[N, float]]` × `array[M, array[1, float]]` | **fail** — rank-2 NumPy row broadcast | `broadcast_invalid_rank2_m3n_vs_m1.li` |
| `array[M, array[N, float]]` + `array[1, array[N, float]]` | **fail** — rank-2 column broadcast | `broadcast_invalid_rank2_m3n_vs_1n.li` |

Full multidimensional rank rules remain **deferred** ([#526](https://github.com/li-langverse/lic/issues/526)) until `tensor[(M,N), T]` and per-axis Lean proofs land.

Inner-dimension mismatches on `@` fail at compile time (`li-tests/math_linalg/matmul_dim_mismatch.li`, `array_dot_mismatch.li`).

## Examples and benches

- Handbook: [Math-first HPC examples](../guide/math-hpc-examples.md)
- Tier 1 pure-Li: `benchmarks/tier1_micro/simd_dot/li/main.li`, `matmul_naive/li/main.li`

## Planned

```li
# target (Phase 2i / 7e)
C += A @ B
y[i] = alpha * x[i] + y[i]   # AXPY via index loop until `@vectorized`
```

- Full NumPy rank broadcast — **deferred** ([#526](https://github.com/li-langverse/lic/issues/526)); length-1 → longer **1d** only today (`broadcast_len1_*.li`); rank-2 promotion rejected (`broadcast_invalid_rank2_*.li`, `broadcast_invalid_len2_vs_len4.li`)
- `@vectorized` / `@parallel` lowering on math loops (**7d** / **7e-a**)
- `tensor[(M,N), f64]` when Phase 3 lands

See [math/linalg spec](../superpowers/specs/2026-05-16-li-math-linalg-surface.md) and **G-math** in [provability-gaps](../verification/provability-gaps.md).
