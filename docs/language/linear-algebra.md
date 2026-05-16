# Linear algebra surface (planned)

User code should express numerical kernels as **math**, not compiler intrinsics:

```li
# target (phase 2i / 7e)
C += A @ B
y[i] = alpha * x[i] + y[i]
```

For matching 1d `array[N, float]` operands, `a @ b` lowers to a compile-time dot product loop (**7e** partial). Full matrix shapes and SIMD lowering are planned.

See [math/linalg spec](../superpowers/specs/2026-05-16-li-math-linalg-surface.md) and **G-math** in [provability-gaps](../verification/provability-gaps.md).
