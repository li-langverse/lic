# Tier-2 migration: shared_c_kernel → explicit copy semantics

**Issue:** [#110](https://github.com/li-langverse/lic/issues/110)  
**Pilot row:** `heat_equation_2d`  
**Secondary row:** `md_lennard_jones` (host-only path first; SoA layout in #128)  
**Rubric:** [kokkos-memory-execution-spaces-rubric.md](kokkos-memory-execution-spaces-rubric.md)

## Problem

Today Rust/Julia tier-2 drivers link the **same C core** as C++ (`kernel_honesty = shared_c_kernel`). The C oracle owns allocation and any implicit device staging. Pure-Li kernels must instead **name** memory space and sync points so `lic build` can prove no silent host↔device copies (Kokkos 4.6 DualView deprecation alignment).

## Current state (`heat_equation_2d`)

| Artifact | Location | Honesty |
|----------|----------|---------|
| Shared C core | `benchmarks/tier2_physics/heat_equation_2d/common/heat_core.c` | Reference stencil (128×128 Jacobi) |
| Li driver (shared) | `…/li/main.li` via `extern proc li_heat_2d_kernel()` | `shared_c_kernel` |
| Li dual-mode | `packages/li-parallel/benchmarks/…/heat_equation_2d/li/main_parallel.li` | `LI_PARALLEL=1` pool override |
| Pure-Li smoke | `packages/li-sim-scientific` 1D stub | Registry smoke only; not full 2D harness |

Harness contract: `li_heat_2d_kernel()` + `li_heat_2d_checksum()` → `li_rt_volatile_sink_f64(checksum)`.

## Staged migration (plan sub-phase E)

### Stage 1 — Host-only pure-Li (no device buffers)

**Goal:** Replace `extern` C calls with proved host `parallel for` stencil.

| Step | Action | Gate |
|------|--------|------|
| 1a | Implement 256×256 (or 128×128) `array[N, array[N, float]]` Jacobi step | `disjoint_row` proof on outer loop |
| 1b | `@cpu @parallel(disjoint=disjoint_row) @vectorized(lanes=4)` on `heat_step` | MIR telemetry (#15) |
| 1c | Emit checksum via `li_rt_volatile_sink_f64` | Harness `verify.py` green |
| 1d | Registry label `pure_li`; drop `LI_EXTRA_C` for Li column | `check-hpc-competitive.sh` |

**Memory model:** `MemorySpace.Host`, `ExecutionSpace.OpenMP`. No sync intrinsics required.

### Stage 2 — Explicit host/device pair (spec conformance)

**Goal:** Demonstrate Kokkos-class `deep_copy` semantics before GPU codegen (#116).

| Step | Action | Gate |
|------|--------|------|
| 2a | Allocate `hostbuffer[grid]` + `devicebuffer[grid]` pair | Types from #128 layout ABI |
| 2b | `@sync_device(grid_dev)` before `@gpu heat_step_device` | MIR `sync_device` tag |
| 2c | `@sync_host(grid_host)` before host checksum | MIR `sync_host` tag |
| 2d | `compile_fail` test: device read without prior sync | `li-tests/hpc/memory_spaces/` |

**Blocked until:** #128 stride/layout names frozen; #15 decorator lowering.

### Stage 3 — Drop shared C oracle

| Step | Action | Gate |
|------|--------|------|
| 3a | Remove `heat_core.c` from Li driver link line | Bench ratio ≤ policy threshold |
| 3b | Update `benchmarks/competitive/registry.toml` Li `compare` to include `heat_2d` | Human review |
| 3c | Close `sim-p0-heat-li-smoke` backlog row | `sim-plan-gates.sh` |

## `md_lennard_jones` (secondary)

| Stage | Focus | Notes |
|-------|-------|-------|
| 1 | Host-only pure-Li MD step | SoA layout per #128 before device buffers |
| 2 | Ghost/halo exchange stays in `li-parallel` | No Kokkos Views for halos in v1 |
| 3 | Device resident positions/forces | Explicit `@sync_*` around force kernel |

Do not re-label `md_lennard_jones` green while Li column still uses `LI_EXTRA_C`.

## Copy semantics rubric (all tier-2 rows)

| Transition | Required documentation | Proof |
|------------|------------------------|-------|
| `shared_c_kernel` → `pure_li` host | Migration stage 1 complete | `disjoint_*` + checksum |
| Host → device staging | `@sync_device` named in source | G-gpu open obligation |
| Device → host readback | `@sync_host` before checksum | G-gpu open obligation |
| Implicit DualView | **Forbidden** | Compile error (future) |

## Agent checklist (#110 close criteria)

- [x] Migration appendix for `heat_equation_2d` + `md_lennard_jones`
- [x] Memory/execution space spec enums merged
- [x] Kokkos 4.6.x vendor handoff filed for benchmarks
- [ ] Stage 1 pure-Li `heat_equation_2d` in benchmarks repo (#41)
- [ ] Stage 2+ after #128 / #15 / #116
