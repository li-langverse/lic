# PH-HW: platform matrix + NVIDIA lab CUDA toolkit

**Date:** 2026-05-29  
**Branch:** `feat/ph-ml-gpu-swarm`

## Summary

- Document **where** hardware WPs run: **M1 → Metal** ([metal-macos-smoke.md](../ci/metal-macos-smoke.md)), **Linux NVIDIA → CUDA** ([cuda-toolkit-setup.md](../ci/cuda-toolkit-setup.md)).
- NVIDIA lab (RTX 3060, Debian 13): installed `nvidia-cuda-toolkit`, `CUDA_HOME=/usr/lib/cuda`, `cuda-home-probe` → `ready_emit_cpu_ref`.
- WP-HW-09 tracker: **blocked → partial** (nvcc present; `gpu_timing_ns` still N/A until WP-HW-08 device dispatch).

## Verify

```bash
export CUDA_HOME=/usr/lib/cuda PATH=/usr/lib/cuda/bin:$PATH
bash scripts/cuda-home-probe.sh
LIG_EMIT_CUDA=1 ./scripts/bench-lig-gpu-suite.sh
li-tests/run_all.sh gpu
```
