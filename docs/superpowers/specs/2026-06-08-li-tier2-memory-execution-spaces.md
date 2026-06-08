# Tier-2 memory and execution spaces (spec)

**Status:** Spec-only (WP0-B compile stub); parser/codegen deferred to [#15](https://github.com/li-langverse/lic/issues/15) / [#116](https://github.com/li-langverse/lic/issues/116)  
**Issue:** [#110](https://github.com/li-langverse/lic/issues/110)  
**Plan:** [2026-06-07-kokkos-memory-execution-spaces-110.md](../plans/2026-06-07-kokkos-memory-execution-spaces-110.md)  
**Gaps:** [Provability gaps](../../verification/provability-gaps.md) **G-gpu**, **G-hetero**, **G-par**, **G-dec**  
**north_star_fit:** HPC tier-2 physics · **PH-7e**, **PH-7d**, **G-par**

## Goal

Define minimal **memory-space** and **execution-space** enums and a **View** lifecycle contract so tier-2 physics kernels can migrate from `shared_c_kernel` rows to pure-Li without silent host↔device copies. Aligns with Kokkos 4.6 semantics (explicit `deep_copy`, DualView deprecation).

## MemorySpace (REQ-MS-01)

Static placement tag on buffer and view types. No runtime space discovery in v1.

| Variant | Kokkos analog | Li buffer type (Phase 3) | Notes |
|---------|---------------|--------------------------|-------|
| `Host` | `HostSpace` | `hostbuffer[T]`, host-resident `array`/`grid` | Default for tier-2 pilot |
| `Device` | `CudaSpace` / `HIPSpace` / `SYCLSpace` | `devicebuffer[T]` | Requires explicit `@sync_device` before host read |
| `Unified` | `HBWSpace` / managed memory | Documented alias; codegen deferred | High-bandwidth host; not implicit dual view |

```text
type MemorySpace = Host | Device | Unified
```

Compile-only stub: `import std.memory.spaces` exports tag constants (`memory_space_host`, …).

## ExecutionSpace (REQ-ES-01)

Selects which runtime backend executes a kernel. Decorator stack + `[execution]` in `li.toml` map to this enum.

| Variant | Kokkos analog | v1 status | Notes |
|---------|---------------|-----------|-------|
| `Serial` | `Serial` | Supported | Single-thread reference |
| `OpenMP` | `OpenMP` | **Default** for tier-2 | Matches `parallel for` + li-parallel pool |
| `Threads` | `Threads` | Opt-in | Documented hazard: conflicts with linked libomp ([Trilinos #1391](https://github.com/trilinos/Trilinos/issues/1391)) |
| `SYCL` | `SYCL` | Reserved (#116) | Kokkos 4.6 production SYCL backend |
| `Cuda` | `Cuda` | Reserved (#116) | |
| `HIP` | `HIP` | Reserved (#116) | |

```text
type ExecutionSpace = Serial | OpenMP | Threads | SYCL | Cuda | HIP
```

**Policy:** tier-2 harness rows default `ExecutionSpace.OpenMP` unless `@cpu` + `Serial` is explicitly requested for debugging.

## View lifecycle (REQ-MS-02)

Kokkos `View` maps to a typed buffer with static space tag:

```text
View[T, Space, Layout]   # Layout from #128 (RowMajor, ColumnMajor, Strided)
```

| Stage | Rule | Proof obligation |
|-------|------|------------------|
| Allocate | `View` constructed in one `MemorySpace` | Space tag in type |
| Read/write | Access only in matching space | **G-gpu:** compile error on cross-space read without prior sync |
| Destroy | Deallocate in same space as allocation | No orphan device allocations |
| Host mirror | Explicit `hostbuffer[T]` paired with `devicebuffer[T]` | **No DualView** — Kokkos 4.6 deprecation alignment |

Borrowed slices use `tensorview[Shape, T]` / `ndview[Shape, T]` with the **same** space tag as the parent View.

## Copy / sync contract (REQ-SYNC-01)

| Operation | Decorator / intrinsic | When required |
|-----------|----------------------|---------------|
| Host → device | `@sync_device(view)` | Before `@gpu` kernel reads host-written data |
| Device → host | `@sync_host(view)` | Before host reads device-written results |
| Same-space | None | Host-only `parallel for` on `array` / `grid` |

Decorator stack example (spec-only; elaboration in #15):

```text
@cpu @parallel(disjoint=disjoint_row) @vectorized(lanes=4)
def heat_step_host(grid: var array[N, array[N, float]]) -> unit
```

Device staging path (post-#128):

```text
@sync_device(grid_dev)
@gpu
def heat_step_device(grid_dev: var devicebuffer[grid[N, N, float]]) -> unit
```

**REQ-SYNC-02:** cross-space read without a documented sync chain is a **compile error** once parser work lands (`li-tests/hpc/memory_spaces/`).

## Relationship to existing surfaces

| Surface | Role |
|---------|------|
| `parallel for` + `disjoint_*` | Host shared-memory parallelism (**G-par** closed slice) |
| `@cpu` / `@gpu` decorators | Execution-space placement tags (**G-dec** partial) |
| `hostbuffer[T]` / `devicebuffer[T]` | Phase 3 types in [language design](2026-05-14-li-language-design.md) |
| `packages/li-parallel` | OpenMP pool; maps to `ExecutionSpace.OpenMP` |
| `packages/lig` | Device probe; maps to `ExecutionSpace.SYCL`/`Cuda` when #116 lands |

## Non-goals (this spec)

- Parser/typechecker for `View[T, Space, Layout]` (blocked on #128 layout ABI).
- LKIR / vendor codegen for device buffers (#116).
- Graph API / composite loop capture (Kokkos 4.6 #7513 — defer to #15).
- `trusted.lean` axioms for device memory (human-approved issue only).

## Exit gate (spec slice)

- [x] `MemorySpace` + `ExecutionSpace` enums documented
- [x] View lifecycle + explicit sync contract documented
- [x] `std/memory/spaces.li` compile-only stub + stdlib seal smoke
- [ ] Parser rejects cross-space access without sync (implementation phase)
- [ ] One tier-2 row (`heat_equation_2d`) with explicit staging in source
