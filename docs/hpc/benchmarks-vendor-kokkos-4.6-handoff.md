# Benchmarks vendor handoff — Kokkos 4.6.x pin

**Status:** Handoff checklist (lic#110 sub-phase F)  
**Owner repo:** [li-langverse/benchmarks](https://github.com/li-langverse/benchmarks)  
**Tracking issue:** [#27](https://github.com/li-langverse/benchmarks/issues/27)

lic defines the Li memory/execution-space policy; **benchmarks** owns vendor pins and competitive driver builds. This checklist is filed from lic#110 for the benchmarks maintainer — **no threshold changes in lic**.

## Checklist for benchmarks PR

- [ ] Pin Kokkos **4.6.02** (or latest 4.6.x patch) in vendor policy doc / `third_party/kokkos` submodule pointer
- [ ] Record pin in `docs/ecosystem/vendor-policy.md` (or equivalent) with review date
- [ ] Add `HPC_COMPETITIVE_KOKKOS_VERSION=4.6.02` to competitive snapshot docs (mirrors `scripts/hpc-competitive-snapshot.sh` env pin on lic)
- [ ] Update `hpc_libraries.toml` / explorer digest: `kokkos` status `watch` → `pinned` (not `missing`)
- [ ] Optional: Kokkos `OpenMP` driver for `heat_2d` / `md_lennard_jones` compare columns (watch track only — no ratio gate until Li device story)
- [ ] Cross-link [lic kokkos rubric](https://github.com/li-langverse/lic/blob/main/docs/hpc/kokkos-memory-execution-spaces-rubric.md)
- [ ] Human review — **do not** self-merge vendor bumps

## lic-side updates (this PR)

| File | Change |
|------|--------|
| `benchmarks/competitive/registry.toml` | `kokkos` notes → 4.6.x SYCL/OpenMP; `last_reviewed` bumped |
| `scripts/hpc-competitive-snapshot.sh` | Already supports `HPC_COMPETITIVE_KOKKOS_VERSION` env pin |

## Exit gate

- benchmarks#27 closed or commented with PR URL when vendor pin merges
- lic competitive registry `kokkos` row notes reference 4.6.02 release

## References

- [Kokkos 4.6.02 release](https://github.com/kokkos/kokkos/releases/tag/4.6.02)
- [2026-05-20 explorer digest](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/explorer-digests/2026-05-20-explorer.md)
- [lic#110 plan](../superpowers/plans/2026-06-07-kokkos-memory-execution-spaces-110.md)
