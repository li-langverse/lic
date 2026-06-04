# PH-ML-GPU battle plan ? native ML/DL/RL on Li

**Status:** Wave 13 program complete (partial ? T1/T6 landed 2026-05-31); Wave 12 final deferred (2026-05-31); Wave 11 carryover (2026-05-31); Wave 10 LLM depth + RL IPC + MLP competitors (2026-05-31); Wave 9 LLM recovery + C++/Rust competitors (2026-05-31); Wave 8 SOTA competitive drivers (2026-05-31); Wave 6 flat matmul + process env scaffold + competitive benches (2026-05-31); Wave 5 thread-pool RL + JobGraph queue (2026-05-31); Wave 4 merged (2026-05-30); Wave 3 JobGraph landed (2026-05-30); Wave 1 spine on branch  
**Vision:** [world-studio-vision.md](world-studio-vision.md)  
**RFC:** [specs/ml-async-parallel-rfc.md](specs/ml-async-parallel-rfc.md)  
**Tracker:** [PH-ML-GPU-execution-tracker.md](PH-ML-GPU-execution-tracker.md)

## Overview

**PH-ML** delivers native-first ML/DL/RL: CPU correctness spine in Wave 1, LKIR/GPU pilot in Wave 2, async JobGraph + Studio RL in Wave 3; general matmul + MLP + sync env workers in Wave 4; pthread parallel env rewards + sample queue in Wave 5; 16?16 flat matmul + OS process env scaffold + SOTA competitive registry in Wave 6.

## Waves

| Wave | Scope | Packages | Gate |
|------|-------|----------|------|
| **1** | CPU matmul spine, li-ml-rl scaffold, PH-LLM smokes | li-ml, li-ml-rl, li-llm | lic check smokes |
| **2** | LKIR matmul via @gpu, tier-3 bench row | li-ml, lig | bench JSON |
| **3** | Async JobGraph, >=4 env sample collection | li-ml-rl, li-sim | bench + studio sim_rl |
| **4** | Persistent EnvPool + DL spine (matmul, MLP, sync workers) | li-ml, li-ml-rl, li-llm | wave4 gates + tier-3 MLP bench |
| **5** | Thread-pool env workers + JobGraph sample queue | li-ml-rl, li-sim | wave5 gates |
| **6** | 16?16 flat matmul, process env scaffold, PH-LLM bench row, competitive registry | li-ml, li-ml-rl, li-llm, li-sim | ph-ml-wave6-gates.sh |
| **7** | PH-LLM scaffold + NumPy competitor driver | li-llm, li-ml | ph-ml-wave7-gates.sh |
| **8** | PyTorch/JAX/TF/Triton competitor drivers + honest ratio_vs_li | li-ml, scripts | ph-ml-wave8-gates.sh |

| **9** | PH-LLM Wave 7 recovery + C++/Rust matmul + matmul perf + process mode 2 | li-llm, li-ml, li-sim | ph-ml-wave9-gates.sh |

| **10** | PH-LLM depth + RL IPC scaffold + NumPy/C++ MLP + SB3 driver + tier-3 LLM bench | li-llm, li-ml, li-sim | ph-ml-wave10-gates.sh |
| **12** | Final deferred: LIG emit, mmap loader, GPU launch pipeline, RL fork, SB3/TF/Triton gates | li-llm, li-ml, li-sim, lig | ph-ml-wave12-gates.sh |

| **13** | **Program complete:** vendor lowering bytes, device buffers, import ml, Li fork, SB3/Ray hard CI, 32x32 competitive, weights mmap, live httpd proxy | li-llm, li-ml, li-sim, lig, li-studio | ph-ml-program-complete-gates.sh |

| **Stage 2** | **Native DL spine:** LKIR 32-tile matmul, MLP kid=2, competitive MLP, autograd RFC + train-step scaffold | li-ml, lig | ph-ml-stage2-gates.sh |

| **Stage 3** | **Parallel RL:** async_env_collect executed, IPC shard scaffold, CartPole stub, train policy_loss_mean | li-ml-rl, li-sim | ph-ml-stage3-gates.sh |

| **Stage 4** | **LLM import:** safetensors/GGUF on-disk parse, ph-ml-weights fixture, lillm-import offline, tier-3 pilot bench | li-llm | ph-ml-stage4-gates.sh |

| **Stage 5** | **Transformer forward:** ml_matmul_f32 on safetensors bytes, multi-token decode (>=8), tier3_cpu bench | li-llm | ph-ml-stage5-gates.sh |

| **HPC master** | **AI library complete:** Stage 5 + no stub Li competitive rows | li-llm | ph-ml-hpc-ai-library-gates.sh |

| **11** | Wave 10 carryover: GPU/LKIR matmul, safetensors bytes, RL fork IPC, Rust MLP, 16x16 row | li-llm, li-ml, li-sim | ph-ml-wave11-gates.sh |


## Stage 2 ? Native DL spine (post program-complete)

LKIR 32-tile matmul prologue, lig kid=2 MLP forward, tier-1 competitive MLP row, autograd forward-tape RFC, and forward-only `ml_mlp_train_step` bench (`autograd_mode: forward_only_scaffold`). Gate: `ph-ml-stage2-gates.sh`.

## Stage 3 ? Parallel RL

Workspace `li-ml-rl`, pthread `async_env_collect` bench + competitive Li row, IPC shard prepare + CartPole-v1 stub semantics, JobGraph `policy_loss_mean` train scaffold. Full PPO deferred: `specs/ml-rl-ppo-deferral.md`. Gate: `ph-ml-stage3-gates.sh`.

## Stage 4 - LLM import pipeline

On-disk safetensors header parse (dtype/shape/tensor count), minimal GGUF header, `fixtures/ph-ml-weights` via `prepare_ph_ml_weights_fixture.py`, `lillm-import.sh` offline manifest, `li_rt_llm.c` runtime probes. Tier-3 `ph-ml-llm-forward` tagged `workload_class=pilot` when `tensor_metadata_ok`. Gate: `ph-ml-stage4-gates.sh`.

## Stage 5 ? transformer forward + multi-token decode

`llm_forward_matmul_top_id` uses `ml_matmul_f32` on safetensors mmap bytes; `llm_generate_tracked` greedy decode >=8 steps. Bench `forward_matmul_ok`, competitive Li row `tier3_cpu`. Gate: `ph-ml-stage5-gates.sh`. Master: `ph-ml-hpc-ai-library-gates.sh`.

## Stage 6 ? li-httpd native generate

`llm_trusted_httpd_native_generate_ok` runs native decode on `fixtures/ph-ml-weights`; bench `native_generate` (Python T8 `live_proxy` retired for prod gate). Gate: `ph-ml-stage6-gates.sh`.

## Wave 13 ? program complete (all deferred T1?T8)

