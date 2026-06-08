# Kokkos memory + execution spaces spec (lic#110)

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**Issue:** [#110](https://github.com/li-langverse/lic/issues/110)  
**PH / REQ:** PH-7e, PH-7d, G-par, G-gpu · REQ-MS-01/02, REQ-ES-01/02, REQ-SYNC-01/02  
**north_star_fit:** HPC tier-2 physics — proof-before-perf; no silent host↔device copies

---

## Summary

Defines a minimal Li `MemorySpace` / `ExecutionSpace` / `View[T, Space, Layout]` policy aligned with Kokkos 4.6 (DualView deprecation, explicit `deep_copy`, OpenMP default) plus tier-2 `shared_c_kernel` migration staging for `heat_equation_2d`.

## Agent deliverable

- [x] Branch pushed and PR opened (not draft)
- [x] Policy rubric: `docs/hpc/kokkos-memory-execution-spaces-rubric.md`
- [x] Execution-space policy: `docs/hpc/kokkos-execution-space-rubric.md`
- [x] Migration appendix + `heat_equation_2d` pilot plan: `docs/hpc/shared-c-kernel-migration-appendix.md`
- [x] Spec enums: language design §Phase 3 + `std/execution/memory_spaces.li`
- [x] Benchmarks vendor handoff checklist: `docs/hpc/benchmarks-vendor-kokkos-4.6-handoff.md` (#27)
- [x] G-par / G-gpu provability-gaps cross-space sync obligations
- [ ] merge-approved (human adds after review)

## Changed

| Area | What |
|------|------|
| Plan | `docs/superpowers/plans/2026-06-07-kokkos-memory-execution-spaces-110.md` |
| HPC rubric | Policy matrix + copy/sync contract |
| Language spec | Phase 3 `MemorySpace`, `ExecutionSpace`, `View[T, Space, Layout]` |
| std | `std/execution/memory_spaces.li` spec enums |
| Migration | `heat_equation_2d` S1→S2→S3 staging |
| Benchmarks handoff | Kokkos 4.6.02 vendor pin checklist for benchmarks#27 |
| Registry | `kokkos` row notes → 4.6.x |

## Not changed

- Parser / codegen / LKIR lowering (#15, #116)
- Tier-2 threshold ratios or harness checksums
- `trusted.lean`
- benchmarks vendor submodule (handoff only)

## Tests

```bash
./scripts/check-hpc-competitive.sh   # exit 0
```

## Downstream

| Repo | Action |
|------|--------|
| benchmarks | Execute vendor handoff checklist (#27) |
| lic | #15 sync MIR tags; #128 layout ABI; then S1 `heat_equation_2d` implementation |

## CHANGELOG entry

```markdown
### Added
- **PH-7e / lic#110:** Kokkos-aligned `MemorySpace` / `ExecutionSpace` / `View` policy, tier-2 migration appendix, benchmarks Kokkos 4.6.x handoff — [2026-06-08-kokkos-memory-execution-spaces-110.md](docs/release-notes/2026-06-08-kokkos-memory-execution-spaces-110.md).
```
