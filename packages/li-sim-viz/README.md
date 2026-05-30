# li-sim-viz

**PH-SCI / PH-PUB** — `sim_scientific` Studio profile and scientific viz pipeline (source browser + Properties / Display / View) stubs.

**Status:** `workload_class=stub` — pipeline state + inspector section IDs only; **not** ParaView/VTK/MATLAB parity. No wgpu field draw; viewport labels are compose-time gates only until `li-render` trusted drivers land.

## Import

```li
import sim.viz
```

## What is real vs stub

| Surface | Status |
|---------|--------|
| `viz_pipeline_*` state machine | **Stub** — source count, display rep, inspector section, deferred Apply |
| Properties / Display / View panel IDs | **Stub** — aligned with `gui`/`ui` inspector sections |
| Studio viewport tier labels | **Stub** — `studio_sim_scientific_viz_viewport_ok` checks tier + pipeline init |
| Field color maps / volume render | **Not implemented** — blocked on wgpu trusted draw path |
| Tier-2 MD/heat checksum benches | **Separate** — `sim.scientific` oracles, not this package |

## Bench

- Registry: [viz.toml](../../benchmarks/competitive/viz.toml)
- Composable: `li-tests/composable/import_sim_viz_pipeline_source_display.li`
- Vertical: `scientific_viz` in [verticals.toml](../../benchmarks/competitive/verticals.toml)

## Build

```bash
lic check packages/li-sim-viz/li-tests/smoke/builds.li
```

| Field | Value |
|-------|-------|
| Package | `PKG-li-sim-viz` |
| Program | [PH-SCI](../../docs/game-dev/PH-world-studio-program.md) |
| Org repo | https://github.com/li-langverse/li-sim-viz |
