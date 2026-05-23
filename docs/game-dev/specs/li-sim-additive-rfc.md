# RFC: Additive manufacturing + export to printer (PH-AM)

**Status:** Draft stub (`workload_class=stub`)  
**Date:** 2026-05  
**Vision:** [world-studio-vision.md](../world-studio-vision.md)  
**Program:** [PH-world-studio-program.md](../PH-world-studio-program.md) — **PH-AM**

## Problem

Additive manufacturing simulation and export needs a **`sim_additive`** Studio profile and slicer workflow surface (slice → preview → export) without claiming PrusaSlicer / Cura / Bambu Studio parity.

## Proposal

| Layer | Deliverable | Status |
|-------|-------------|--------|
| Package | `sim.additive` (`li-sim-additive`) | **landed** — slicer stage state + export click counter |
| Bench | `am_slicer` in [additive.toml](../../../benchmarks/competitive/additive.toml) | **stub** — composable_only |
| Composable | `import_sim_additive_slicer_workflow.li` | **landed** |
| Registry | `verticals.toml` id=`am_slicer` | **landed** |
| Thermal | `pde_heat_2d` tier-2 | shared numerics (not slicer oracle) |
| Export | G-code/3MF via `studio.publish` | **open** |

### PH-AM phases (tracker)

| Phase | ID | This slice |
|-------|-----|------------|
| 0 | AM-0 | `sim_additive` profile + composable smoke (`am_stage_slice`) |
| 1 | AM-1 | Slice → preview advance (`slicer_workflow_advance`) |
| 2 | AM-2 | Preview → export | **stub** — click counter only |
| 3 | AM-3 | Export handoff (≤3 clicks PH-UX) | **stub** — `export_clicks` smoke |
| — | — | Trusted slicer/oracle FFI | **open** (Wave E) |

## Li syntax

```li
import sim.additive

var s: SlicerWorkflowState = slicer_workflow_init(12)
var s1: SlicerWorkflowState = slicer_workflow_advance(s, am_event_complete_stage())
```

Exported APIs use `requires` / `ensures` / `decreases` on `packages/li-sim-additive/src/lib.li`.

## Simulate and manufacture (future)

1. Mesh + voxel occupancy (`li-voxel` mode `am_occupancy`)  
2. Thermal/warp (`heat_equation`, proved tolerance)  
3. **`sim.export.print`** → STL, 3MF, G-code  
4. Optional send: OctoPrint / PrusaLink / Bambu (trusted FFI)

**Export wizard (PH-UX):** Review → Pre-flight → Export/Print (≤3 clicks).

## Domains

`fdm` | `sla` | `sls` | `ded` | `metal_am`

## Proof / trust

- **Proved:** workflow init invariants, stage advance order, export click monotonicity.
- **Trusted:** none in this slice.
- **Stub:** mesh slice kernels, toolpath/infill, G-code generation — not implemented.

## Honesty

Cite [verticals.toml](../../../benchmarks/competitive/verticals.toml) `am_slicer` with `workload_class=stub`. No PrusaSlicer/Cura/Bambu performance claims in CI or docs.

## Open questions

- [ ] Cura-class toolpath engine FFI
- [ ] G-code/3MF export oracle column
- [ ] OctoPrint / PrusaLink trusted send boundary
