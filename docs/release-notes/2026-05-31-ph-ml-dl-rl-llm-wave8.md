# PH-ML Wave 8 — SOTA competitive benchmarks

**Date:** 2026-05-31  
**Branch:** `cursor/ph-ml-dl-rl-llm-wave8-sota-bench`

## Summary

Wave 8 adds **honest, executed** competitor drivers for PyTorch (CPU + optional CUDA), JAX (CPU), TensorFlow (optional), and Triton (GPU-only stub when unavailable). Results merge into `benchmarks/results/ph-ml-competitive.json` with `ratio_vs_li = competitor_cpu_sec / li_cpu_sec`.

## Workloads

| Row | Li measurement | Competitor workload | Sizes |
|-----|----------------|---------------------|-------|
| `matmul_lkir` | LKIR lig kernel kid=1 + validity gate | 4×4 f32 identity `@` / `matmul`, 50 timed runs | 4 (16 deferred for Li LKIR path) |
| `mlp_forward` | `ml_mlp_forward_f32` smoke build+run | PyTorch manual 2-2-1 ReLU MLP | in=2, hidden=2, out=1 |

**Honesty:** Li matmul row times the LKIR pilot (provability/validity gate), not the same micro-kernel as NumPy/PyTorch. Ratios are indicative; see `workload_note` in JSON.

## Gates

```bash
cd lic && bash scripts/ph-ml-wave8-gates.sh
```

Requires:
- Li smokes: `ml_matmul_general`, `ml_matmul_16_flat`, `ml_matmul_lkir_parity`, `ml_mlp_forward`
- `pytorch_cpu` + `jax_cpu` matmul competitors `executed: true` with `ratio_vs_li`
- `pytorch_cpu` MLP competitor `executed: true`
- TensorFlow / Triton / CUDA may be `executed: false` with documented `note`

## Pinned deps

`scripts/requirements-ph-ml-competitive.txt` — installed in gate script via pip.

## Deferred

- 16×16 matmul competitive row (Li LKIR path still 4×4 pilot)
- NumPy MLP competitor
- RL async SB3/Ray executed drivers
- TensorFlow in CI (optional heavy install)

## Provability

Tied to existing Li smokes and `validity_gate_pass` on LKIR matmul. G-ml stub limits unchanged — no overclaim vs BLAS/GPU incumbents.
