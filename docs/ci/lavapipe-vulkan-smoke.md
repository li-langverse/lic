# Lavapipe Vulkan smoke (WP-HW-07 blocker)

**Status:** Advisory CI — [lavapipe-vulkan-smoke.yml](../../.github/workflows/lavapipe-vulkan-smoke.yml) runs SPIR-V launch smokes with Mesa ICD; default `lic` build does **not** link Vulkan compute.  
**Tracker:** WP-HW-07 **partial** — `li_rt_lkir_vulkan_compute_symbols_ok()` proves dlopen symbols; **blocked** until real `vkCreateComputePipelines` dispatch (job proves env + status `0` only).

## Goal

Headless SPIR-V module validation (`li_rt_lkir_spirv_validation_smoke`) is **done** in-process.  
**Partial (Wave 6):** `li_rt_lkir_vulkan_compute_symbols_ok()` after loader open.  
**Blocked:** `vkCreateComputePipelines` dispatch on lavapipe (no swapchain).

## Host prerequisites (Linux CI)

```bash
sudo apt-get install -y libvulkan1 mesa-vulkan-drivers
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.x86_64.json
export LIG_VULKAN_LAVA=1
export LIG_VULKAN_LAVAPIPE=1  # Wave 5b alias
```

## CI workflow steps (`lavapipe-vulkan-smoke.yml`)

1. Install `libvulkan1` + `mesa-vulkan-drivers` + `vulkan-tools`; set `VK_ICD_FILENAMES` + `LIG_VULKAN_LAVA=1`
2. `./scripts/build.sh`
3. `lic check` on `kernel_launch_status`, `kernel_matmul_parity`, `lkir_spirv_stub`
4. Optional `vulkaninfo` artifact
5. **Do not** assert `gpu_timing_ns` — in-process SPIR-V validation only (WP-HW-07 still **blocked** for compute)

## Evidence (2026-05-29 agent)

| Check | Result |
|-------|--------|
| SPIR-V header smoke | pass (`bid=5` → status `0`) |
| `li_rt_lkir_spirv_lavapipe_probe()` | env-gated only |
| `li_rt_lkir_vulkan_compute_symbols_ok()` | pass when `libvulkan` installed |
| Linked Vulkan compute pipeline in `libli_rt` | **no** — dispatch blocked |

**Next WP:** link minimal Vulkan compute smoke binary or CI job separate from default `build.sh`.
