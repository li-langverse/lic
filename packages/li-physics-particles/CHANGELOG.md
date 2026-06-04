# Changelog

All notable changes to this package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **WP-SCI-GPU-03** — `nbody_pair_force` accumulates softened 2D Newtonian force via `var float` borrow; smoke `nbody_pair_force.li`.

### Changed

- `md_mini_forces_3d` / `md_mini_step` remain 16-particle LJ integration path for `@gpu` smoke.

### Added

- Initial scaffold via `scripts/li-new-package` (PKG-li-std-physics-particles).

## [0.1.0] - 2026-05-16

### Added

- Package skeleton.
