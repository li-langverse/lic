# Tier-2 migration: `heat_equation_2d` shared-C → explicit copy semantics

**Issue:** [lic#110](https://github.com/li-langverse/lic/issues/110)  
**Bench row:** `heat_equation_2d` (tier 2)  
**north_star_fit:** HPC / tier-2 physics · **PH-7e**, **G-par**

## Current state

| Aspect | Today |
|--------|-------|
| Native oracle | `common/heat_core.c` (shared C kernel) |
| Li driver | `benchmarks/tier2_physics/heat_equation_2d/li/main.li` calls `li_heat_2d_kernel()` extern |
| Catalog honesty | `kernel_honesty = shared_c_kernel` — C owns device/host data layout |
| Parallel entry | `packages/li-parallel/.../heat_equation_2d/li/main_parallel.li` (dual-mode) |
| Memory model | Implicit — no `MemorySpace` tag; copies hidden in C |

## Target state (post-#110 policy)

| Aspect | Target |
|--------|--------|
| Li kernel | Pure-Li heat stencil with `@cpu` `@parallel(disjoint=disjoint_elem)` |
| Buffers | Explicit `hostbuffer[f64]` (v1); optional `devicebuffer[f64]` pair in stage 2 |
| Sync | `@sync_device(grid)` before device step; `@sync_host(grid)` before checksum |
| Catalog | `kernel_honesty = li_pure` after checksum parity |
| `LI_EXTRA_C` | Removed after stage 3 |

## Staged migration checklist

### Stage 1 — Host-only pure-Li (no device)

- [ ] Implement 2D Jacobi stencil in Li on `hostbuffer` / `array` with proved `disjoint_elem` policy
- [ ] Keep `execution_space_openmp()` default; `@cpu` `@parallel` on interior rows
- [ ] Emit checksum via `li_rt_volatile_sink_f64` (harness contract unchanged)
- [ ] Verify: `python3 benchmarks/harness/bench.py --tier 2 --only heat_equation_2d --verify`
- [ ] Gate: checksum drift ≤ native oracle tolerance

### Stage 2 — Explicit host/device pair (spec surface)

- [ ] Allocate `hostbuffer[f64, N]` + `devicebuffer[f64, N]` with static `MemorySpace` tags
- [ ] Insert `@sync_device(host_grid)` before `@gpu` or device execution-space kernel (#116)
- [ ] Insert `@sync_host(device_grid)` before host checksum read
- [ ] **No** implicit DualView — host and device buffers are separate symbols
- [ ] MIR telemetry shows sync points (feeds #15)

### Stage 3 — Drop shared C

- [ ] Set `li_pure=True` in `bench.py` `BenchSpec` for `heat_equation_2d`
- [ ] Remove `LI_EXTRA_C` / `common/heat_core.c` link from Li build path
- [ ] Update `benchmarks/competitive/registry.toml` notes: `kernel_honesty` promotion
- [ ] Re-run tier-2 ratio gate — no threshold weakening

## Secondary row: `md_lennard_jones`

Same rubric applies after #128 (SoA/AoS layout ABI):

1. Host-only MD step with `memory_space_host()` buffers.
2. Explicit device staging for GPU offload experiments.
3. Drop `md_core.c` only when checksum + ratio gates pass.

## Blockers

| Blocker | Owner issue |
|---------|-------------|
| `View[T, Space, Layout]` parser + type tags | #128 (layout ABI) |
| `@sync_host` / `@sync_device` MIR lowering | #15 |
| Device kernel emission | #116 |
| Kokkos 4.6.x vendor pin in benchmarks catalog | [benchmarks#27](https://github.com/li-langverse/benchmarks/issues/27) |

## Proof obligations

- **G-par:** disjoint interior stencil indices — closed slice via `disjoint_elem` on row loops.
- **G-gpu:** cross-space read without sync — **open** until #15 lands; tracked in [provability-gaps.md](../verification/provability-gaps.md).
