# RFC stub: sim-viz-scientific-rfc

**Status:** Draft stub  
**Date:** 2026-05  
**Track:** PH-SCI (MD, heat PDE, orbital, scientific viz — **not** engineering FEA/CFD)  
**CAE split:** [li-sim-cae-rfc.md](li-sim-cae-rfc.md) · [engineering-cae-fundamentals.md](../../ecosystem/engineering-cae-fundamentals.md) (**PH-CAE**)  
**Vision:** [world-studio-vision.md](../world-studio-vision.md)

## Problem

Scientific simulation in World Studio spans molecular dynamics, generic heat/PDE proxies, and viewport visualization. **Engineering FEA and CFD** are tracked under **PH-CAE** with separate `verticals.toml` rows — do not fold COMSOL/OpenFOAM-class claims into this RFC.

## Proposal

| Layer | Package | Status |
|-------|---------|--------|
| Viz pipeline | `sim.viz` ([li-sim-viz-rfc.md](li-sim-viz-rfc.md)) | **stub** — source/display/view composable |
| MD / heat / orbital | `sim.scientific`, `physics.*` | tier-2 benches |

<!-- TODO: numerics API, phases -->

## Li syntax

Use Python-style `def` for functions; `requires` / `ensures` / `decreases` on exported APIs.

## Proof / trust

<!-- TODO: what is proved vs trusted -->

## Dependencies

See [PH-world-studio-program.md](../PH-world-studio-program.md).

## Open questions

- [ ] …

