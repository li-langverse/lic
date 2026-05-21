# Linear algebra surface

User code should express numerical kernels as **math**, not compiler intrinsics.

## Implemented (v1)

| Form | Types | Lowering |
|------|-------|----------|
| `a @ b` / `dot(a, b)` | `array[N, float]` × `array[N, float]` → `float` | `ArrayDotF64` (4-wide SIMD gather when `N ≥ 4`) |
| `C = A @ B` | `array[M, array[K, float]]` × `array[K, array[N, float]]` → `array[M, array[N, float]]` | `ArrayMatMul2DF64` |
| `sum(a)` | `array[N, int]` or `array[N, float]` | `ArraySumF64` / `ArraySumI64` |
| `a + b`, `a - b`, `a * b`, `a / b` | matching 1d numeric arrays | `ArrayBinOpF64` (4-wide SIMD gather/scatter when `N ≥ 4`) / `ArrayBinOpI64` |
| `sum(a * b)` | product array then reduce | element-wise + `ArraySumF64` |

Inner-dimension mismatches on `@` fail at compile time (`li-tests/math_linalg/matmul_dim_mismatch.li`, `array_dot_mismatch.li`).

## Examples and benches

- Handbook: [Math-first HPC examples](../guide/math-hpc-examples.md)
- Tier 1 pure-Li: `benchmarks/tier1_micro/simd_dot/li/main.li`, `matmul_naive/li/main.li`

## Design: no implicit broadcast

Li does **not** plan NumPy-style broadcasting (repeating a shorter array/scalar shape to match a longer one without saying so). Reasons:

1. **Clarity** — mismatched lengths are not the same mathematical object; silent promotion confuses readers and agents.
2. **Provability** — same-dimension operations are easy to state in `requires`/`ensures`; implicit repetition is not.

Use instead:

- **Matching-length** element-wise ops (`a * b` when `len(a) == len(b)`).
- **Explicit loops** for AXPY and similar — e.g. `for i in 0..<N: y[i] = alpha * x[i] + y[i]` with optional `@vectorized` / `@parallel`.
- **Named functions** when the pattern is standard (`dot`, `sum`; future `axpy`, `norm`, `scale`).

## Planned

```li
# AXPY — explicit and readable (not broadcast sugar)
for i in 0..<N
  y[i] = alpha * x[i] + y[i]
```

- Same-length `**` on arrays (optional); named reductions (`norm`, `axpy` proc)
- Deeper `@vectorized` / `@parallel` on math loops (**7d** / **7e**)
- `tensor[(M,N), f64]` when Phase 3 lands

See [math/linalg spec](../superpowers/specs/2026-05-16-li-math-linalg-surface.md) and **G-math** in [provability-gaps](../verification/provability-gaps.md).
