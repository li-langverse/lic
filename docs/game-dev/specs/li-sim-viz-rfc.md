# RFC: Scientific visualization pipeline (PH-SCI / PH-PUB)

**Status:** Draft stub (`workload_class=stub`)  
**Date:** 2026-05  
**Vision:** [world-studio-vision.md](../world-studio-vision.md)  
**Program:** [PH-world-studio-program.md](../PH-world-studio-program.md) — **PH-SCI**, **PH-PUB**  
**Related:** [sim-viz-scientific-rfc.md](sim-viz-scientific-rfc.md) (MD/heat/orbital numerics)

## Problem

Scientific simulation in World Studio needs a **`sim_scientific`** viewport pipeline surface (source browser + Properties / Display / View inspector) without claiming ParaView / VTK / MATLAB parity.

## Proposal

| Layer | Deliverable | Status |
|-------|-------------|--------|
| Package | `sim.viz` (`li-sim-viz`) | **landed** — pipeline source/display/view state stub |
| Bench | `scientific_viz` in [viz.toml](../../../benchmarks/competitive/viz.toml) | **stub** — composable_only |
| Composable | `import_sim_viz_pipeline_source_display.li` | **landed** |
| Registry | `verticals.toml` id=`scientific_viz` | **landed** |
| Inspector chrome | `ui` / `gui` section IDs (UX-04) | **landed** — shared 0/1/2 mapping |
| Field color maps | tier-2 MD/heat benches | shared numerics (not viz oracle) |
| VTK render path | in-viewport scalar coloring | **open** |

### PH-PUB phases (tracker)

| Phase | ID | This slice |
|-------|-----|------------|
| 0 | PUB-0 | `sim_scientific` profile + composable smoke (`viz_pipeline_init`) |
| 1 | PUB-1 | Pipeline browser — add/select source | **stub** — ID counter only |
| 2 | PUB-2 | Display rep (surface/wireframe/points) | **stub** — rep ID only |
| 3 | PUB-3 | Properties/Display deferred Apply vs View instant | **stub** — `pending_apply` flag |
| — | — | Linked split views / camera sync | **open** (Wave E) |

## Li syntax

```li
import sim.viz

var s: VizPipelineState = viz_pipeline_init()
var s1: VizPipelineState = viz_pipeline_add_source(s, viz_source_kind_sphere())
var s2: VizPipelineState = viz_pipeline_set_inspector_section(s1, viz_inspector_section_display())
```

Exported APIs use `requires` / `ensures` / `decreases` on `packages/li-sim-viz/src/lib.li`.

## UX patterns (ParaView competitive intel)

- **Pipeline browser:** active source highlighting (`active_source_id`)
- **Properties / Display / View:** section IDs aligned with `ui_inspector_section_*` / `gui_inspector_section_*`
- **Apply modes:** deferred for Properties/Display; instant for View ([UX-04](../competitive-intel/ui-ux-by-dimension.md#ux-04--properties--inspector), [UX-06](../competitive-intel/ui-ux-by-dimension.md#ux-06--scientific-visualization))
- **Offline reference:** `competitive-intel/downloads/paraview-properties-panel.html`

## Proof / trust

- **Proved:** pipeline init invariants, source count monotonicity, section/rep assignment, apply clears pending flag.
- **Trusted:** none in this slice.
- **Stub:** VTK mesh readers, scalar color maps, slice widgets, linked camera sync — not implemented.

## Honesty

Cite [verticals.toml](../../../benchmarks/competitive/verticals.toml) `scientific_viz` with `workload_class=stub`. No ParaView/VTK/MATLAB performance or feature parity claims in CI or docs.

## Open questions

- [ ] Field → color map lookup table FFI
- [ ] Split-view camera sync (ParaView `SplitView`)
- [ ] Tier-2 field overlay oracle column
