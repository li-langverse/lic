# CUDA toolkit setup (WP-HW-09)

**Status:** Host recipe — RTX-class driver (`nvidia-smi`) does **not** imply `nvcc` or `CUDA_HOME`.  
**Tracker:** WP-HW-09 is **partial** once toolkit + `CUDA_HOME` are set; **device timing** stays blocked until real PTX dispatch (WP-HW-08).  
**Platforms:** [hardware-platform-matrix.md](hardware-platform-matrix.md) · Mac M1 → [metal-macos-smoke.md](metal-macos-smoke.md).

## Detect on lab / CI

```bash
command -v nvidia-smi && nvidia-smi -L
echo "CUDA_HOME=${CUDA_HOME:-unset} CUDA_PATH=${CUDA_PATH:-unset}"
command -v nvcc || ls "${CUDA_HOME:-/usr/local/cuda}/bin/nvcc" 2>/dev/null || true
bash scripts/cuda-home-probe.sh
```

## Debian 13 / Ubuntu 24.04 (lab)

```bash
sudo apt-get install -y nvidia-cuda-toolkit   # Debian 13: 12.4.x
export CUDA_HOME="$(bash scripts/detect-cuda-home.sh)"   # often /usr/lib/cuda on Debian
export PATH="$CUDA_HOME/bin:$PATH"
```

After install: `LIG_EMIT_CUDA=1 ./scripts/bench-lig-gpu-suite.sh` — expect `gpu_timing_ns: N/A`, `cuda_home_probe.wp_hw_09`: `ready_emit_cpu_ref`.

## Evidence

| Check | Lab (RTX 3060) 2026-05-29 pre-toolkit | Lab post-toolkit |
|-------|----------------------------------------|-------------------|
| `nvidia-smi -L` | pass | pass |
| `CUDA_HOME` | **unset** | `/usr/lib/cuda` |
| `nvcc` | **missing** | `/usr/bin/nvcc` 12.4 |
| `bash scripts/cuda-home-probe.sh` | `blocked_ptx_nvcc_cuda_home_unset` | `ready_emit_cpu_ref` |
