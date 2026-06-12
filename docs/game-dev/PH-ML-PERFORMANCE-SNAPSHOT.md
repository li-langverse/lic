# PH-ML Performance Snapshot

**Shareable overview** of Li native ML/RL/LLM benchmark results on CPU.  
**Generated from:** `benchmarks/results/ph-ml-*.json` on `main`  
**Snapshot date:** 2026-06-12  
**Commit:** `8378b7a64` (Phase L merge); Phase M honesty refresh pending Phase N regen

---

## 1. Executive summary

PH-ML has **gate-complete** inference and pilot autograd: 32×32 li-array matmul, LKIR matmul, 2-2-1 MLP forward, full backward train-step, async RL env collect, and LLM forward stub all **execute with validity gates passing**. The **performance gap vs NumPy/PyTorch CPU remains large** on matmul (Li ~122–135× slower than NumPy @ 32×32; target ≤2× not met) and MLP forward (Li ~0.29 s vs competitors ~2–7 µs per step — dominated by compile/runtime overhead in the smoke path). RL async collect shows Li **faster than SB3 SubprocVecEnv** on the current bench, but Li uses a **CartPole stub** while SB3 runs **real CartPole-v1** — not apples-to-apples. LLM forward runs natively; **no competitor executed** (llama.cpp, vLLM, transformers not installed in oracle image). **Multi-step training loops and competitive training benchmarks are starting** (Phase K: XOR SGD); prior state was inference + single-step backward only.

---

## 2. CPU matmul / li-array (32×32)

| Metric | Value |
|--------|-------|
| Li `cpu_sec` | **0.00027 s** (50-run mean) |
| NumPy `cpu_sec` | **0.000002 s** (2 µs) |
| `li_over_numpy` | **135×** (Li slower) |
| `ratio_target` | 2.0 (Li should be ≤2× NumPy) |
| `ratio_target_met` | **false** |
| `blas_backend` | openblas |
| `buffer_class` | dense_c_blas32 |
| `gemm_tile` | 16 (default) |

**Tile sweep** (`ph-ml-li-array-gemm-tile-sweep.json`):

| `gemm_tile` | Li `cpu_sec` | `li_over_numpy` |
|-------------|--------------|-----------------|
| 8 | 0.000152 s | 152× |
| 16 | 0.000245 s | 122.5× |

**Competitive row** (`li_array_matmul_32x32`): Li 0.000244 s, NumPy 2 µs, `ratio_vs_li` 0.0082 (~122×).

Phase H baseline was ~343×; dense 32×32 buffer + BLAS hook improved to ~122–135×. Target ≤2× still open.

---

## 3. MLP forward & LKIR matmul

### MLP forward (2-2-1 ReLU)

| Framework | `cpu_sec` | `ratio_vs_li` |
|-----------|-----------|---------------|
| **Li** | **0.292 s** | 1.0 |
| NumPy manual | 2 µs | 7×10⁻⁶ |
| PyTorch CPU | 7 µs | 2.4×10⁻⁵ |

Smoke path includes LKIR probe + nested matmul; not yet competitive with BLAS-backed frameworks.

### LKIR matmul (32×32 logical)

| Framework | `cpu_sec` | Notes |
|-----------|-----------|-------|
| **Li** | **0.00713 s** | 8×8 blocked LKIR |
| NumPy BLAS | 1 µs | `ratio_vs_li` 0.00014 (~7130×) |
| PyTorch CPU | 4 µs | executed |
| JAX CPU | 43 µs | executed |
| TensorFlow CPU | 115 µs | executed |
| C++/OpenMP, Rust, CUDA, Triton | — | not executed (no toolchain/GPU) |

### MLP train step (single step, backward)

| Field | Value |
|-------|-------|
| `cpu_sec` | **0.00792 s** |
| `autograd_mode` | `full_backward` |
| Topology | 2-2-1 f32 |

Backward pass is real; single-step bench only. Multi-step SGD: see **mlp_train** competitive row below.

### MLP training loop (Phase L — `mlp_train`)

| Field | Value |
|-------|-------|
| Kernel | `ml_mlp_sgd_step_f32` |
| Fixture | 2-2-1 XOR, 50 SGD steps |
| Li row | runtime autograd + weight update (`ml_mlp_train_bench.li`) |
| Competitor | PyTorch CPU SGD on same weights |
| JSON | `benchmarks/results/ph-ml-mlp-train-competitive.json` (generated; `executed` depends on lic+torch in env) |

---

## 4. RL async env collect

| Framework | `cpu_sec` | `ratio_vs_li` | Semantics |
|-----------|-----------|---------------|-----------|
| **Li** | **0.325 s** | 1.0 | `cartpole_v1_reward_shard_stub_x4`, pthread pool |
| SB3 SubprocVecEnv | 2.92 s | 8.99 | **real CartPole-v1** ×4 |
| Ray RLlib | 0.043 s | — | Ray core fallback (RLlib API deprecated) |

**Caveat:** Li bench uses **per-env reward shards**, not OpenAI Gym CartPole physics. SB3 runs **real CartPole-v1** — Li appears faster but workloads differ. See `docs/game-dev/ph-ml-cartpole-stub-honesty.md`.

Worker model: `pthread_pool`, 4 workers, 4 collect rounds.

---

## 5. LLM forward

| Framework | `executed` | `cpu_sec` | Note |
|-----------|------------|-----------|------|
| **Li** | **true** | **0.00049 s** | 50-run tier-3 mean |
| llama.cpp | false | — | llama-cli not installed |
| vLLM | false | — | not installed |
| transformers | false | — | torch/transformers not installed |

Li forward + matmul oracle pass; competitor rows are **honestly skipped**, not fabricated.

---

## 6. Training status (honest)

| Capability | Status | Evidence |
|------------|--------|----------|
| MLP forward | **exists** | `ml_mlp_forward_f32`, `ph-ml-mlp-forward.json` |
| MLP backward (single step) | **exists** | `ml_mlp_train_step_f32`, `autograd_mode: full_backward` |
| SGD weight update | **exists (Phase K)** | `ml_mlp_sgd_step_f32`, `ml_mlp_xor_sgd.li` gate |
| Multi-step training loop | **exists (Phase L)** | `mlp_train` row + `bench_ph_ml_mlp_train_competitive.py` |
| PyTorch training parity bench | **partial** | `ph-ml-mlp-train-parity.json` uses env vars for dw — superseded by Phase L competitive row |
| RL policy training | **stub** | `ml_rl_job_graph_train_step` scaffold only; no Li CartPole physics |
| SB3 train-step bench | **scaffold (Phase M)** | `sb3_train_step` row; `executed:false` when SB3/gymnasium missing |
| SB3 / Ray collect bench | **collect only** | `async_env_collect`; not policy `learn()` on Li side |
| LLM fine-tuning | **not present** | forward stub only |

---

## 7. Methodology footnotes

- **Native Li only** for Li rows: `lic build` + run; no Python shim for Li timings.
- **50-run mean** where noted (`tier3_runs: 50`, li-array 32×32 bench).
- **benchmark-oracle-llvm22** image: pre-baked PH-ML Python deps, LLVM 22, OpenBLAS (`LI_ARRAY_BLAS=openblas`).
- **Validity gates:** `validity_gate_pass: true` means output parity / smoke exit 0 — not performance targets.
- **`ratio_vs_li`:** competitor ÷ Li; values ≪1 mean competitor faster.
- **`li_over_numpy`:** Li ÷ NumPy; values >1 mean Li slower.
- **Competitor skips** recorded as `executed: false` with reason (no GPU, no compiler, package missing).
- **Honest labels:** `workload_class`, `env_semantics`, `autograd_mode` declared in JSON — read before comparing rows.

---

## 8. Provenance

| Field | Value |
|-------|-------|
| **Date** | 2026-06-12 |
| **Commit SHA** | `8378b7a64` (Phase L merge); Phase M doc refresh on main |
| **Primary JSON** | `benchmarks/results/ph-ml-competitive.json` (2026-06-07T16:51:26Z; Phase N regen pending) |
| **Supporting** | `ph-ml-li-array-matmul-32.json`, `ph-ml-li-array-gemm-tile-sweep.json`, `ph-ml-mlp-forward.json`, `ph-ml-mlp-train-step.json`, `ph-ml-mlp-train-competitive.json`, `ph-ml-async-env-collect.json`, `ph-ml-sb3-train-step.json`, `ph-ml-llm-forward.json`, `ph-ml-lkir-matmul-32.json` |

*Refresh this document after Phase N (`ph-ml-training-toy-sota` sprint).*
