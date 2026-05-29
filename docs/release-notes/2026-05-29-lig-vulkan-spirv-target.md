# Release notes: 2026-05-29 — lig-vulkan-spirv-target

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** branch `cursor/vulkan-spirv-lig-5b3a`  
**PH / REQ:** PH-HW, G-gpu, `lig` backend identity  
**Author:** agent

---

## Summary (one sentence)

`lig` now has an explicit Vulkan/SPIR-V backend identity so Li-owned kernels can target a CUDA-free cross-vendor path before vendor-specific adapters.

## Agent continuation (required)

1. Read: `packages/lig/src/lib.li`, `runtime/li_rt.c`, `packages/lig/li-tests/smoke/vulkan_spirv_backend.li`, and `docs/game-dev/specs/lig-rfc.md`.
2. Run: `./scripts/build.sh`, `build/compiler/lic/lic check packages/lig/li-tests/smoke/vulkan_spirv_backend.li`, and `build/compiler/lic/lic check packages/lig/li-tests/smoke/lig_device_probe.li`.
3. Then: add a Li-owned LKIR -> SPIR-V module emitter and a headless Vulkan shader-module validation smoke.
4. Blocked on: SPIR-V binary emission, Vulkan dispatch/runtime adapter, device-buffer contracts, and multi-GPU scheduler semantics.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| `packages/lig/src/lib.li` | Added `lig_backend_vulkan_spirv()` id `5`, `lig_backend_max()`, `lig_backend_target_supported()`, widened backend contracts to `1..5`, and bumped `li_std_lig_version()` to `3`. | `vulkan_spirv_backend.li` check/build/run passes. |
| Runtime probe | `runtime/li_rt.c` recognizes `vulkan_spirv`, `spirv`, and `vulkan` TOML aliases; non-Apple auto-selection chooses Vulkan/SPIR-V target identity while runtime availability remains `0` until dispatch exists. | `lig_device_probe.li` and `vulkan_spirv_backend.li`. |
| Tests | Added `packages/lig/li-tests/smoke/vulkan_spirv_backend.li`; extended `lig_device_probe.li`. | `packages/lig/li-tests/manifest.toml`. |
| Docs | `lig-rfc.md` and `packages/lig/README.md` now define Vulkan/SPIR-V as Li's cross-vendor kernel target. | Doc paths above. |

## Not changed (scope fence)

- No SPIR-V binary emitter was added.
- No Vulkan driver calls or dispatch runtime were added; backend id `5` is target identity only.
- No CUDA/HIP/Metal codegen changed.
- No GPU benchmark timings or ML/DL/RL kernels changed.

## Breaking changes

Stub behavior change: `lig_kernel_run_auto(...)` now selects the Vulkan/SPIR-V target identity on non-Apple hosts and returns unavailable (`-1`) until SPIR-V dispatch exists. Tests that need the legacy stub runner should call `lig_kernel_run(..., lig_backend_webgpu())` explicitly.

## Security

No new driver calls or trusted vendor runtime entry points were added. The change is a typed backend identity and TOML parse path only; backend id `5` returns unavailable for runtime kernel dispatch until a SPIR-V emitter/dispatcher lands.

## Performance

N/A — no kernel execution path or timing changed.

## Downstream

| Repo | Action |
|------|--------|
| `lig` | Future PH-HW work should target `lig_backend_vulkan_spirv()` for Li-owned kernels before optional vendor adapters; legacy smoke tests should pin explicit backend ids. |
| `benchmarks` | No benchmark row changed; add SPIR-V validation once an emitter exists. |

## CHANGELOG entry (paste into Unreleased)

```markdown
### Added
- **PH-HW Vulkan/SPIR-V target:** `lig` now exposes `lig_backend_vulkan_spirv()` as backend id 5 and treats it as the CUDA-free default target identity for Li-owned kernels before vendor-specific adapters — [2026-05-29-lig-vulkan-spirv-target.md](docs/release-notes/2026-05-29-lig-vulkan-spirv-target.md).
```
