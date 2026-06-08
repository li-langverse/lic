# Kokkos 4.6.x vendor policy — benchmarks handoff (#27)

**Owner repo:** [li-langverse/benchmarks](https://github.com/li-langverse/benchmarks) · **Tracking issue:** [#27](https://github.com/li-langverse/benchmarks/issues/27)  
**Lic registry:** `benchmarks/competitive/registry.toml` (`id = "kokkos"`) · **Issue:** [#110](https://github.com/li-langverse/lic/issues/110)

## Pin target

| Field | Value |
|-------|-------|
| Upstream | [Kokkos 4.6.02](https://github.com/kokkos/kokkos/releases/tag/4.6.02) |
| Env pin (CI/local) | `HPC_COMPETITIVE_KOKKOS_VERSION=4.6.02` |
| Review cadence | Quarterly + on Kokkos minor release |

## Benchmarks PR checklist (human review — do not self-merge)

- [ ] Vendor manifest / submodule pin `kokkos` ≥ **4.6.02**
- [ ] Document SYCL backend as production in vendor README (watch track only until Li device path)
- [ ] Note DualView deprecation — aligns with Li no-implicit-dual-view policy ([#110](../../../docs/hpc/kokkos-memory-execution-spaces-rubric.md))
- [ ] `compare` rows: `md_lennard_jones`, `heat_2d` / `heat_equation_2d` naming aligned with lic harness
- [ ] No `threshold_ratio_cpp` changes in vendor-only PR
- [ ] Update `last_reviewed` in benchmarks copy of competitive registry when pin lands

## Lic-side (this PR)

- `registry.toml` `kokkos` row: `last_reviewed = "2026-06-08"`, notes cite 4.6.02 + #110 rubric
- `scripts/hpc-competitive-snapshot.sh` already emits `HPC_COMPETITIVE_KOKKOS_VERSION` when set
