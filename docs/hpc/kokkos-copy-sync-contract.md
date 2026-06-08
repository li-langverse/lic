# Copy / sync contract — memory spaces × decorators

**Issue:** [#110](https://github.com/li-langverse/lic/issues/110) · feeds [#15](https://github.com/li-langverse/lic/issues/15) decorator lowering  
**Status:** Spec-only (no MIR tags emitted until plan-approved codegen)

## Principle

Host↔device data movement is **always explicit** in source. Li rejects Kokkos `DualView` auto-sync semantics and any API that reads device memory from host code without a named sync point.

## Sync intrinsics (names frozen for elaboration)

| Intrinsic | Direction | Preconditions | Postcondition |
|-----------|-----------|---------------|---------------|
| `@sync_device(view)` | Host → Device | `view` is `hostbuffer[T]` or host-resident `View[T, Host]` | Device mirror contains host bytes; host writes since last sync are visible on device |
| `@sync_host(view)` | Device → Host | `view` is `devicebuffer[T]` or device-resident `View[T, Device]` | Host mirror contains device bytes; device writes since last sync are visible on host |

Both intrinsics are **compile-time elaborated** to MIR copy nodes with telemetry tags (`mir_sync_host`, `mir_sync_device`). They are not runtime decorators.

## Decorator stack → required sync

| Decorator stack | Memory in scope | Required sync before kernel read |
|-----------------|-----------------|----------------------------------|
| `@cpu` only | `hostbuffer[T]` | None |
| `@cpu` `@parallel(disjoint=…)` | `hostbuffer[T]` | None (host-only tier-2 v1 path) |
| `@gpu` + `@parallel` | `devicebuffer[T]` | `@sync_device` after host init / each host-side write |
| `@gpu` + post-kernel host reduce | `devicebuffer[T]` + host scalar | `@sync_host` before host read of reduction result |
| `@cpu` `@gpu` (invalid) | — | **Compile error** — pick one execution space per region |

## Cross-space access rules

| Action | Without prior sync | With `@sync_*` |
|--------|-------------------|----------------|
| Read `devicebuffer[T]` from `@cpu` code | **Compile error** (REQ-SYNC-02) | Allowed after `@sync_host` |
| Write `hostbuffer[T]` then read on `@gpu` | **Compile error** | Allowed after `@sync_device` |
| `parallel for` over `devicebuffer[T]` indices | Requires `@gpu` + proved `disjoint_*` on device view | Same as Kokkos `parallel_for` on `View` in device space |

## MIR telemetry (target)

Post-approval, `lic verify --mir-dump` must list:

- `mir_memory_space_tag` on each buffer allocation
- `mir_sync_host_count` / `mir_sync_device_count` per module
- `mir_cross_space_read` = **0** unless preceded by sync in same basic block (static check)

## Layout dependency ([#128](https://github.com/li-langverse/lic/issues/128))

Sync copies move **contiguous byte ranges** in v1. Strided / SoA layouts require frozen `ndview[Shape, T, Layout]` ABI before codegen — copy size = `sizeof(T) * product(Shape)` for contiguous layouts only.

## Provability

| Gap | Obligation |
|-----|------------|
| **G-gpu** | Cross-space read without sync → open VC; no trusted axiom in plan phase |
| **G-par** | Device `parallel for` still requires `disjoint_*` on device index space |
| **G-dec** | `@sync_*` elaborates before `@gpu` kernel outline (#15) |

See [provability-gaps.md](../verification/provability-gaps.md).
