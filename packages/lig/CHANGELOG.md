# Changelog

All notable changes to this package will be documented in this file.

## [Unreleased]

### Added

- **PH-HW HW-0** — Rename package `li-gpu` → `lig`; import `lig`.
- **Device API** — `lig_device_kind`, `lig_backend_available`, `lig_backend_select_auto`, `lig_capability_json`, `lig_parse_toml_backend_line`, `lig_present_surface_ok`.
- **Runtime** — `li_rt_lig_*` in `runtime/li_rt.c` + `emit.cpp` declarations.
- **Probe bench** — `bench/device_probe.toml`; smoke `lig_device_probe.li`.

### Changed

- **wgpu smoke** — `LigWgpuSmoke` / `lig_wgpu_smoke_*`; `surface_ok` follows `lig_present_surface_ok()`.

### Removed

- **`li-gpu` package name** — workspace member `lig` replaces `li-gpu`.
- **lig.present (PH-HW HW-1)** — `LigSwapchain`, `LigPresentFrame`, wgpu smoke via trusted `li_rt_lig_*` edge; bench `wgpu_smoke.toml` with x86_64-linux / aarch64-darwin CI notes.
- HW-3 memory ledger (`lig_memory_budget_mib`, `lig_alloc_within_budget`, `LigMemoryLedger`) and `memory/lib.li` slice.
- HW-4 custom targets (`lig_custom_target_descriptor`, `lig_custom_load_signed_driver` OSS stub, `lig_custom_lab_id_fpga`).
- `lig_backend_switch_log` audit stub; smoke `memory_budget.li`.

## [0.1.0] - 2026-05-25

### Added

- WP4 LKIR matmul pilot, `lig_kernel_run` / `lig_validity_gate_pass`, `runtime/li_rt_lig.c`.
