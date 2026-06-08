# Kokkos memory + execution spaces — tier-2 policy slice (lic#110)

**Issue:** [#110](https://github.com/li-langverse/lic/issues/110)  
**north_star_fit:** HPC / tier-2 physics · **PH-7e**, **G-par**, **G-gpu**

## Added

- `std/execution/memory_spaces.li` — `MemorySpace` and `ExecutionSpace` int constants + `View` placeholder type
- `docs/hpc/kokkos-memory-execution-spaces-rubric.md` — Kokkos 4.6 → Li competitive rubric
- `docs/hpc/tier2-shared-c-migration-110.md` — `heat_equation_2d` staged migration from `shared_c_kernel`
- `docs/hpc/benchmarks-kokkos-vendor-handoff-27.md` — benchmarks#27 vendor pin checklist
- `docs/superpowers/plans/2026-06-07-kokkos-memory-execution-spaces-110.md` — approved plan
- Language design §Phase 3 — memory/execution space enums
- `li-tests/hpc/memory_spaces/memory_spaces_constants_ok.li`

## Deferred

- Pure-Li `heat_equation_2d` Stage 1 (host-only) — [#128](https://github.com/li-langverse/lic/issues/128) layout ABI
- `@sync_host` / `@sync_device` codegen — [#15](https://github.com/li-langverse/lic/issues/15)
- Kokkos 4.6.x vendor pin — **benchmarks** [#27](https://github.com/li-langverse/benchmarks/issues/27)
