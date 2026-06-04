# Changelog

All notable changes to this package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **PH-IO-4 ingest → registry dispatch** — `sim_scientific_csv_ingest_bundle_tag`, `sim_scientific_ingest_then_md_registry`; smoke ties std.io/csv ingest to `run_algo(105)` tier-2 MD oracle.
- **PH-IO-4 scientific CSV ingest gate** — smoke `scientific_csv_ingest_gate.li` (`std.io`/`std.csv` before competitive vertical oracle checksums); phase-2 gate hook.
- **WP-SCI-GPU-VENDOR-02** — `sim_scientific_md_device_buffer_bind_ok`, `sim_scientific_gpu_md_device_buffer_pipeline`; smoke `scientific_gpu_md_device_buffer.li`; bench `scripts/bench-ph-sci-md-device-buffer.sh` (0.1% force-checksum parity).
- **WP-SCI-GPU-VENDOR-01** — `sim_scientific_md_lkir_progress`, `sim_scientific_gpu_lkir_launch_pipeline`; smoke `scientific_gpu_lkir_launch.li`; `lig.kernel.md_force_short` (kid=5); bench `scripts/bench-ph-sci-lkir-md-oracle.sh`.
- **WP-SCI-03 automotive + additive registry tier-2** — `sim_scientific_oracle_checksum_auto()` / `sim_scientific_oracle_checksum_additive()`; `run_auto_tier2_registry` (601–610), `run_additive_tier2_registry` (701–707); dep `li-sim-automotive`; extended `run_algo_registry_tier2.li`.
- **WP-SCI-03 rigid registry tier-2** — `sim_scientific_oracle_checksum_rigid()`; `run_rigid_tier2_registry` (301–305); `run_algo_registry_tier2.li` rigid oracle match.
- **WP-SCI-03 drug + robotics registry tier-2** — `sim_scientific_oracle_checksum_drug()` / `sim_scientific_oracle_checksum_robo()`; `run_drug_tier2_registry` (501–505), `run_robo_tier2_registry` (801–805); deps `li-sim-drug-design`, `li-sim-robotics`; extended `run_algo_registry_tier2.li`.
- **WP-SCI-03 QM tier-2 oracle** — `sim_scientific_oracle_checksum_qm()` delegates to `physics.quantum.qm_normalize_oracle_checksum()`; `run_qm_tier2_registry` for algo 401–432; smoke `scientific_qm_normalize.li`.
- **WP-SCI-05 FEA elasticity oracle** — `sim_scientific_oracle_checksum_fea()` delegates to `physics.rigid.fea_bar_oracle_checksum()`; `run_fea_tier2_registry` for algo 211–216; `vertical_fea_linear_elasticity()` in `sim`; smoke `scientific_fea_elasticity.li`.
- **WP-SCI-06 CFD cavity oracle** — `sim_scientific_oracle_checksum_cfd()` delegates to `physics.fluids.cavity_lid_oracle_checksum()`; `run_cfd_tier2_registry` for algo 205–210; `vertical_cfd_lid_driven_cavity()` in `sim`; smoke `scientific_cfd_cavity.li`.
- **WP-SCI-03 tier-2 kernels** — `sim_scientific_oracle_checksum_md`, `sim_scientific_oracle_checksum_heat`, `run_algo_registry` MD/heat/rigid dispatch; smokes `scientific_oracle_bench.li`, `run_algo_registry_tier2.li`.

### Changed

- `run_heat_tier2_registry` limited to algo 201–204 (FEA/CFD rows split from heat band); `li_sim_scientific_version` → 7 (drug/robo registry tier-2).
- **WP-SCI-01 multi-physics tick** — `sim_scientific_tick_at`, `run_multi_physics_at_step`, `sim_scientific_checksum_combine` (MD + heat + rigid smokes); smoke `li-tests/smoke/multi_physics_tick.li`.

### Changed (prior)

- `sim_scientific_tick_stub` delegates to `sim_scientific_tick_at(1, detail)`; `li_sim_scientific_version` → 2.

## [0.1.0] - 2026-05-25

### Added

- Package skeleton (`sim.scientific`): `run_md_lj_smoke`, `run_heat_smoke`, `run_rigid_smoke`, `run_algo`, `run_simulation`, `sim_scientific_tick_stub`.
