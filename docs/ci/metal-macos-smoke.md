# Metal / Apple Silicon smoke (WP-HW, M1+)

**Host:** macOS on Apple Silicon (M1, M2, …).  
**Backend:** `lig_backend_metal()` → runtime id **3** (`LI_RT_LIG_BACKEND_METAL`).

## Prerequisites

- Xcode command-line tools (Metal frameworks available to the host linker when building `lic`).
- Same `lic` tree as Linux; no `CUDA_HOME`, no `nvidia-smi`.

## Smoke commands

```bash
cd lic
./scripts/build.sh
lic check packages/lig/li-tests/smoke/lig_device_probe.li
lic check packages/lig/li-tests/smoke/lkir_spirv_stub.li   # SPIR-V header only; no lavapipe on Mac
```

**Expected:** `lig_backend_select_auto()` returns Metal; `lig_backend_available(lig_backend_cuda())` is **0** (CUDA probe requires `CUDA_HOME` on non-Apple hosts only).

## WPs on Mac vs NVIDIA lab

| WP | Mac (Metal) | Linux NVIDIA |
|----|-------------|--------------|
| WP-HW-07 Vulkan compute | advisory only (use CI lavapipe) | lavapipe + GPU driver |
| WP-HW-08 device matmul | Metal dispatch (future) | CUDA dispatch (future) |
| WP-HW-09 PTX/nvcc | N/A | [cuda-toolkit-setup.md](cuda-toolkit-setup.md) |

See [hardware-platform-matrix.md](hardware-platform-matrix.md).
