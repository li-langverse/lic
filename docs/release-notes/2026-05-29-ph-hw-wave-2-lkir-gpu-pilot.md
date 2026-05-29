# PH-HW Wave 2 — LKIR + Vulkan/SPIR-V target pilot

**Date:** 2026-05-29  
**Branch:** `feat/ph-ml-gpu-swarm`

## Summary

Wave 2 lands the GPU spine stubs: LKIR syntax doc + matmul module, `lig_backend_vulkan_spirv()` (id 5), runtime probe/auto-select, honest kernel dispatch (`bid==5` → `-1`), `LIG_EMIT_CUDA` gate for CUDA, lig smokes, and `@gpu` parse smoke.

## Verify

```bash
./scripts/build.sh
build/compiler/lic/lic check --no-cache packages/lig/li-tests/smoke/vulkan_spirv_backend.li
build/compiler/lic/lic check --no-cache packages/lig/li-tests/smoke/lkir_parser.li
build/compiler/lic/lic check --no-cache packages/lig/li-tests/smoke/kernel_matmul_parity.li
build/compiler/lic/lic check --no-cache li-tests/gpu/gpu_decorator_parse.li
./scripts/bench-lig-gpu-suite.sh
```

## Not in this wave

- SPIR-V codegen / Vulkan dispatch (WP-HW-06) — `gpu_timing_ns` remains `N/A`
- `@gpu` MIR lowering (G-gpu)
