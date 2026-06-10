---
workflow_repo: lic
branch: main
plan: data/goal-directed-sprints/ph-sci-simulation-gap-close-plan.md
wp: WP-SCI-GPU-VENDOR-02
---

# WP-SCI-GPU-VENDOR-02 — Device buffer bind for MD grid (deferred)

**Status:** **DEFERRED** (plan closed at **32/33**, ~97%)  
**Merged on main:** #1541 (`c988d702d`) — VENDOR-01 + VENDOR-03 landed; this WP out of scope for gap-close.

## Scope (when resumed)

Bind MD particle/grid state through the PH-ML Wave 13 device-buffer pipeline (`ml_gpu_device_buffer_pipeline`, `lig_gpu_device_buffer_ready`) for a science hot path — e.g. `li-sim-scientific` MD oracle or `li-physics-particles` mini-step — mirroring `packages/li-ml/li-tests/smoke/ml_gpu_device_buffer.li`.

## Why deferred

- **Chem/DFT path** already gates on `lig_gpu_device_buffer_ready()` in `chem_dft_gpu_lkir_launch_pipeline()`; that is LKIR launch scaffold, not MD grid bind parity.
- **MD grid bind** needs `lig` host/runtime device-buffer allocation + bind for simulation arrays (positions, forces), not yet wired for science packages.
- PH-ML Wave 12 T2 / Wave 13 T2 (`ml_gpu_device_buffer_pipeline`) covers ML matmul; science MD reuse requires a separate smoke + gate row in `science_gpu` or a dedicated `ph-sci-md-device-buffer-gate.sh`.

## Acceptance (future)

1. `@gpu` MD step smoke (e.g. `scientific_gpu_md_device_buffer.li`) returns `1` when `lig_gpu_device_buffer_ready()` and `ml_gpu_device_buffer_pipeline()` both pass.
2. Honest skip (`0`) when vendor emit absent — same pattern as `ml_gpu_device_buffer.li`.
3. Gate chained in `scripts/ph-sci-gpu-gates.sh` (optional `LIG_EMIT_CUDA=1`).

## Dependencies

| Track | Item |
|-------|------|
| PH-ML | Wave 13 T2 device buffers (`ml_gpu_device_buffer.li`) |
| lig | `li_rt_lig_gpu_device_buffer_ready` host contract |
| PH-SCI | `science_gpu` MD oracle row (`scientific_gpu_md_oracle.li`) |

## K8s (optional tiny sprint)

Goal file: [ph-sci-gpu-vendor-02.md](ph-sci-gpu-vendor-02.md) — scale worker only when resuming this WP.

## Verification (regression spine unchanged)

```bash
bash scripts/ph-sci-gap-close-phase2-gate.sh
bash scripts/ph-sci-gpu-gates.sh
./li-tests/run_all.sh science_gpu
```
