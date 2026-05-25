# Changelog

## [Unreleased]

### Added

- **PH-HW WP2** — matmul CPU oracle + md_force_short placeholder.
- **PH-HW HW-0** — Rename package `li-gpu` → `lig`; import `lig`.
- **Device API** — `lig_device_kind`, `lig_backend_available`, `lig_backend_select_auto`, `lig_capability_json`, `lig_parse_toml_backend_line`, `lig_present_surface_ok`.
- **Runtime** — `li_rt_lig_*` in `runtime/li_rt.c` + `emit.cpp` declarations.
- **Probe bench** — `bench/device_probe.toml`; smoke `lig_device_probe.li`.

### Changed

- **wgpu smoke** — `LigWgpuSmoke` / `lig_wgpu_smoke_*`; `surface_ok` follows `lig_present_surface_ok()`.

### Removed

- **`li-gpu` package name** — workspace member `lig` replaces `li-gpu`.
