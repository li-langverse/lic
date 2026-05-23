# Wave D AL-5 — engineering / CAE RFC (2026-05-23)

## Summary

**wave-d-17-cae-rfc (AL-5):** split FEA and CFD from **PH-SCI** into **PH-CAE** with fundamentals doc, RFC stub, Layer B registry rows, and doc linkage gate.

## Changes

- `docs/ecosystem/engineering-cae-fundamentals.md` — FEA vs CFD gap table, PH-CAE milestones
- `docs/game-dev/specs/li-sim-cae-rfc.md` — PH-CAE RFC stub
- `benchmarks/competitive/verticals.toml` — `fea_linear_elasticity`, `cfd_lid_driven_cavity`
- `docs/ecosystem/vertical-algorithm-catalog.md` — two new vertical sections
- `scripts/check-engineering-cae-rfc.sh` — gate (wired in `hpc_competitive_registry.sh`)
- `docs/game-dev/PH-world-studio-program.md`, `world-studio-vision.md`, `sim-viz-scientific-rfc.md`

## Plan

Marks `wave-d-17-cae-rfc` completed on compiler-studio plan loop.
