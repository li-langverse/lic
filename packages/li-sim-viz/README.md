# li-sim-viz

**PH-SCI / PH-PUB** — `sim_scientific` Studio profile and scientific viz pipeline (source browser + Properties / Display / View) stubs.

**Status:** `workload_class=stub` — pipeline state + inspector section IDs only; not ParaView/VTK/MATLAB parity.

## Import

```li
import sim.viz
```

## Bench

- Registry: [viz.toml](../../benchmarks/competitive/viz.toml)
- Composable: `li-tests/composable/import_sim_viz_pipeline_source_display.li`
- Vertical: `scientific_viz` in [verticals.toml](../../benchmarks/competitive/verticals.toml)

## Build

```bash
lic build src/lib.li -o li-sim-viz
```

| Field | Value |
|-------|-------|
| Package | `PKG-li-sim-viz` |
| Program | [PH-SCI](../../docs/game-dev/PH-world-studio-program.md) |
| RFC | [li-sim-viz-rfc.md](../../docs/game-dev/specs/li-sim-viz-rfc.md) |
| Org repo | https://github.com/li-langverse/li-sim-viz |
