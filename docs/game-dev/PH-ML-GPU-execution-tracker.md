# PH-ML + GPU execution tracker

**Status:** Waves 0–5 complete (2026-05-29)  
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
| **5** | Scale stubs | RFCs + tier-4 stub rows; blockers documented | **pass** |

---

## Work package registry (Wave 4–5)

| id | state | branch | verify | blocker |
|----|-------|--------|--------|---------|
| WP-HW-06 | partial | feat/ph-ml-gpu-swarm | `lkir_spirv_stub.li`, `li_rt_lkir_spirv.c` | Vulkan dispatch WP-HW-07 |
| WP-HW-08 | partial | feat/ph-ml-gpu-swarm | `kernel_launch_status.li`, `kernel_matmul_parity.li` | Real GPU execution |
| WP-HW-09 | partial | feat/ph-ml-gpu-swarm | `LIG_EMIT_CUDA=1` → status `1` | Hardware + PTX |
| WP-HW-10 | partial | feat/ph-ml-gpu-swarm | `LIG_EMIT_HIP=1` → status `1` | ROCm CI hardware |
| WP-HW-12 | partial | feat/ph-ml-gpu-swarm | `mlp_forward_f32.lkir` + catalog | GPU dispatch |
| WP-HW-14 | stub | feat/ph-ml-gpu-swarm | `lig-rfc.md` § multi-GPU | Scheduler impl |
| WP-GPU-04 | partial | feat/ph-ml-gpu-swarm | `gpu_decorator_mir.li`, `mir_gpu_proc` | G-gpu proofs |
| WP-GPU-06 | partial | feat/ph-ml-gpu-swarm | codegen launch prologue | LKIR module per `@gpu def` |
| WP-ML-11 | partial | feat/ph-ml-gpu-swarm | `dl_gpu_train_hook.li` | Device buffers + real GPU train |
| WP-BENCH-ML-05 | done | feat/ph-ml-gpu-swarm | `bench-lig-gpu-suite.sh` | `gpu_timing_ns` N/A |
| WP-BENCH-ML-06 | partial | feat/ph-ml-gpu-swarm | `tier3-ml-ingest-stub.json` | Dashboard ingest |
| WP-BENCH-ML-07 | stub | feat/ph-ml-gpu-swarm | `resnet18_infer.toml` | ONNX oracle + tensor |
| WP-DOC-ML-04 | done | feat/ph-ml-gpu-swarm | `ml-autograd-rfc.md` | WP-ML-13 impl |
| WP-RL-04 | stub | feat/ph-ml-gpu-swarm | `ml-rl-async-env-pool.md` + tick stub | Process IPC |
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
| 5 | RFC/docs only + tracker blockers | pass |

**Release notes:** [Wave 4](../release-notes/2026-05-29-ph-hw-wave-4-hardening.md) · [Wave 5](../release-notes/2026-05-29-ph-ml-wave-5-scale-stubs.md) · [Wave 2](../release-notes/2026-05-29-ph-hw-wave-2-lkir-gpu-pilot.md) · [Wave 3](../release-notes/2026-05-29-ph-ml-wave-3-rl-studio.md)

---

## Merge-ready checklist (PR #367)

- [x] Waves 0–5 tracker rows updated
- [x] `./scripts/build.sh` green
- [x] `lic check packages/lig/** packages/li-ml/**` smokes
- [x] No fake `gpu_timing_ns` in JSON/TOML
- [x] CHANGELOG Unreleased + release notes
- [ ] Human: Vulkan lavapipe dispatch (WP-HW-07)
- [ ] Human: NVIDIA/AMD hardware for timed CUDA/HIP rows
- [ ] Human: G-gpu Lean proofs (WP-GPU-05)

**Maintainers:** Mirror battle plan §5 **State** when follow-up PRs land.
