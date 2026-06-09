# Changelog

All notable changes to this package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **WP-SCI-03 Phase 2 slice** — CFD/FEA/QM integral tier-2 oracles (`sim_scientific_oracle_checksum_cfd`, `_fea`, `_qm_overlap`); `run_cfd_tier2_registry`, `run_fea_tier2_registry`, `run_qm_integral_tier2_registry` for registry ids 205–210, 211–216, 401–404; `vertical_cfd_lid_driven_cavity` / `vertical_fea_linear_elasticity` in `li-sim`; FEA oracle uses scalar stiffness trace (avoids float-array codegen gap on host).

### Added (prior)

- **WP-ECHEM-15 multiscale SEI growth kMC** — `sim_scientific_oracle_checksum_echem_sei_kmc`, `run_echem_sei_kmc_tier2_registry`, `algo_echem_sei_kmc()` (435) dispatch; 48-step NEB-barrier deposition kMC vs mean-field growth law; smoke `echem_sei_kmc_interface_smoke.li`.
- **WP-ECHEM-12 grand-canonical SHE AIMD** — `sim_scientific_oracle_checksum_echem_gc_aimd`, `run_echem_gc_aimd_tier2_registry`, `algo_echem_gc_aimd_interface()` (434) dispatch; 10-step constant-potential MD with `echem_gc_charge_neutrality_step` feedback; smoke `echem_gc_aimd_interface_smoke.li`.
- **WP-ECHEM-09 AIMD coupling** — `sim_scientific_oracle_checksum_echem_aimd`, `run_echem_aimd_tier2_registry`, `algo_echem_aimd_interface()` (433) dispatch; 8-step velocity-Verlet + Berendsen toy thermostat calling `chem_dft_energy_kernel_hartree` each step; smoke `echem_aimd_interface_smoke.li`.
- **WP-SCI-03 tier-2 kernels** — `sim_scientific_oracle_checksum_md`, `sim_scientific_oracle_checksum_heat`, `run_algo_registry` MD/heat/rigid dispatch; smokes `scientific_oracle_bench.li`, `run_algo_registry_tier2.li`.

### Changed

- `run_md_lj_smoke` / `run_heat_smoke` use tier-2 oracle checksums (not scalar stub / constant 1.0); `li_sim_scientific_version` → 6 (WP-ECHEM-15).
- **WP-SCI-01 multi-physics tick** — `sim_scientific_tick_at`, `run_multi_physics_at_step`, `sim_scientific_checksum_combine` (MD + heat + rigid smokes); smoke `li-tests/smoke/multi_physics_tick.li`.

### Changed (prior)

- `sim_scientific_tick_stub` delegates to `sim_scientific_tick_at(1, detail)`; `li_sim_scientific_version` → 2.

## [0.1.0] - 2026-05-25

### Added

- Package skeleton (`sim.scientific`): `run_md_lj_smoke`, `run_heat_smoke`, `run_rigid_smoke`, `run_algo`, `run_simulation`, `sim_scientific_tick_stub`.
