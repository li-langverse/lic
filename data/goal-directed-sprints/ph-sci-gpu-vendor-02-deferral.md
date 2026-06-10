---
workflow_repo: lic
branch: main
plan: data/goal-directed-sprints/ph-sci-simulation-gap-close-plan.md
wp: WP-SCI-GPU-VENDOR-02
---

# WP-SCI-GPU-VENDOR-02 — Device buffer bind for MD grid

**Status:** **DONE** (partial — host bind scaffold; full CUDA MD kernel offload out of scope)  
**Landed:** `feat/ph-sci-gpu-vendor-02` — smoke `scientific_gpu_md_device_buffer.li` (PH-SCI-GPU-20), `sim_scientific_md_gpu_device_buffer_pipeline`, `li_rt_lig_gpu_md_grid_device_buffer_bind`.

## Scope delivered

Bind MD particle/grid state through the PH-ML Wave 13 device-buffer pipeline (`ml_gpu_device_buffer_pipeline`, `lig_gpu_device_buffer_ready`, `lig_gpu_md_grid_device_buffer_bind`) for the `li-sim-scientific` MD oracle hot path — mirroring `packages/li-ml/li-tests/smoke/ml_gpu_device_buffer.li`.

## Honest limits (still stub)

- **LKIR kernel:** reuses matmul pilot id (same scaffold as chem DFT); `lig.kernel.md_force_short` lowering not wired.
- **Device memory:** host-side byte accounting only; no CUDA/HIP alloc or GPU readback of MD forces yet.
- **Vendor path:** returns `1` only when `LIG_EMIT_*` + full `ml_gpu_device_buffer_pipeline()` pass; honest `0` otherwise.

## Acceptance (met)

1. `@gpu` smoke `scientific_gpu_md_device_buffer.li` returns `1` when `lig_gpu_device_buffer_ready()` and `ml_gpu_device_buffer_pipeline()` both pass (plus MD oracle CPU checksum gate).
2. Honest skip (`0`) when vendor emit absent — same pattern as `ml_gpu_device_buffer.li`.
3. Gate chained in `scripts/ph-sci-gpu-gates.sh` (`LIG_EMIT_CUDA=1` optional path).
4. Registered in `science_gpu` manifest as PH-SCI-GPU-20 (21 rows total).

## Dependencies

| Track | Item |
|-------|------|
| PH-ML | Wave 13 T2 device buffers (`ml_gpu_device_buffer.li`) |
| lig | `li_rt_lig_gpu_device_buffer_ready` + `li_rt_lig_gpu_md_grid_device_buffer_bind` |
| PH-SCI | `science_gpu` MD oracle row (`scientific_gpu_md_oracle.li`) |

## Verification

```bash
bash scripts/ph-sci-gap-close-phase2-gate.sh
bash scripts/ph-sci-gpu-gates.sh
./li-tests/run_all.sh science_gpu
LIG_EMIT_CUDA=1 lic build packages/li-sim-scientific/li-tests/smoke/scientific_gpu_md_device_buffer.li -o /dev/null
```
