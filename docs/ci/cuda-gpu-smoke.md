# CUDA GPU smoke (WP-HW-09 blocker)

**Status:** Host probe + emit-stub path — **no** `gpu_timing_ns` until PTX/nvcc lands.  
**Tracker:** WP-HW-09 **blocked** when `nvidia-smi` visible but `CUDA_HOME` unset.

## Goal

Prove the CUDA toolchain path before claiming device kernels:

1. `CUDA_HOME` or `CUDA_PATH` set
2. Optional `nvcc` on `PATH` (version string captured, not timed)
3. `LIG_EMIT_CUDA=1` → host CPU 2×2 matmul ref + launch status `1` (emit stub)

## Host probe (lab / CI)

```bash
./scripts/cuda-home-probe.sh
./scripts/bench-lig-gpu-suite.sh   # merges probe into lig-gpu-suite-honest.json
```

Runtime mirror: `li_rt_lig_cuda_home_probe()` in `runtime/li_rt_lig.c` (bitmask: `1` = `CUDA_HOME`, `2` = `CUDA_PATH`, `4` = `nvcc` on PATH).

## Smokes

| Step | Command |
|------|---------|
| Emit off | `lic check packages/lig/li-tests/smoke/kernel_launch_status.li` → CUDA `bid=1` status `-2` |
| Emit on + home | `LIG_EMIT_CUDA=1 CUDA_HOME=/usr/local/cuda lic check packages/lig/li-tests/smoke/kernel_matmul_parity.li` |
| Bench JSON | `LIG_EMIT_CUDA=1 ./scripts/bench-lig-gpu-suite.sh` → `cuda_hardware` + `cuda_home_probe` |

## Evidence template (release notes)

```
$ ./scripts/cuda-home-probe.sh
$ echo CUDA_HOME=${CUDA_HOME:-unset}
```

**Do not** write measured `cuda_timing_ns` until nvcc-linked dispatch exists.

## Next WP

PTX emit + driver launch in `li_rt_lig_kernel_run` when `CUDA_HOME` + nvcc present; timed rows in `lig-kernels.toml` only after oracle parity gate passes.
