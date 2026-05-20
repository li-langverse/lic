# Scalar precision (fixed-width types)

Li exposes **explicit** integer and float widths for HPC, quantization, and per-domain accuracy choices. The compiler does **not** pick a global accuracy for the ecosystem.

## Float widths

| Type | Bits | Role |
|------|------|------|
| `float4` / `Float4` | 4 | Logical quantized lane (layout for kernels — Phase quant) |
| `float8` / `Float8` | 8 | Logical FP8 / quantized (e.g. E4M3/E5M2 — policy in package) |
| `float16` / `f16` | 16 | IEEE half |
| `float32` / `f32` | 32 | IEEE single |
| `float64` / `f64` / `float` | 64 | IEEE double (default `float`) |
| `float128` / `f128` | 128 | Extended (software / target-dependent codegen) |
| `float256` | 256 | High-precision research (logical; codegen may widen) |
| `float512` | 512 | Same |

Aliases: `f4`, `f8`, `Float32`, etc. — see `compiler/types/numeric_types.cpp`.

## Integer widths

| Signed | Unsigned |
|--------|----------|
| `int4` … `int512` | `uint4` … `uint512` |
| `int` → 64-bit | `uint` → 64-bit |

Also: `i8`/`u8`, `Int32`, `UInt64`, …

## Rules (strict, local)

| Rule | Behavior |
|------|----------|
| Width mix | `int32 + int64` → **error** unless explicit cast |
| Sign mix | `int32 + uint32` → **error** unless cast |
| `int` + `float` | **error** (unchanged) |
| Literals | `3.14` / `42` default to **64-bit**; narrow with typed variables + cast (suffixes: roadmap) |

No silent widening between widths.

## Who chooses accuracy?

| Layer | Mechanism |
|-------|-----------|
| **Source** | Annotate fields and locals: `var q: float16`, `def f(x: float32) -> float32` |
| **`li.toml`** | Optional `[numerics] default_float = "float32"` — documents project **preference** only; not enforced on deps |
| **Physics** | `ScalarPrecision` + `PhysicsProfile.float_bits` / `int_bits` in `physics.core` — simulation metadata, not a compiler global |
| **Packages** | Generic APIs `def step[T](...)` (future) or duplicate thin wrappers per width |

The org **does not** enforce one float width in CI. Packages ship defaults; callers override.

## Codegen (current)

| Width | LLVM (typical) |
|-------|----------------|
| 32 | `float` |
| 64 | `double` |
| 16 | `half` when target supports |
| 4 / 8 / 128+ | Type-checked; lowering may use `double` until quantization MIR is wired |

See [Provability gaps](../verification/provability-gaps.md) for proof/discharge maturity per width.

## Related

- [Types and data](types-and-data.md)
- [Numerics](numerics.md)
- [Strict by default](../ecosystem/strict-by-default.md) — no hidden global downgrade of numeric policy
