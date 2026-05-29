# PH-ML + GPU execution tracker

**Status:** Wave 4b de-stub (2026-05-29)  
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
| **4** | Hardening | SPIR-V stub + launch status + `@gpu` MIR partial | **pass** |
| **4b** | De-stub pilot | Vulkan stub_ok + CPU matmul ref + RL serial batch | **pass** |
| **5** | Scale stubs | RFCs + tier-4 stub rows; blockers documented | **pass** |

---

## Work package registry (Wave 4b)

| id | state | branch | verify | blocker |
|----|-------|--------|--------|---------|
| WP-HW-06 | partial | feat/ph-ml-gpu-swarm | `lkir_spirv_stub.li`, `li_rt_lkir_spirv.c` | Full SPIR-V shader module |
| WP-HW-07 | in_progress | feat/ph-ml-gpu-swarm | SPIR-V validate → `bid=5` status `0`; `LIG_VULKAN_LAVA` probe | Vulkan compute pipeline + lavapipe CI |
| WP-HW-08 | in_progress | feat/ph-ml-gpu-swarm | CPU 2×2 ref + `kernel_matmul_parity.li` | Real GPU execution |
| WP-HW-09 | in_progress | feat/ph-ml-gpu-swarm | `LIG_EMIT_CUDA=1` + `CUDA_HOME` → ratio 1.0 | PTX / device kernel |
| WP-HW-10 | partial | feat/ph-ml-gpu-swarm | `LIG_EMIT_HIP=1` → status `1` + CPU ref | ROCm CI hardware |
| WP-HW-12 | partial | feat/ph-ml-gpu-swarm | `mlp_forward_f32.lkir` + catalog | GPU dispatch |
| WP-HW-14 | stub | feat/ph-ml-gpu-swarm | `lig-rfc.md` § multi-GPU | Scheduler impl |
| WP-GPU-04 | partial | feat/ph-ml-gpu-swarm | `gpu_decorator_mir.li`, `mir_gpu_proc` | G-gpu proofs |
| WP-GPU-05 | partial | feat/ph-ml-gpu-swarm | `gpu-host-device-alias.md`, compile_fail | Lean `P-gpu-*` corpus |
| WP-GPU-06 | partial | feat/ph-ml-gpu-swarm | codegen launch prologue | LKIR module per `@gpu def` |
| WP-ML-11 | partial | feat/ph-ml-gpu-swarm | `dl_gpu_train_hook.li` | Device buffers + real GPU train |
| WP-BENCH-ML-05 | done | feat/ph-ml-gpu-swarm | `bench-lig-gpu-suite.sh` wave 4b JSON | `gpu_timing_ns` N/A |
| WP-BENCH-ML-06 | partial | feat/ph-ml-gpu-swarm | `tier3-ml-ingest-stub.json` | Dashboard ingest |
| WP-BENCH-ML-07 | stub | feat/ph-ml-gpu-swarm | `resnet18_infer.toml` | ONNX oracle + tensor |
| WP-DOC-ML-04 | done | feat/ph-ml-gpu-swarm | `ml-autograd-rfc.md` | WP-ML-13 impl |
| WP-RL-04 | in_progress | feat/ph-ml-gpu-swarm | `async_env_pool_serial.li` | Fork IPC / multi-process |
| WP-ML-07 | done | feat/ph-ml-gpu-swarm | `dl_mlp4_backward_apply`, nn `w1_scale`+`w2` | Dynamic `tensor` (WP-ML-14) |
| WP-ML-08 | done | feat/ph-ml-gpu-swarm | `mnist_train_step.li` | Full dynamic weights |
| WP-ML-13 | blocked | — | RFC only | `tensor` Phase 3 |
| WP-ML-14 | blocked | — | tracker | WP-ML-13 + compiler |

---

## Wave verification log

| Wave | Run | Result |
|------|-----|--------|
| 0 | `./scripts/build.sh` + li-ml / li-ml-rl smokes | pass |
| 1 | 7× li-ml smokes + tier3 oracle script | pass |
| 2 | build + lig LKIR/vulkan smokes + bench JSON | pass |
| 3 | li-ml-rl persistent + sim_rl_tick_session + studio profile | pass |
| 4 | build + lig smokes + gpu_decorator_mir + bench-lig-gpu-suite | pass |
| 4b | wave 4b smokes + bench JSON + RL serial batch | pass (agent) |
| 5 | RFC/docs only + tracker blockers | pass |

**Release notes:** [Wave 4b](../release-notes/2026-05-29-ph-ml-de-stub-wave-4b.md) · [Wave 4](../release-notes/2026-05-29-ph-hw-wave-4-hardening.md) · [Wave 5](../release-notes/2026-05-29-ph-ml-wave-5-scale-stubs.md)

---

## Merge-ready checklist (PR #367)

- [x] Waves 0–5 + 4b tracker rows updated
- [x] `./scripts/build.sh` green
- [x] `lic check` on touched smokes
- [x] No fake `gpu_timing_ns` in JSON/TOML
- [x] CHANGELOG Unreleased + release notes
- [x] `ph-ml-stub-then-implement.mdc` rule
- [ ] Human: Vulkan compute dispatch on lavapipe (WP-HW-07 done)
- [ ] Human: NVIDIA/AMD hardware for timed CUDA/HIP rows
- [ ] Human: G-gpu Lean proofs (WP-GPU-05 done)

**Maintainers:** Mirror battle plan §5 **State** when follow-up PRs land.
