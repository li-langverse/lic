# Publish metadata — PKG-li-physics-core

| Field | Value |
|-------|--------|
| **PKG id** | `PKG-li-physics-core` |
| **Registry name** | `li-physics-core` (lip, phase 8d) |
| **Maintainer** | li-langverse |
| **Repository** | https://github.com/li-langverse/li-physics-core |
| **License** | Apache-2.0 OR MIT (SPDX) |

## Exports (v1)

- `PhysicsProfile`, `NumericalTargets`, `SimulationParams`
- `select_integrator_order`, `profile_for_tier`
- `SiUnit`, `PhysicalConstant`, `ScalarField2D`, `VectorField2D`
- `unit_seconds`, `unit_meters`, `c_light`, `k_boltzmann`

## Bench refs

All tier-2 physics benches via `PhysicsProfile` tier selection.

## Proof / coverage tier

| Gate | Required for registry |
|------|------------------------|
| `lic build` | Yes |
| `lit test --coverage` ≥ 80% | Yes (lip 8e) |
| ed25519 manifest signature | Yes (lip 8c) |
