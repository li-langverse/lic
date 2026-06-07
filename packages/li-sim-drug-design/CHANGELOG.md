# Changelog

All notable changes to this package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- PH-DRUG **DRUG-0/1** — five-stage LITL workflow (`drug_litl_stage_*`, `run_drug_litl_stage`, `run_drug_design_litl_workflow`, `sim_drug_design_tick_stub`).
- PH-DRUG **DRUG-1** — `sim_drug_design_litl_advance` stage advance and `sim_drug_design_inspector_payload` adaptive inspector helper (`DrugLitlStagePayload`).
- `li-chem` dependency for DFT stage smoke (`chem_dft_run_smoke`); `algo_drug_litl_stages()` in `li-sim`.
- Composable gate `li-tests/composable/import_sim_drug_design_litl_workflow.li`; extended package smoke.

### Changed

- `li_sim_drug_design_version()` → **4**.

### Added (prior)

- PH-SIM vertical gap **#3** — profile contract + studio id constants, `run_drug_design_smoke()`, package smoke (`li-tests/smoke/builds.li`).

## [0.1.0] - 2026-05-26

### Added

- Package skeleton (`sim.drug_design`).
