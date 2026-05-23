# li-sim-additive

**PH-AM** — `sim_additive` Studio profile and slicer workflow (slice → preview → export) stubs.

**Status:** `workload_class=stub` — stage chrome + export click counter only; not PrusaSlicer/Cura/Bambu parity.

## Import

```li
import sim.additive
```

## Bench

- Registry: [additive.toml](../../benchmarks/competitive/additive.toml)
- Composable: `li-tests/composable/import_sim_additive_slicer_workflow.li`
- Vertical: `am_slicer` in [verticals.toml](../../benchmarks/competitive/verticals.toml)

## Build

```bash
lic build src/lib.li -o li-sim-additive
```

| Field | Value |
|-------|-------|
| Package | `PKG-li-sim-additive` |
| Program | [PH-AM](../../docs/game-dev/PH-world-studio-program.md) |
| RFC | [li-sim-additive-rfc.md](../../docs/game-dev/specs/li-sim-additive-rfc.md) |
| Org repo | https://github.com/li-langverse/li-sim-additive |
