# Changelog

All notable changes to this package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Algo 105 neighbor-cell smoke re-exported via `sim.scientific` (`md_neighbor_cell_list_smoke_checksum`); C parity @ N=256 in `scripts/md-neighbor-cell-parity.c`.

- **WP-ECHEM-10 classical MD solvent shell** — `echem_solvent_*` water sphere (16-molecule 4×4 grid), TIP3P-like LJ + Ewald stub, O–O radial `g(r)` peak oracle vs `ph-sci-echem-solvent-gr-reference.json`; smokes `echem_solvent_gr_smoke.li`, composable `import_echem_solvent_smoke.li`; `li_std_physics_particles_version` → 2.
- Initial scaffold via `scripts/li-new-package` (PKG-li-std-physics-particles).

## [0.1.0] - 2026-05-16

### Added

- Package skeleton.
