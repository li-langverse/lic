# PH-ML GPU merge readiness (PR #367)

**Branch:** `feat/ph-ml-gpu-swarm`  
**Date:** 2026-05-29  
**Tracker:** [PH-ML-GPU-execution-tracker.md](PH-ML-GPU-execution-tracker.md)

## Merges in #367 (software-only, honest stubs)

| Area | Deliverable |
|------|-------------|
| ML-0..2 | `li-ml` / `li-ml-rl` smokes, MNIST train step, tier-3 correctness path |
| GPU spine | LKIR/SPIR-V header validation, host launch status, `@gpu` parse/MIR partial |
| Bench | `bench-lig-gpu-suite.sh` — `gpu_timing_ns` / `cuda_timing_ns` remain **N/A** |
| Rules | `ph-ml-stub-then-implement.mdc`, `ph-ml-gpu-honesty.mdc` |
| Docs | Battle plan, tracker Waves **0–5** + **4b/4c/4d**, release notes |
| CI (advisory) | [lavapipe-vulkan-smoke.yml](../../.github/workflows/lavapipe-vulkan-smoke.yml) |

## Follow-up PRs (not blocking #367)

| Item | Repo / WP | Why separate |
|------|-----------|--------------|
| Vulkan compute dispatch | lic / WP-HW-07 | Needs linked Vulkan loader + `vkCreateComputePipelines` |
| CUDA PTX + timed rows | lic / WP-HW-09 | Needs `CUDA_HOME` + nvcc on CI GPU runner |
| G-gpu Lean `P-gpu-*` | lic / WP-GPU-05 | `lake build` discharge, not compile_fail only |
| Dynamic `tensor` | lic / WP-ML-13–14 | Phase 3 language |
| lic-studio-ui agent-kit 1.3.5 | lic-studio-ui `chore/agent-kit-1.3.5-studio-ui` | Sibling repo manifest sync |
| Tier-3 dashboard ingest | benchmarks / WP-BENCH-ML-06 | Real oracle CSV |

## Hardware / CI prerequisites (human)

| Gate | Command / env |
|------|----------------|
| Lavapipe | `VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.x86_64.json` `LIG_VULKAN_LAVA=1` |
| CUDA toolchain | `CUDA_HOME` or `CUDA_PATH` + `nvcc` — `./scripts/cuda-home-probe.sh` |
| ROCm | `ROCM_PATH` / `HIP_PATH` — WP-HW-10 |

## Merge recommendation

**Merge #367** when `./scripts/build.sh`, `lic check packages/*`, and `li-tests/run_all.sh gpu` are green on rebased `feat/ph-ml-gpu-swarm`. Treat WP-HW-07/08/09/13/14 as **blocked** with documented evidence; do not block merge on device nanoseconds or Lean proofs.

## Verify checklist (agent)

```bash
./scripts/build.sh
lic check packages/li-ml packages/li-ml-rl packages/lig
./li-tests/run_all.sh gpu
./scripts/bench-lig-gpu-suite.sh
```
