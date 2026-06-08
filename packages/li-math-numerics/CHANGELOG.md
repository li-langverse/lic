# Changelog

All notable changes to this package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- BDF-1/2 fixed-step stiff ODE stubs (`bdf1_step_scalar`, `bdf2_step_scalar`, `bdf2_step_vec2`) and `newton_implicit_step_scalar` (lic#35 ode-r3).
- Smoke test `bdf_stiff_ode.li` + `numerics_stiff_ode_bdf_smoke()` linear decay gate.
- Initial scaffold via `scripts/li-new-package` (PKG-li-std-numerics).

## [0.1.0] - 2026-05-16

### Added

- Package skeleton.
