# Tier-2 `shared_c_kernel` → explicit copy migration

**Issue:** [#110](https://github.com/li-langverse/lic/issues/110) · **PH-7e**  
**Rubric:** [kokkos-memory-execution-spaces-rubric.md](kokkos-memory-execution-spaces-rubric.md)

## Problem

Tier-2 catalog rows labeled `shared_c_kernel` today delegate hot loops to a C oracle (`LI_EXTRA_C`, `*.c` under `benchmarks/tier2_physics/`). The C kernel may hold data in device-resident buffers while the Li harness treats results as host-visible — **silent copy semantics** that violate Li’s proof-first memory model.

Pure-Li migration must name every host↔device transition; checksum gates in `benchmarks/harness/bench.py` stay unchanged.

## Migration rubric (all tier-2 rows)

| Step | Action | Gate |
|------|--------|------|
| 1 | Inventory C symbols (`extern proc`) and who allocates buffers | Harness `verify.py` documents oracle owner |
| 2 | Classify current memory owner: host-only vs device-resident C | Row metadata `memory_owner: host\|device\|opaque` (benchmarks PR) |
| 3 | Stage **host-only** pure-Li with `@cpu` `@parallel(disjoint=…)` | Green checksum; `li_pure=True`; no `LI_EXTRA_C` |
| 4 | Introduce explicit `hostbuffer` / `devicebuffer` pair + `@sync_device` before offload | MIR shows sync count ≥ 1; no `mir_cross_space_read` |
| 5 | Drop C oracle; row track → `pure_li` | `threshold_ratio_cpp` unchanged; ratio honesty preserved |

**Do not** re-label a row green while still on shared C. **Do not** weaken `threshold_ratio_cpp`.

## Pilot row: `heat_equation_2d`

| Field | Current (shared C) | Target (pure-Li staged) |
|-------|-------------------|-------------------------|
| Harness path | `benchmarks/tier2_physics/heat_equation_2d/` | Same |
| Li entry | `extern proc li_heat_2d_kernel()` + `li_heat_2d_checksum()` | Pure `def heat_step(...)` on `hostbuffer[f64]` |
| Parallel path | `packages/li-parallel/.../main_parallel.li` (C kernel) | `@cpu` `@parallel(disjoint=disjoint_elem)` Jacobi stencil |
| Memory owner today | **Opaque** (C owns grid) | **Explicit Host** (stage 3) → **Host+Device pair** (stage 4) |
| Checksum | `li_heat_2d_checksum()` float oracle | Same numeric invariant; spec in `verify.py` |

### Staged checklist (issue #110)

- [x] **Stage 0 (this PR):** Migration plan + memory-space spec documented
- [ ] **Stage 1:** Host-only pure-Li Jacobi on `hostbuffer[f64]` — `@cpu` `@parallel`, no extern C
- [ ] **Stage 2:** Add `devicebuffer[f64]` mirror + `@sync_device` before `@gpu` stub kernel (telemetry only until #116)
- [ ] **Stage 3:** Remove `LI_EXTRA_C`; catalog `track=pure_li`; green tier-2 verify

**Blockers for stages 1–3:** #128 layout ABI freeze; #15 `@sync_*` MIR elaboration; post-approval parser for `hostbuffer` / `devicebuffer`.

## Secondary row: `md_lennard_jones`

| Field | Notes |
|-------|-------|
| Layout | SoA particle arrays — **blocked on #128** stride ABI |
| v1 path | Host-only `shared_c_kernel` → host-only pure-Li (same rubric steps 1–3) |
| Device path | Defer until `heat_equation_2d` stage 4 proves sync MIR |

Annotate in benchmarks registry: `migration_plan: tier2-shared-c-kernel-migration.md#md_lennard_jones` (benchmarks PR).

## Harness metadata (benchmarks handoff)

Recommend adding to each tier-2 `bench.toml`:

```toml
[memory]
owner = "opaque"   # host | device | opaque → migrate to host | host_device_explicit
execution_space = "openmp"  # serial | openmp | threads
migration_issue = "li-langverse/lic#110"
```

Filed via [benchmarks-kokkos-4.6-vendor-handoff.md](benchmarks-kokkos-4.6-vendor-handoff.md) checklist — **benchmarks** repo owns catalog edits.

## Exit criteria (implementation phase)

One tier-2 row with:

- Explicit `@sync_device` in committed `.li` source
- `li_pure=True` in catalog
- Green checksum in `bench.py --tier 2`
- MIR dump showing zero silent cross-space reads

Plan-phase exit (this PR): migration appendix + pilot checklist above merged on **lic**.
