# PH-ML + GPU execution tracker

**Status:** Active (2026-05-29)  
**Branch:** `feat/ph-ml-gpu-swarm`  
**Plan:** [PH-ML-GPU-battle-plan.md](PH-ML-GPU-battle-plan.md)

---

## Wave ladder

| Wave | Theme | Exit gate |
|:----:|-------|-----------|
| **-1** | Agent-kit + `.cursor` bootstrap | manifest ≥ 1.3.4; PH-ML rules/skills/hooks |
| **0** | ML-0 packages | `./scripts/build.sh` + all `li-ml` / `li-ml-rl` smokes |
| **1** | CPU ML truth | Tier-3 correctness CSV; MNIST MLP forward |
| **2** | GPU spine | LKIR + SPIR-V; one honest GPU timing field |
| **3** | RL + Studio | Persistent env pool; `sim_rl` demo |

---

## Work package registry

**Columns:** `id` · `state` · `branch` · `verify` · `blocker`

| id | state | branch | verify | blocker |
|----|-------|--------|--------|---------|
| WP-ML-01 | done | feat/ph-ml-gpu-swarm | `li-ml`, `li-ml-rl` in `packages/li.toml` | — |
| WP-ML-02 | done | feat/ph-ml-gpu-swarm | `lic check packages/li-ml/li-tests/smoke/activations.li` | — |
| WP-ML-03 | done | feat/ph-ml-gpu-swarm | `lic check packages/li-ml/li-tests/smoke/mlp_forward.li` | — |
| WP-ML-04 | stub | — | — | Wave 1; tier-3 NumPy oracle |
| WP-ML-05 | stub | — | — | Wave 1 |
| WP-ML-06 | done | feat/ph-ml-gpu-swarm | `lic check packages/li-ml/li-tests/smoke/train_step.li` | — |
| WP-ML-07 | WIP | — | partial `dl_train_step4` | Wave 1 manual backward |
| WP-ML-08 | stub | — | — | Wave 1 |
| WP-ML-09 | done | feat/ph-ml-gpu-swarm | `lic check packages/li-ml/li-tests/smoke/ai_batch.li` | — |
| WP-ML-10 | partial | feat/ph-ml-gpu-swarm | `lic check …/gpu_bridge.li` | WP-HW-08 host launch |
| WP-RL-01 | done | (prior) | `env_obs_from_session.li` | merged contract |
| WP-RL-02 | done | feat/ph-ml-gpu-swarm | 3× `lic check packages/li-ml-rl/li-tests/smoke/*.li` | — |
| WP-RL-03 | stub | — | — | Wave 3 persistent pool |
| WP-DOC-ML-02 | done | feat/ph-ml-gpu-swarm | battle plan in `docs/game-dev/` | — |
| WP-DOC-ML-03 | done | feat/ph-ml-gpu-swarm | `packages/li-ml/README.md` + traceability stub | — |
| WP-GPU-01 | partial | main | parse `@gpu` | G-gpu MIR/codegen |
| WP-HW-01 | partial | main | `lig_device_probe.li` | — |
| WP-HW-06 | stub | — | — | SPIR-V emitter — blocks GPU perf |

---

## Wave 0 verification log

Run after merge:

```bash
./scripts/build.sh
lic check packages/li-ml/li-tests/smoke/*.li
lic check packages/li-ml-rl/li-tests/smoke/*.li
```

Update this section with commit SHA and pass/fail summary when the wave closes.

| Run | Result |
|-----|--------|
| `./scripts/build.sh` | pass (`b9051d03`) |
| 6× `li-ml` smokes `lic check --no-cache` | pass |
| 3× `li-ml-rl` smokes `lic check --no-cache` | pass |

**Maintainers:** Mirror battle plan §5 **State** when PRs land; link release notes under `docs/release-notes/`.
