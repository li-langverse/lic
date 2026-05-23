# Release notes: wave-d-06 `li-gpu` wgpu smoke (2026-05-23)

## Summary

**wave-d-06-gpu-wgpu-smoke:** first **`import gpu`** package with device backend enum (`cuda`/`rocm`/`metal`/`wgpu`), LKIR module/kernel stubs, and wgpu smoke composable (`workload_class=stub`).

## Changes

- `packages/li-gpu/` — scaffold via `li-new-package`; `import_name = "gpu"`; `gpu_workload_class_stub`
- `packages/li-gpu/src/lib.li` — `GpuDevice`, `LkirModule`/`LkirKernel`, `wgpu_smoke_*` witnesses
- `li-tests/composable/import_gpu_wgpu_smoke.li` — `compile_open_ok`
- `li-tests/gpu_wgpu/import_gpu_wgpu_smoke_entry.li` — `verify_open_ok`
- `packages/li.toml` — workspace member `li-gpu`

## Plan

Marks `wave-d-06-gpu-wgpu-smoke` completed on compiler-studio plan loop.
