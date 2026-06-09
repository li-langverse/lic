# Tier-2 shared_c_kernel → explicit copy migration appendix

**Issue:** [#110](https://github.com/li-langverse/lic/issues/110)  
**Rubric:** [kokkos-memory-execution-spaces-rubric.md](kokkos-memory-execution-spaces-rubric.md)

## Problem

Tier-2 physics rows today use **`kernel_honesty = shared_c_kernel`**: Li drivers call `extern` C kernels (`li_heat_2d_kernel`, `li_md_lj_kernel`, …) that may own device-resident data opaquely. The harness checksum sink contract is satisfied, but Li cannot prove memory-space placement or copy semantics.

## Migration rubric (sub-phase D)

| Step | Action | Honesty label | Gate |
|------|--------|---------------|------|
| 0 | Current: `extern` C kernel + checksum | `shared_c_kernel` | harness verify + ratio |
| 1 | Pure-Li host oracle, `@cpu` `@parallel` | `pure_li` (host) | checksum parity vs step 0 |
| 2 | Add `hostbuffer`/`devicebuffer` pair + explicit `@sync_device` | `pure_li` (staged) | MIR sync tags (#15) |
| 3 | Drop `LI_EXTRA_C` / C core link | `pure_li` | green harness row, no C object |

**Rule:** No step may re-label a row green while still linking shared C without updating `kernel_honesty` in registry CSV.

## Pilot: `heat_equation_2d` (sub-phase E)

### Current state (lic)

| Artifact | Path | Mode |
|----------|------|------|
| Shared-C parallel driver | `packages/li-parallel/benchmarks/parallel-src/.../heat_equation_2d/li/main_parallel.li` | `extern li_heat_2d_*` |
| Pure-Li oracle | `packages/li-sim-scientific/src/lib.li` (`heat_oracle_stencil_step`, `sim_scientific_oracle_checksum_heat`) | host-only 8-point stencil |
| Registry smoke | `packages/li-sim-scientific/li-tests/smoke/run_algo_registry_tier2.li` | pure oracle dispatch |
| Backlog | `docs/ecosystem/sim-algorithm-backlog.md` → `sim-p0-heat-li-smoke` | **pending** |

### Staged path

1. **Step 1 (host-only pure-Li):** benchmarks repo `tier2_physics/heat_equation_2d/li/main.li` imports `sim.scientific` oracle OR inlines matching stencil; `@cpu @parallel(disjoint=disjoint_row)` on interior rows when parallelized; `li_rt_volatile_sink_f64(checksum)` unchanged.
2. **Step 2 (explicit copy semantics):** pair `hostbuffer[8, float]` with future `devicebuffer[8, float]`; call `view_copy_host8` (host v1) or `@sync_device` when #15 lands; document sync in source.
3. **Step 3 (drop C):** remove `LI_EXTRA_C` / `heat_core.c` from harness BenchSpec; set `li_pure=True`; update competitive CSV `kernel_honesty=pure_li`.

### Checksum contract

Oracle reference: `sim_scientific_oracle_checksum_heat()` — 200 steps, `r = alpha*dt/(dx*dx)`, sine initial condition. Migration **must** match this checksum within harness tolerance before dropping shared C.

## Secondary row: `md_lennard_jones`

Same rubric; blocked on #128 SoA/AoS layout ABI for force arrays. Host-only path first; device staging after #110 + #128 + #15.

## Benchmarks handoff

- [benchmarks#41](https://github.com/li-langverse/benchmarks/issues/41) — pure-Li variant expansion
- [benchmarks#27](https://github.com/li-langverse/benchmarks/issues/27) — Kokkos **4.6.x** vendor pin

Lic owns spec + migration plan; benchmarks repo owns harness driver swap and vendor policy PR.
