# Changelog

## [Unreleased]

### Added

- **WP-SCI-GPU-VENDOR-01** — `lig_kernel_md_force_short()` (runtime kid=5); 4-particle LJ force pilot in `li_rt_lig.c`.
- **PH-HW HW-0** — Rename package `li-gpu` → `lig`; import `lig`.
- **Device API** — `lig_device_kind`, `lig_backend_available`, `lig_backend_select_auto`, `lig_capability_json`, `lig_parse_toml_backend_line`, `lig_present_surface_ok`.
- **Runtime** — `li_rt_lig_*` in `runtime/li_rt.c` + `emit.cpp` declarations.
- **Probe bench** — `bench/device_probe.toml`; smoke `lig_device_probe.li`.

### Changed

- **wgpu smoke** — `LigWgpuSmoke` / `lig_wgpu_smoke_*`; `surface_ok` follows `lig_present_surface_ok()`.

### Removed

- **`li-gpu` package name** — workspace member `lig` replaces `li-gpu`.
