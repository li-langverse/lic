# PH-ML-GPU battle plan — native ML/DL/RL on Li

**Status:** Wave 7 PH-LLM scaffold + NumPy competitive driver (2026-05-31); Wave 6 flat matmul + process env scaffold + competitive benches (2026-05-31); Wave 5 thread-pool RL + JobGraph queue (2026-05-31); Wave 4 merged (2026-05-30); Wave 3 JobGraph landed (2026-05-30); Wave 1 spine on branch  
**Vision:** [world-studio-vision.md](world-studio-vision.md)  
**RFC:** [specs/ml-async-parallel-rfc.md](specs/ml-async-parallel-rfc.md)  
**Tracker:** [PH-ML-GPU-execution-tracker.md](PH-ML-GPU-execution-tracker.md)

## Overview

**PH-ML** delivers native-first ML/DL/RL: CPU correctness spine in Wave 1, LKIR/GPU pilot in Wave 2, async JobGraph + Studio RL in Wave 3; general matmul + MLP + sync env workers in Wave 4; pthread parallel env rewards + sample queue in Wave 5; 16×16 flat matmul + OS process env scaffold + SOTA competitive registry in Wave 6; PH-LLM tokenizer/safetensors/transformer scaffold + one external competitor driver in Wave 7.

## Waves

| Wave | Scope | Packages | Gate |
|------|-------|----------|------|
| **1** | CPU matmul spine, li-ml-rl scaffold, PH-LLM smokes | li-ml, li-ml-rl, li-llm | lic check smokes |
| **2** | LKIR matmul via @gpu, tier-3 bench row | li-ml, lig | bench JSON |
| **3** | Async JobGraph, >=4 env sample collection | li-ml-rl, li-sim | bench + studio sim_rl |
| **4** | Persistent EnvPool + DL spine (matmul, MLP, sync workers) | li-ml, li-ml-rl, li-llm | wave4 gates + tier-3 MLP bench |
| **5** | Thread-pool env workers + JobGraph sample queue | li-ml-rl, li-sim | wave5 gates |
| **6** | 16×16 flat matmul, process env scaffold, PH-LLM bench row, competitive registry | li-ml, li-ml-rl, li-llm, li-sim | ph-ml-wave6-gates.sh |

| **7** | PH-LLM Wave 1 progress + NumPy matmul competitor + process defer docs | li-llm, li-ml, li-sim | ph-ml-wave7-gates.sh |
