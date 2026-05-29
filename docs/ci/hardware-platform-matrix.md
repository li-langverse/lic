# Hardware platform matrix (PH-HW)

Where to run GPU-related work packages — **no fake timings**; each host only claims what it verifies.

| Host | Typical machine | Primary backends | WPs to run here | Do not claim here |
|------|-----------------|------------------|-----------------|-------------------|
| **Apple Silicon (M1+)** | MacBook, local dev | **Metal** (`bid=3`), WebGPU probe | WP-HW on Metal path; `lig_device_probe.li`; Studio present smokes | CUDA, HIP, lavapipe Vulkan compute |
| **Linux + NVIDIA** | Remote lab, CI GPU runners | **CUDA** (`bid=1`), Vulkan/SPIR-V (`bid=5`) when loader present | WP-HW-08/09 emit probes; `LIG_EMIT_CUDA=1` bench; future PTX dispatch | Metal |
| **Linux + AMD** | ROCm box | **HIP/ROCm** (`bid=2`) | WP-HW-10 with `ROCM_PATH` / `LIG_EMIT_HIP=1` | CUDA, Metal |
| **Linux CPU-only CI** | GitHub `ubuntu-latest` | WebGPU stub, SPIR-V header validation | Advisory [lavapipe-vulkan-smoke](lavapipe-vulkan-smoke.md) | Device `gpu_timing_ns` |

## Auto backend selection (`lig_backend_select_auto`)

1. **macOS** → Metal when `__APPLE__`.
2. **Linux** → ROCm if `ROCM_PATH`/`HIP_PATH`, else CUDA if `CUDA_HOME`/`CUDA_PATH`, else Vulkan SPIR-V when probe passes, else WebGPU.

User Li never embeds vendor strings; set env on the host (see [cuda-toolkit-setup.md](cuda-toolkit-setup.md), [metal-macos-smoke.md](metal-macos-smoke.md)).

## Lab NVIDIA (Debian 13, RTX 3060)

```bash
export CUDA_HOME=/usr/lib/cuda
export PATH="$CUDA_HOME/bin:$PATH"
bash scripts/cuda-home-probe.sh          # wp_hw_09: ready_emit_cpu_ref
LIG_EMIT_CUDA=1 ./scripts/bench-lig-gpu-suite.sh   # cuda_emit_status=1, gpu_timing_ns still N/A
```

`gpu_timing_ns` stays **N/A** until real device kernels ship (WP-HW-08); emit path runs CPU 2×2 reference only.

## Mac M1 checklist

```bash
./scripts/build.sh
lic check packages/lig/li-tests/smoke/lig_device_probe.li
# expect lig_backend_select_auto() == Metal (3)
```

CUDA toolkit and `nvidia-smi` are **not** required on Apple Silicon.
