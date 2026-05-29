# GPU backend driver (`LI_GPU_BACKEND`)

**Phase 7d / PH-HW:** User kernels use `@gpu` / `@cpu` decorators; **vendor selection** is not a decorator argument.

## Backend selection

Configure in `li.toml` (package or app):

```toml
[engine.lig]
backend = "cuda"   # cuda | rocm | metal | webgpu
```

Legacy one-release alias:

```toml
[engine.gpu]
backend = "metal"
```

| `backend` | Lowering target | Notes |
|-----------|-----------------|-------|
| `cuda` | CUDA / NVPTX | NVIDIA |
| `rocm` / `hip` | HIP | AMD |
| `metal` | Metal | Apple |
| `webgpu` / `wgpu` | SPIR-V via wgpu | **One** portable path — not Vulkan-only |

## Driver script

```bash
./scripts/lig-gpu-compile-driver.sh packages/lig/examples/engine_lig.toml
```

Exports `LI_GPU_BACKEND` and runs the MIR `@gpu` gate (`check-mir-gpu-decorator.sh`). Full LKIR → vendor object emit remains **G-gpu** (stub).

## Compiler behavior

- `@gpu` on `def` → `MirDecorator.gpu` (+ optional `devices=N`).
- `@gpu` on `for` → `MirOp::GpuFor` helper + `li_rt_lig_gpu_for_i64` when `LI_GPU_BACKEND` is set; otherwise scalar loop calling the helper.
- `@cpu` → `MirDecorator.cpu` (host placement tag).
- Telemetry: `lic verify` prints `mir_gpu_def`, `mir_gpu_for`, `mir_cpu_def`, …

See [execution decorators spec](../superpowers/specs/2026-05-16-li-execution-decorators.md) and [lig-rfc.md](../game-dev/specs/lig-rfc.md).
