# PH-HW / bench: LKIR parse + parity run + tier3 oracle

**Date:** 2026-05-29  
**Branch:** `feat/ph-ml-gpu-swarm`

## Added

- `runtime/li_rt_lkir_parse.c` — validate `matmul_f32.lkir` and `mlp_forward_f32.lkir` on disk
- `scripts/lkir-validate.sh`, `packages/lig/li-tests/smoke/lkir_file_validate.li`
- `scripts/linux-gpu-smoke.sh` — NVIDIA lab one-shot (parallel to `macos-metal-smoke.sh`)
- `scripts/lig-hip-timing-probe.sh` — honest HIP hardware probe stub
- Bench parity builds from repo root and **runs** matmul smoke when `CUDA_HOME` is set
- Tier-3 bench JSON includes NumPy `oracle_mlp_forward` checksum when script succeeds

## Verify

```bash
./scripts/lkir-validate.sh
./scripts/bench-lig-kernel-parity.sh   # validity_gate_pass: true with CUDA
LIG_EMIT_CUDA=1 ./scripts/bench-lig-gpu-suite.sh
```
