# Lean `P-gpu-*` corpus note (WP-GPU-05)

**Status:** Not started — tracker **partial**, not **done**  
**Package:** G-gpu (provability) — disjoint device/host laws

## Planned corpus (RFC)

| Lemma id | Statement sketch |
|----------|------------------|
| `P-gpu-host-device-disjoint` | No `host[T]` pointer aliases `device[T]` storage |
| `P-gpu-kernel-launch-framing` | `@gpu def` lowers to host stub + device symbol (LKIR) |
| `P-gpu-emit-honesty` | Bench rows without `gpu_timing_ns` do not imply device execution |

## Current gates (no Lean yet)

- `gpu_device_type_reserved_compile_fail.li` — `@gpu proc` → `def` required
- `gpu_decorator_type_alias_compile_fail.li` — `@gpu` on type alias rejected
- `gpu_decorator_mir.li` — `mir_gpu_proc` telemetry at verify

**Honesty:** WP-GPU-05 stays **partial** until `lake build` includes at least one discharged `P-gpu-*` goal.
