---
workflow_repo: lic
branch: feat/ph-ml-gpu-swarm
gates: ./scripts/build.sh && li-tests/run_all.sh gpu && bash scripts/lkir-validate.sh
---

# PH-ML + GPU — continue (post Metal/CUDA pilots)

**Branch:** `feat/ph-ml-gpu-swarm` (push after each logical chunk)  
**Plan:** `docs/game-dev/PH-ML-GPU-battle-plan.md`  
**Tracker:** `docs/game-dev/PH-ML-GPU-execution-tracker.md`  
**Rules:** `.cursor/rules/ph-ml-stub-then-implement.mdc`, `ph-ml-gpu-honesty.mdc`, `ph-ml-gpu-wp-scope.mdc`

## Already done (do not redo)

- Waves 0–5, CUDA device 2×2 matmul, Metal pilot (`li_rt_lig_metal.mm`), LKIR file parser, bench parity run, tier3 oracle smoke
- Mac verify: `./scripts/macos-metal-smoke.sh` (human may run in parallel)

## Pick 1–2 WPs this run (Linux-friendly)

| Priority | WP | Target |
|----------|-----|--------|
| 1 | WP-HW-07 | Vulkan compute pipeline beyond `VkInstance` smoke (lavapipe doc + minimal dispatch) |
| 2 | WP-GPU-06 | `@gpu def` → LKIR module hook / codegen launch prologue wiring |
| 3 | WP-HW-12 | Wire `mlp_forward_f32.lkir` into `lig_kernel_run` kid=2 path |
| 4 | WP-BENCH-ML-07 | Expand `resnet18_infer.toml` stub + honest N/A columns only |

## Hard rules

- No fake `gpu_timing_ns` — only integers from real device probes
- Stubs OK as step 1 only; same branch must implement or mark **blocked** with evidence
- `./scripts/build.sh` + `li-tests/run_all.sh gpu` must pass before push
- Update tracker + CHANGELOG + short release note per WP touched

## Exit

Commit, push `feat/ph-ml-gpu-swarm`, summarize WP states and verify commands in the PR comment body for #367.
