# CUDA embedded PTX catalog (WP-HW-09)

**Status:** Pilot — one embedded kernel (`lig.kernel.matmul_f32`)  
**Manifest:** [runtime/lig-ptx-catalog.toml](../../runtime/lig-ptx-catalog.toml)  
**Gate:** `bash scripts/check-lig-ptx-catalog.sh`

## Embedded (device launch)

| Kernel ID | Symbol | Source | PTX inc |
|-----------|--------|--------|---------|
| `lig.kernel.matmul_f32` | `lig_matmul2x2_f32` | `runtime/kernels/lig_matmul2x2.cu` | `runtime/lig_cuda_matmul2_ptx.inc` |

Regenerate PTX after editing `.cu`:

```bash
export CUDA_HOME=/usr/lib/cuda PATH=$CUDA_HOME/bin:$PATH
bash scripts/gen-lig-cuda-matmul-ptx.sh
bash scripts/check-lig-ptx-catalog.sh
```

Runtime loads modules via `li_rt_lig_cuda_ptx_lookup()` in [lig_cuda_ptx_catalog.c](../../runtime/lig_cuda_ptx_catalog.c).

## Blocked (documented — no fake timing)

All other `lig.kernel.*` rows in [lig-kernels.toml](../../benchmarks/competitive/lig-kernels.toml) remain **`cuda = "N/A"`** until embedded PTX or LKIR→nvcc emit lands. See `[[blocked]]` in the manifest.

## Probes (honesty)

| Script | Reports |
|--------|---------|
| `scripts/cuda-home-probe.sh` | `ready_emit_cpu_ref`, `embedded_ptx_*`, **no** `gpu_timing_ns` |
| `scripts/lig-cuda-timing-probe.sh` | `gpu_timing_ns` only after successful device launch + parity |

When `LIG_EMIT_CUDA=1` and device launch fails, `li_rt_lig_kernel_run` falls back to **CPU 2×2 reference** (`lig_matmul_cpu_ref_2x2`) — status `LI_LIG_KERNEL_EMIT_STUB`.

## Blocker

**Full catalog PTX emit** (LKIR → nvcc per kernel) remains **WP-HW-08+** / compiler — not claimed in Wave 5b.
