# Wave D — scientific viz vertical `scientific_viz` (2026-05-23)

## Summary

**wave-d-25-vertical-viz:** `li-sim-viz` pipeline source/display composable, `viz.toml` bench row, PH-SCI/PH-PUB RFC cross-links, and `verticals.toml` honesty.

## Changes

- `packages/li-sim-viz/` — scaffold via `li-new-package`; `import_name = "sim.viz"`; `workload_class=stub`
- `packages/li-sim-viz/src/lib.li` — `sim_scientific` profile + pipeline source/display/view stub (ParaView UX-04/06 panel model)
- `li-tests/composable/import_sim_viz_pipeline_source_display.li` — pipeline composable
- `benchmarks/competitive/viz.toml` — `scientific_viz` composable bench row
- `benchmarks/competitive/verticals.toml` — `scientific_viz` notes cross-link
- `scripts/check-viz-bench.sh` — gate (wired in `hpc_competitive_registry.sh`)
- `docs/game-dev/specs/li-sim-viz-rfc.md` — PH-SCI/PH-PUB cross-links
- `docs/ecosystem/vertical-algorithm-catalog.md` — scientific_viz section update

## Plan

Marks `wave-d-25-vertical-viz` on compiler-studio plan loop.
