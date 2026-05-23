# Wave D — chem vertical `qm_dft` (2026-05-23)

## Summary

**wave-d-21-vertical-chem:** `li-chem` DFT composable smoke, `qm_dft.toml` bench row, and `verticals.toml` honesty cross-links.

## Changes

- `packages/li-chem/` — scaffold via `li-new-package`; `import_name = "chem"`; `workload_class=stub`
- `packages/li-chem/src/lib.li` — H2 geometry + `dft_single_point_rks_stub` closed-form smoke
- `li-tests/composable/import_chem_dft_smoke.li` — RKS stub energy composable
- `benchmarks/competitive/qm_dft.toml` — `qm_dft` composable bench row
- `benchmarks/competitive/verticals.toml` — updated `qm_dft` notes
- `scripts/check-qm-dft-bench.sh` — gate (wired in `hpc_competitive_registry.sh`)
- `docs/ecosystem/vertical-algorithm-catalog.md` — qm_dft bench/composable citations

## Plan

Marks `wave-d-21-vertical-chem` on compiler-studio plan loop.
