# RFC: ML / RL async parallel runtime (PH-ML)

**Status:** Active (Wave 3 design; async workers deferred)  
**Vision anchor:** [world-studio-vision.md §16](../world-studio-vision.md)  
**Default:** `ml.runtime.mode = "async_parallel"`

## Purpose

Studio RL demos and `li-ml` training loops must overlap **environment sampling**, **host tensor staging**, **GPU kernel launches**, and optional **cluster** steps without blocking the UI thread or lying about timing in benchmarks.

## Four parallelism axes

| Axis | Name | What overlaps | Li surface (Wave 3+) |
|------|------|---------------|----------------------|
| **1** | Sample | Many env instances stepping while policy is idle | `EnvPoolPersistent`, `env_pool_stub_step`, `sim_rl_tick_session` |
| **2** | Host prefetch | H2D / layout transforms while GPU executes prior wave | `ml.ai` batch staging (CPU today; streams later) |
| **3** | GPU streams | Kernel launches on dedicated queues vs present/viewport | `lig.kernel.launch` + `lig_backend_vulkan_spirv()` / vendor backends |
| **4** | Cluster | Multi-node shard of batch dim (Triton-distributed–class) | JobGraph stub in ML-5; not implemented in Wave 3 |

Axis 1 is **serial** in Wave 3 (`pool_size` envs stepped in a loop on one session) but **persistent** across Studio ticks via `SimSessionStub.rl_persistent_*`. Axes 2–4 are specified here for agent alignment; implementation slips to Wave 4–5 per [PH-ML-GPU-battle-plan.md](../PH-ML-GPU-battle-plan.md).

## Configuration

```toml
[ml.runtime]
mode = "async_parallel"   # sync | async_parallel
env_pool_size = 4
prefetch_batches = 1
gpu_streams = 1
```

## Honesty gates

- Benchmark JSON must mark `gpu_timing_ns = "N/A"` until SPIR-V dispatch lands (WP-HW-06).
- `LIG_EMIT_CUDA=1` required for CUDA matmul timing rows; default is stub `-1`.
- Studio `sim_rl` profile must call `sim_rl_tick_session` on the live session — no detached self-test that advances a throwaway stub.

## Related

- [lig-rfc.md](lig-rfc.md) — LKIR / backend matrix  
- [li-engine-unified-sim-rfc.md](li-engine-unified-sim-rfc.md) — `SimSessionStub` bridge
