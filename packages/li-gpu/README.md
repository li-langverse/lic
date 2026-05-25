# li-gpu

GPU backend identifiers and **wgpu smoke** stubs for Li Studio (PH-HW). Real device surfaces land in a later PH-HW slice; this package exposes compile-verified smoke status for the bench harness.

## wgpu smoke

- `gpu_wgpu_smoke_run()` — returns `GpuWgpuSmoke` with `adapter_ok=1`, `surface_ok=0` (honest stub).
- Bench hook: `bench/wgpu_smoke.toml` consumed by `./scripts/bench-studio-viewport-perf.sh`.

## Backends

| ID | Constant |
|----|----------|
| CUDA | `gpu_backend_cuda()` |
| ROCm | `gpu_backend_rocm()` |
| Metal | `gpu_backend_metal()` |
| wgpu | `gpu_backend_wgpu()` |
