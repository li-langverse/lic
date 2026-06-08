# Traceability — PKG-li-std-physics-fluids

<!-- DOC-traceability-PKG-li-std-physics-fluids -->

| Type | ID | Artifact |
|------|-----|----------|
| Package | PKG-li-std-physics-fluids | This repository |
| Phase | PH-Pkg | [Package scaffold](https://github.com/li-langverse/li-language/blob/dev/docs/superpowers/plans/2026-05-16-li-package-scaffold.md) |
| Test | T-PKG-li-std-physics-fluids-smoke | `li-tests/smoke/builds.li` |

## Requirements

Link design-spec `REQ-*` items when this package implements normative language or std behavior.

### Implicit PDE tier ([lic#117](https://github.com/li-langverse/lic/issues/117))

| REQ | Planned API | Benches |
|-----|-------------|---------|
| REQ-PDE-PC-4 | `AdvectionDiffusionSolver` | `advection_diffusion_2d` |
| REQ-PDE-PC-4 | `PressurePoisson` | `euler_fluid_2d`, `wind_field_bc` |

Normative rubric: [tier2-implicit-pde-preconditioner-rubric.md](../../../docs/numerics/tier2-implicit-pde-preconditioner-rubric.md). Package promotion tracked in [lic#14](https://github.com/li-langverse/lic/issues/14).

## Releases

Update `CHANGELOG.md` and `li.toml` `version` together; tag `vX.Y.Z` on GitHub.
