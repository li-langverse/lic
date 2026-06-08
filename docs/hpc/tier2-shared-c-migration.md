# Tier-2 `shared_c_kernel` → explicit copy migration (#110)

**Status:** Migration appendix (plan sub-phases D + E)  
**Issue:** [#110](https://github.com/li-langverse/lic/issues/110)  
**Rubric:** [kokkos-memory-execution-spaces-rubric.md](kokkos-memory-execution-spaces-rubric.md)

Today, tier-2 competitive rows (`rust`, `julia`, `li` with `LI_EXTRA_C`) share a C oracle in `benchmarks/tier2_physics/*/common/*_core.c`. The harness labels this **`shared_c_kernel`**. Device-resident data and implicit copies are **hidden inside the C core** — Li cannot prove placement.

This appendix defines how each row migrates to pure-Li with **explicit** host↔device sync.

---

## Migration rubric (all tier-2 rows)

| Stage | Harness state | Copy semantics | Gate |
|-------|---------------|----------------|------|
| **0 — baseline** | `shared_c_kernel`; `LI_EXTRA_C` links C core | Implicit (C owns buffers) | Checksum parity vs cpp |
| **1 — host pure-Li** | `li/main.li` only; `@cpu` + `@parallel(disjoint=…)` | All data in `Host` space | Green checksum; `li_pure=True` candidate |
| **2 — explicit buffers** | `hostbuffer[T]` + `devicebuffer[T]` pair | `@sync_device` before device kernel; `@sync_host` before verify sink | MIR shows sync tags (#15) |
| **3 — drop shared C** | No `LI_EXTRA_C`; no `common/*_core.c` in Li path | Fully named in Li source | `threshold_ratio_cpp` unchanged; no silent copy in MIR dump |

**Do not:** re-label rows green or weaken `threshold_ratio_cpp` while still on stage 0–1 with shared C.

---

## Pilot: `heat_equation_2d`

Primary migration target (2D explicit heat stencil; smaller state than MD).

| Step | Work | Owner | Blocked by |
|------|------|-------|------------|
| **E.1** | Host-only pure-Li stencil with `@cpu` `@parallel(disjoint=disjoint_elem)` on grid | lic | — (can start now) |
| **E.2** | Add `hostbuffer[f64]` / `devicebuffer[f64]` pair; explicit `@sync_device` before offload stub | lic | #128 layout ABI for grid strides |
| **E.3** | Wire `@gpu` decorator + LKIR heat kernel (`packages/li-gpu/lkir/heat_2d.lkir`) | lic | #15 lowering, #116 offload |
| **E.4** | Remove `LI_EXTRA_C`; set `li_pure=True` in `bench.py`; verify checksum | lic + benchmarks | E.1–E.3 green |

**Current harness paths (when benchmarks submodule present):**

- `benchmarks/tier2_physics/heat_equation_2d/li/main.li`
- `benchmarks/tier2_physics/heat_equation_2d/common/heat_core.c`
- `benchmarks/tier2_physics/heat_equation_2d/cpp/main.c`

**Exit checklist (issue #110):**

- [x] Migration rubric documented (this file)
- [ ] E.1 host-only pure-Li green checksum
- [ ] E.2 explicit buffer pair + sync in source
- [ ] E.4 `li_pure=True` without `LI_EXTRA_C`

---

## Secondary: `md_lennard_jones`

| Step | Notes |
|------|-------|
| Host-only first | SoA layout from [#128](https://github.com/li-langverse/lic/issues/128) before device staging |
| Device path | Larger state; follow heat pilot after E.4 |
| Parallelism | `@parallel(disjoint=disjoint_elem)` on particle indices; execution space `OpenMP` default |

Paths: `benchmarks/tier2_physics/md_lennard_jones/`.

---

## Catalog honesty

| Field | Stage 0–1 | Stage 2+ |
|-------|-----------|----------|
| `li_status` | `shared_c_kernel` or `li_pure_host` | `li_pure` |
| `copy_semantics` | `implicit_c` | `explicit_sync` |
| Competitive ratio | Unchanged | Unchanged until proof + perf review |

Coordinate catalog updates with [benchmarks#41](https://github.com/li-langverse/benchmarks/issues/41).

---

## Related

- [Kokkos rubric](kokkos-memory-execution-spaces-rubric.md)
- [Benchmarks vendor handoff](benchmarks-kokkos-vendor-handoff.md)
- [Competitive landscape](../benchmarks/competitive-landscape.md)
