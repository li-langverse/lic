# Kokkos memory + execution spaces (#110)

**Issue:** [#110](https://github.com/li-langverse/lic/issues/110) · **PH-7e**, **G-par**, **G-gpu**

## Summary

Minimal Li memory model aligned with Kokkos 4.6: `MemorySpace` / `ExecutionSpace` enums, explicit copy/sync contract (no DualView), tier-2 `shared_c_kernel` migration rubric for `heat_equation_2d`, Kokkos **4.6.02** vendor pin in competitive registry.

## Artifacts

| Path | Role |
|------|------|
| `std/hpc/memory.li` | `MemorySpace`, `ExecutionSpace` enums |
| `docs/hpc/kokkos-memory-execution-spaces-rubric.md` | Policy matrix |
| `docs/hpc/copy-sync-contract-110.md` | `@sync_host` / `@sync_device` contract |
| `docs/hpc/tier2-shared-c-kernel-migration-110.md` | Pilot migration plan |
| `benchmarks/competitive/registry.toml` | Kokkos 4.6.02 pin + review date |
| `benchmarks/competitive/kokkos-vendor-policy-benchmarks-27.md` | Handoff to benchmarks #27 |

## Tests

```bash
./li-tests/run_all.sh hpc stdlib_coverage
./scripts/check-hpc-competitive.sh
```
