# Changelog

All notable changes to this package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **WP-SCI-03 tier-2 kernels** — `sim_scientific_oracle_checksum_md`, `sim_scientific_oracle_checksum_heat`, `run_algo_registry` MD/heat/rigid dispatch; smokes `scientific_oracle_bench.li`, `run_algo_registry_tier2.li`.

### Changed

- `run_md_lj_smoke` / `run_heat_smoke` use tier-2 oracle checksums (not scalar stub / constant 1.0); `li_sim_scientific_version` → 3.
- **WP-SCI-01 multi-physics tick** — `sim_scientific_tick_at`, `run_multi_physics_at_step`, `sim_scientific_checksum_combine` (MD + heat + rigid smokes); smoke `li-tests/smoke/multi_physics_tick.li`.

### Changed (prior)

- `sim_scientific_tick_stub` delegates to `sim_scientific_tick_at(1, detail)`; `li_sim_scientific_version` → 2.

## [0.1.0] - 2026-05-25

### Added

- Package skeleton (`sim.scientific`): `run_md_lj_smoke`, `run_heat_smoke`, `run_rigid_smoke`, `run_algo`, `run_simulation`, `sim_scientific_tick_stub`.
