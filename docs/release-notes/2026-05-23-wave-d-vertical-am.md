# Wave D — additive vertical `am_slicer` (2026-05-23)

## Summary

**wave-d-24-vertical-am:** `li-sim-additive` slicer workflow composable, `additive.toml` bench row, PH-AM RFC cross-links, and `verticals.toml` honesty.

## Changes

- `packages/li-sim-additive/` — scaffold via `li-new-package`; `import_name = "sim.additive"`; `workload_class=stub`
- `packages/li-sim-additive/src/lib.li` — `sim_additive` profile + slice→preview→export stage stub
- `li-tests/composable/import_sim_additive_slicer_workflow.li` — slicer workflow composable
- `benchmarks/competitive/additive.toml` — `am_slicer` composable bench row
- `benchmarks/competitive/verticals.toml` — `am_slicer` notes cross-link
- `scripts/check-additive-bench.sh` — gate (wired in `hpc_competitive_registry.sh`)
- `docs/game-dev/specs/li-sim-additive-rfc.md` — PH-AM cross-links
- `docs/ecosystem/vertical-algorithm-catalog.md` — am_slicer section

## Plan

Marks `wave-d-24-vertical-am` on compiler-studio plan loop.
