# CUDA toolkit setup (WP-HW-09 blocker)

**Status:** Host recipe — RTX-class driver (`nvidia-smi`) does **not** imply `nvcc` or `CUDA_HOME`.  
**Tracker:** WP-HW-09 stays **blocked** for PTX/device timing until toolkit + `CUDA_HOME` are set.

## Detect on lab / CI

```bash
command -v nvidia-smi && nvidia-smi -L
echo "CUDA_HOME=${CUDA_HOME:-unset} CUDA_PATH=${CUDA_PATH:-unset}"
command -v nvcc || ls "${CUDA_HOME:-/usr/local/cuda}/bin/nvcc" 2>/dev/null || true
```

## Debian 13 / Ubuntu 24.04 (lab)

```bash
sudo apt-get install -y nvidia-cuda-toolkit   # when available
# or NVIDIA CUDA repo: https://developer.nvidia.com/cuda-downloads
export CUDA_HOME=/usr/local/cuda
export PATH=$CUDA_HOME/bin:$PATH
```

After install: `LIG_EMIT_CUDA=1 ./scripts/bench-lig-gpu-suite.sh` — expect `gpu_timing_ns: N/A`.

## Evidence (2026-05-29 Wave 5b)

| Check | Lab (RTX 3060) |
|-------|----------------|
| `nvidia-smi -L` | pass |
| `CUDA_HOME` | **unset** |
| `nvcc` | **missing** |
