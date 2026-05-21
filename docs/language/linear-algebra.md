# Linear algebra surface (planned)

User code should express numerical kernels as **math**, not compiler intrinsics:

```li
# target (phase 2i / 7e)
C += A @ B
y[i] = alpha * x[i] + y[i]
```

For matching 1d `array[N, float]` operands, `a @ b` and `dot(a, b)` lower to the same dot-product loop (`ArrayDotF64` MIR).

For fixed 2d tiles `array[M, array[K, float]] @ array[K, array[N, float]]`, the result type is `array[M, array[N, float]]`; inner-dimension mismatches fail at compile time (`li-tests/math_linalg/matmul_dim_mismatch.li`). Lowering is a scalar triple loop today (**2i-c**); SIMD / `@parallel` on matmul (**7e-a/b**) is planned.

See [math/linalg spec](../superpowers/specs/2026-05-16-li-math-linalg-surface.md) and **G-math** in [provability-gaps](../verification/provability-gaps.md).
