---
workflow_repo: lic
branch: main
plan: data/goal-directed-sprints/ph-sci-gpu-vendor-02-deferral.md
parent: data/goal-directed-sprints/ph-sci-simulation-gap-close-plan.md
---

# Goal: WP-SCI-GPU-VENDOR-02 — MD device buffer bind

**Single WP sprint** — resume only after PH-ML device-buffer infra is stable on `main`.

## Objective

Add MD grid device-buffer bind smoke + gate for `li-sim-scientific` / `li-physics-particles`, mirroring `ml_gpu_device_buffer.li`.

## Done when

- [ ] Smoke compiles under `--allow-open-vc --no-lean-verify`
- [ ] Returns `1` when `lig_gpu_device_buffer_ready()` + pipeline pass; honest `0` otherwise
- [ ] `ph-sci-gpu-gates.sh` includes optional CUDA path
- [ ] Deferral doc updated to **done**; parent plan → 33/33

## Commands

```bash
bash scripts/ph-sci-gpu-gates.sh
LIG_EMIT_CUDA=1 lic build packages/li-sim-scientific/li-tests/smoke/scientific_gpu_md_device_buffer.li -o /dev/null
```

## Out of scope

- Full LAMMPS/GROMACS GPU offload
- Address-space proofs (G-gpu)
