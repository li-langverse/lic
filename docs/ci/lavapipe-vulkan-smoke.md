# Lavapipe Vulkan smoke (WP-HW-07)

**Status:** CI recipe — default `lic` build does **not** link Vulkan.  
**Workflow:** [`.github/workflows/lavapipe-vulkan-smoke.yml`](../../.github/workflows/lavapipe-vulkan-smoke.yml) (PH-ML wave 6).  
**Related:** [CUDA / GPU smoke](cuda-gpu-smoke.md) (WP-HW-09, `CUDA_HOME` probe).

## Goal

In-process SPIR-V header validation (`li_rt_lkir_spirv_validation_smoke`) is **done**.  
**Blocked:** `vkCreateComputePipelines` on lavapipe (headless compute, no swapchain).

## Host prerequisites (Linux CI)

```bash
sudo apt-get install -y libvulkan1 mesa-vulkan-drivers vulkan-tools
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.x86_64.json
export LIG_VULKAN_LAVA=1
```

## CI steps

1. `./scripts/build.sh`
2. `lic check packages/lig/li-tests/smoke/lkir_spirv_stub.li`
3. `lic check packages/lig/li-tests/smoke/kernel_launch_status.li`
4. `LIG_VULKAN_LAVA=1 lic check packages/lig/li-tests/smoke/kernel_matmul_parity.li`
5. Optional: `vulkaninfo --summary | head`
6. **Do not** assert `gpu_timing_ns` — only launch status / stub_ok

## Evidence

| Check | Result |
|-------|--------|
| SPIR-V header smoke | pass (`bid=5` → status `0` stub_ok) |
| `li_rt_lkir_spirv_lavapipe_probe()` | env-gated (`LIG_VULKAN_LAVA`, `VK_ICD_FILENAMES`) |
| Linked Vulkan loader in `libli_rt` | **no** — full dispatch blocked |

**Next WP:** minimal Vulkan compute binary or separate link of loader (WP-HW-07).
