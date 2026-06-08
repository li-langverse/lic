# Tier-2 memory + execution spaces spec (#110)

**PH-7e** · **G-par** · **G-gpu** · Issue [#110](https://github.com/li-langverse/lic/issues/110)

Defines Kokkos 4.6-aligned `MemorySpace`, `ExecutionSpace`, and View lifecycle contracts for tier-2 physics migration from `shared_c_kernel` to explicit copy semantics.

## Run

```bash
./li-tests/run_all.sh stdlib_seal
./scripts/check-hpc-competitive.sh
```

## Files

| Artifact | Path |
|----------|------|
| Spec enums | `docs/superpowers/specs/2026-06-08-li-tier2-memory-execution-spaces.md` |
| HPC rubric | `docs/hpc/kokkos-memory-execution-spaces-rubric.md` |
| Migration appendix | `docs/hpc/tier2-shared-c-migration-heat-equation-2d.md` |
| Plan | `docs/superpowers/plans/2026-06-07-kokkos-memory-execution-spaces-110.md` |
| Std stub | `std/memory/spaces.li` |
| Vendor handoff | `docs/ecosystem/benchmarks-kokkos-vendor-handoff.md` |
