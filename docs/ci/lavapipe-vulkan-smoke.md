# Lavapipe Vulkan smoke (WP-HW-07 blocker)

**Status:** CI recipe only — default `lic` build does **not** link Vulkan.  
**Tracker:** WP-HW-07 **blocked** until compute pipeline + this job land.

## Goal

Headless SPIR-V module validation (`li_rt_lkir_spirv_validation_smoke`) is **done** in-process.  
**Blocked:** `vkCreateComputePipelines` dispatch on lavapipe (no swapchain).

## Host prerequisites (Linux CI)

```bash
sudo apt-get install -y libvulkan1 mesa-vulkan-drivers
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.x86_64.json
export LIG_VULKAN_LAVA=1
export LIG_VULKAN_LAVAPIPE=1  # Wave 5b alias
```

## Planned CI steps (`.github/workflows` follow-up)

1. `lic check packages/lig/li-tests/smoke/kernel_launch_status.li`
2. `LIG_VULKAN_LAVA=1 lic check packages/lig/li-tests/smoke/kernel_matmul_parity.li`
export LIG_VULKAN_LAVAPIPE=1  # Wave 5b alias
3. Optional: `vulkaninfo | head` artifact when ICD present
4. **Do not** assert `gpu_timing_ns` — only launch status `0` (stub_ok)

## Evidence (2026-05-29 agent)

| Check | Result |
|-------|--------|
| SPIR-V header smoke | pass (`bid=5` → status `0`) |
| `li_rt_lkir_spirv_lavapipe_probe()` | env-gated only |
| Linked Vulkan loader in `libli_rt` | **no** — dispatch blocked |

**Next WP:** link minimal Vulkan compute smoke binary or CI job separate from default `build.sh`.
