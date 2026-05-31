# PH-ML / DL / RL / LLM Wave 13 — program complete (all deferred)

**Repos:** `lic` (primary)  
**Branch:** `cursor/ph-ml-program-complete` (from `main` @ Wave 12 merge, PR #675, ~455b40fd)  
**Runner:** goal-directed SDK `code_implementer` (`LI_SWARM_EXTERNAL=1`, `--max 0` until gate passes)

## Tranches (finish all before gate passes)

| ID | Deferred from Wave 12 | Done when |
|----|------------------------|-----------|
| **T1** | Vendor CUDA/HIP/Metal `LIG_EMIT` lowering (real PTX/HS/MSL bytes, not env-only progress) | `lig_emit_vendor_lowering_ready` + vendor stub emits non-empty backend artifact |
| **T2** | End-to-end `@gpu` → device buffers + G-gpu proofs | `ml_gpu_device_buffer.li` smoke + proof row in tracker |
| **T3** | `import ml` in li-llm when compiler allows | li-llm smoke with `import ml` builds under `lic` |
| **T4** | In-process Li fork env pool + Studio integration | `sim_rl_env_li_process_fork_ready` + Studio hook smoke |
| **T5** | SB3/Ray hard CI dependencies | CI installs + bench JSON `executed:true` without skip |
| **T6** | Li matmul 32×32+ competitive ratios | `bench-ph-ml-lkir-matmul-32.sh` + `ratio_vs_li` ≤ 2.0 vs NumPy CPU |
| **T7** | Full safetensors/GGUF from real weight files | mmap/GGUF smokes against `PH_ML_WEIGHTS_FIXTURE` on disk |
| **T8** | Ollama / live li-httpd proxy wiring | `bench_ph_ml_llm_trusted_httpd.py` with `live_proxy: true` |

## Agent rules

- One PR per tranche when possible; merge to `main` when CI green.
- Update `docs/game-dev/PH-ML-GPU-execution-tracker.md` and release note `docs/release-notes/2026-05-31-ph-ml-program-complete.md` per tranche.
- Do not weaken `ph-ml-program-complete-gates.sh` to exit 0 without real implementation.

## Completion gate

Runs Wave 12 baseline plus strict checks for **all** tranches T1–T8:

```bash
cd lic && bash scripts/ph-ml-program-complete-gates.sh
```

Milestone-only (not sufficient to stop the loop): `bash scripts/ph-ml-wave13-gates.sh`
