# Linear algebra surface

User code should express numerical kernels as **math**, not compiler intrinsics.

## Implemented (v1)

| Form | Types | Lowering |
|------|-------|----------|
| `a @ b` / `dot(a, b)` | `array[N, float]` × `array[N, float]` → `float` | `ArrayDotF64` (4-wide SIMD gather when `N ≥ 4`) |
| `C = A @ B` | `array[M, array[K, float]]` × `array[K, array[N, float]]` → `array[M, array[N, float]]` | `ArrayMatMul2DF64` |
| `sum(a)` | `array[N, int]` or `array[N, float]` | `ArraySumF64` / `ArraySumI64` |
| `a + b`, `a - b`, `a * b`, `a / b`, `a ** b` | matching 1d numeric arrays; see broadcast rules below | `ArrayBinOpF64` / `ArrayBinOpI64` |
| `scalar * a`, `a * scalar` | `float` × `array[N, float]` | element-wise scale |
| `sum(a * b)` | product array then reduce | element-wise + `ArraySumF64` |
| `norm(a)`, `axpy(α, x, y)` | prelude / `li-math` helpers | named reductions (no broadcast on `axpy`) |

Inner-dimension mismatches on `@` fail at compile time (`li-tests/math_linalg/matmul_dim_mismatch.li`, `array_dot_mismatch.li`). Non-matching 1d lengths fail unless the sole len-1 rule applies (`broadcast_numpy_reject_*.li`).

## Broadcast policy (explicit only)

Li rejects **NumPy-style broadcasting** (silent rank/length promotion). Wrong shapes are **compile-time errors**, not runtime `ValueError`.

| Allowed | Example | Notes |
|---------|---------|-------|
| Same length | `array[4] * array[4]` | Primary element-wise form |
| Scalar × array | `2.0 * a` | One scalar, not a repeated vector |
| Length-1 → N | `array[1] + array[4]` | Only promotion: index 0 of the shorter operand |
| Named ops | `dot`, `sum`, `norm`, `axpy` | `axpy` requires matching `x`/`y` lengths |

| Rejected | Example | Diagnostic |
|----------|---------|------------|
| NumPy len promotion | `array[2] * array[4]` | `matching lengths` / no NumPy-style broadcast |
| 2d/nd rank rules | (not implemented) | — |
| `@` shape mismatch | `A[M,K] @ B[K',N]` | inner dimension mismatch |

Prefer **explicit loops** when semantics are not a pure element-wise map: `for i in 0..<N: y[i] = alpha * x[i] + y[i]` with optional `@vectorized` / `@parallel`.

## Examples and benches

- Handbook: [Math-first HPC examples](../guide/math-hpc-examples.md)
- Tier 1 pure-Li: `benchmarks/tier1_micro/simd_dot/li/main.li`, `matmul_naive/li/main.li`
- Tests: `li-tests/math_linalg/` (including `broadcast_len1_*`, `broadcast_numpy_reject_*`)

## Tensor and quaternion path (not array broadcast)

| Concern | v1 (today) | Planned |
|---------|------------|---------|
| Dense linear algebra | `array[N, float]`, nested `array[M, array[K, float]]` for `@` | `tensor[(M,N), f64]` — shape in type ([language design](../superpowers/specs/2026-05-14-li-language-design.md) Phase 3) |
| 3-vectors / MD | `array[N, float]` or `li-math` `Vec3` | `tensor[(N,3), f64]` for SoA layouts |
| Quaternions | `packages/li-math` — `Quat`, `quat_mul`, `quat_identity` (object ops, not `@`) | `quat_dot`, `quat_rotate_vec3`, `quat_to_mat4` per [algorithms plan](../ecosystem/algorithms-and-libraries-plan.md) AL-11 |
| Scene transforms | wire `Transform3` to `math.Quat` | no `quaternion` package fork |

Quaternions stay in **`li-math`** named functions — not element-wise array operators. Tensors get compile-time shape checks like `@` today; no implicit NumPy broadcast at any rank.

## Planned

- Deeper `@vectorized` / `@parallel` on math loops (**7d** / **7e**)
- `tensor[(M,N), f64]` when Phase 3 lands

See [math/linalg spec](../superpowers/specs/2026-05-16-li-math-linalg-surface.md) and **G-math** in [provability-gaps](../verification/provability-gaps.md).
