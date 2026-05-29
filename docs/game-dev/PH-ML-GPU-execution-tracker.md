# PH-ML + GPU execution tracker

**Status:** Waves 0–3 complete (2026-05-29)  
**Branch:** `feat/ph-ml-gpu-swarm`  
**Plan:** [PH-ML-GPU-battle-plan.md](PH-ML-GPU-battle-plan.md)

---

## Wave ladder

| Wave | Theme | Exit gate | State |
|:----:|-------|-----------|-------|
| **-1** | Agent-kit + `.cursor` bootstrap | manifest ≥ 1.3.4; PH-ML rules/skills/hooks | **pass** |
| **0** | ML-0 packages | `./scripts/build.sh` + all `li-ml` / `li-ml-rl` smokes | **pass** |
| **1** | CPU ML truth | Tier-3 correctness CSV; MNIST MLP forward | **pass** |
| **2** | GPU spine | LKIR + SPIR-V; one honest GPU timing field | **pass** (timing N/A honest) |
| **3** | RL + Studio | Persistent env pool; `sim_rl` demo | **pass** |

---

## Work package registry

| id | state | branch | verify | blocker |
|----|-------|--------|--------|---------|
| WP-ML-01 | done | feat/ph-ml-gpu-swarm | `li-ml`, `li-ml-rl` in `packages/li.toml` | — |
| WP-ML-02…09 | done | feat/ph-ml-gpu-swarm | li-ml smokes | — |
| WP-ML-10 | partial | feat/ph-ml-gpu-swarm | `gpu_bridge.li` | WP-HW-08 host launch |
| WP-BENCH-ML-01…03 | done | feat/ph-ml-gpu-swarm | tier1 ML benches | — |
| WP-BENCH-ML-02 | partial | feat/ph-ml-gpu-swarm | tier3 oracle | CSV ingest |
| WP-BENCH-ML-04 | partial | feat/ph-ml-gpu-swarm | pytorch N/A honest | torch optional |
| WP-BENCH-ML-05 | done | feat/ph-ml-gpu-swarm | `bench-lig-gpu-suite.sh` | gpu_timing_ns N/A |
| WP-RL-01…02 | done | feat/ph-ml-gpu-swarm | env contract smokes | — |
| WP-RL-03 | done | feat/ph-ml-gpu-swarm | `env_pool_persistent.li` | async workers → Wave 4 |
| WP-RL-05 | done | feat/ph-ml-gpu-swarm | `policy_forward.li` | GPU policy → Wave 4 |
| WP-RL-06 | done | feat/ph-ml-gpu-swarm | `studio_sim_step_by_profile.li` | — |
| WP-DOC-ML-01 | done | feat/ph-ml-gpu-swarm | `ml-async-parallel-rfc.md` | impl → Wave 4–5 |
| WP-DOC-ML-02…03 | done | feat/ph-ml-gpu-swarm | battle plan + README | — |
| WP-GPU-01 | partial | feat/ph-ml-gpu-swarm | `gpu_decorator_parse.li` | G-gpu MIR |
| WP-HW-01 | done | feat/ph-ml-gpu-swarm | `lig_device_probe.li` v3 | — |
| WP-HW-03…05 | done | feat/ph-ml-gpu-swarm | LKIR + smokes | — |
| WP-HW-06 | stub | — | — | SPIR-V emitter |
| WP-HW-08 | partial | feat/ph-ml-gpu-swarm | kernel_matmul_parity | Vulkan runtime |
| WP-HW-09 | stub | — | — | `LIG_EMIT_CUDA=1` emit |

---

## Wave verification log

| Wave | Run | Result |
|------|-----|--------|
| 0 | `./scripts/build.sh` + li-ml / li-ml-rl smokes | pass |
| 1 | 7× li-ml smokes + tier3 oracle script | pass |
| 2 | build + lig LKIR/vulkan smokes + bench JSON | pass (see release note) |
| 3 | li-ml-rl persistent + sim_rl_tick_session + studio profile | pass (see release note) |

**Release notes:** [2026-05-29-ph-hw-wave-2-lkir-gpu-pilot.md](../release-notes/2026-05-29-ph-hw-wave-2-lkir-gpu-pilot.md) · [2026-05-29-ph-ml-wave-3-rl-studio.md](../release-notes/2026-05-29-ph-ml-wave-3-rl-studio.md)

**Maintainers:** Mirror battle plan §5 **State** when PRs land.
