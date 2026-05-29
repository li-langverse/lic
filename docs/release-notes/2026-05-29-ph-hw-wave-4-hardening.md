# Release notes: 2026-05-29 — PH-HW Wave 4 GPU hardening

**Status:** Ready for review  
**Branch:** `feat/ph-ml-gpu-swarm`  
**PR:** [#367](https://github.com/li-langverse/lic/pull/367)

## Summary

Wave 4 advances the GPU spine with honest host launch status codes, minimal SPIR-V module bytes + validation smoke, CUDA/HIP emit gates, `@gpu` MIR tag + codegen launch prologue (Partial G-gpu), `mlp_forward_f32` LKIR tile, refreshed lig-gpu-suite JSON, and `@gpu` train hook in `ml.dl`.

## Verify

```bash
./scripts/build.sh
build/compiler/lic/lic check packages/lig/li-tests/smoke/**
build/compiler/lic/lic check packages/li-ml/**
lic check li-tests/gpu/gpu_decorator_mir.li
scripts/bench-lig-gpu-suite.sh
```

## Changed

| WP | What |
|----|------|
| WP-HW-06 | `runtime/li_rt_lkir_spirv.c` — SPIR-V header stub; `lkir_spirv_*` wired to runtime |
| WP-HW-08 | `li_rt_lig_kernel_run` returns `-1` unavailable, `-2` emit off, `1` emit stub, `0` ran |
| WP-HW-09/10 | `LIG_EMIT_CUDA=1` / `LIG_EMIT_HIP=1` matmul pilot status |
| WP-GPU-04/06 | `MirDecorator.gpu`, codegen `li_rt_lig_kernel_run` prologue |
| WP-HW-12 | `packages/lig/lkir/mlp_forward_f32.lkir` + catalog row |
| WP-BENCH-ML-05/06 | `bench-lig-gpu-suite.sh` + tier3 ingest stub JSON |
| WP-ML-11 | `dl_forward_gpu_stub` in `ml.dl` |

## Not changed (honesty fence)

- No Vulkan compute dispatch (WP-HW-07).
- No GPU `gpu_timing_ns` — all `N/A`.
- G-gpu proofs remain **Partial**.
