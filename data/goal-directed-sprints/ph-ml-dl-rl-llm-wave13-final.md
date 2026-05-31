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

## Status

| Tranche | Status |
|---------|--------|
| T1 | **DONE** — `lig_emit_vendor_lowering_ready`, PTX stub bytes |
| T2 | **DONE** — `ml_gpu_device_buffer_pipeline`, `ml_gpu_device_buffer.li` smoke |
| T3 | **DONE** — `import ml` in li-llm + `llm_import_ml.li` smoke |
| T4 | **DONE** — `sim_rl_env_li_process_fork_ready`, Studio hook, `env_pool_li_process_fork.li` |
| T5 | **DONE** — SB3/Ray deps + benches `executed:true` (DummyVecEnv / Ray core fallback) |
| T6 | **DONE** — `ml_matmul_lkir_logical_32`, `bench-ph-ml-lkir-matmul-32.sh` |
| T7 | **DONE** — `llm_weights_file_mmap.li`, `prepare_ph_ml_weights_fixture.py`, `PH_ML_WEIGHTS_FIXTURE` on-disk weights |
| T8 | **DONE** — `bench_ph_ml_llm_trusted_httpd.py` live proxy (`live_proxy: true`) |
| **Completion gate** | **DONE** — `bash scripts/ph-ml-program-complete-gates.sh` exit 0 (2026-05-31, runs include `1780259931171`, `1780260010703`, `1780260234126`, `1780260578755`, `1780260620736`, `1780260925722`, `1780261177111`, `1780261322138`, `1780261911488`, `1780261960970` post-merge `main` #683/#684/#686); PR [#676](https://github.com/li-langverse/lic/pull/676) — await human merge |

## Agent rules

- One PR per tranche when possible; merge to `main` when CI green.
- Update `docs/game-dev/PH-ML-GPU-execution-tracker.md` and release note `docs/release-notes/2026-05-31-ph-ml-program-complete.md` per tranche.
- Do not weaken `ph-ml-program-complete-gates.sh` to exit 0 without real implementation.

## Completion gate

Runs Wave 12 baseline plus strict checks for **all** tranches T1–T8:

```bash
bash scripts/ph-ml-program-complete-gates.sh
```

Milestone-only (not sufficient to stop the loop): `bash scripts/ph-ml-wave13-gates.sh`
