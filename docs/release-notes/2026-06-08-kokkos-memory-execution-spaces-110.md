# Release notes — Kokkos memory + execution spaces spec (#110)

**Date:** 2026-06-08  
**Issue:** [#110](https://github.com/li-langverse/lic/issues/110)  
**north_star_fit:** HPC tier-2 · **PH-7e**, **G-par**, **G-gpu**

## Summary

Plan-approved implementation of sub-phases **A–G**: normative Kokkos-class memory/execution-space rubric, language-design spec enums, tier-2 shared-C migration appendix, benchmarks vendor handoff checklist, and `std/execution/memory_spaces.li` spec constants.

## Added

| Path | Purpose |
|------|---------|
| `docs/superpowers/plans/2026-06-07-kokkos-memory-execution-spaces-110.md` | Approved plan |
| `docs/hpc/kokkos-memory-execution-spaces-rubric.md` | Policy matrix + copy/sync contract |
| `docs/hpc/tier2-shared-c-migration.md` | `shared_c_kernel` → explicit sync migration |
| `docs/hpc/benchmarks-kokkos-vendor-handoff.md` | Checklist for benchmarks#27 |
| `std/execution/memory_spaces.li` | `MemorySpace` + `ExecutionSpace` constants |
| `li-tests/hpc/memory_spaces_spec_smoke.li` | Compile/link smoke |

## Updated

- `docs/superpowers/specs/2026-05-14-li-language-design.md` — Phase 3 memory/execution spaces
- `docs/verification/provability-gaps.md` — G-gpu cross-space sync obligation (#110)
- `docs/language/stdlib.md` — `std.execution.memory_spaces` import

## Not in this slice

- Parser / MIR lowering for `@sync_host` / `@sync_device` → [#15](https://github.com/li-langverse/lic/issues/15)
- `hostbuffer` / `devicebuffer` codegen → [#116](https://github.com/li-langverse/lic/issues/116)
- Benchmarks Kokkos 4.6.x pin → [benchmarks#27](https://github.com/li-langverse/benchmarks/issues/27)

## Tests

```bash
./li-tests/run_all.sh hpc
# or: lic build li-tests/hpc/memory_spaces_spec_smoke.li -o /tmp/hpc-ms-smoke && /tmp/hpc-ms-smoke
```
