# Release notes: 2026-05-29 — PH-ML de-stub wave 4b

**Status:** Ready for review  
**Branch:** `feat/ph-ml-gpu-swarm`  
**PR:** [#367](https://github.com/li-langverse/lic/pull/367)

## Summary

Wave 4b replaces header-only Vulkan `-1` with SPIR-V validation stub-ok path, adds CPU 2×2 matmul reference when `LIG_EMIT_CUDA` + `CUDA_HOME`, serial 4-env RL batch in-process, WP-GPU-05 Partial verification doc + compile_fail, and encodes stub policy in `ph-ml-stub-then-implement.mdc`.

## Agent continuation

1. Read [PH-ML-GPU-execution-tracker.md](../game-dev/PH-ML-GPU-execution-tracker.md) for `partial` / `blocked` rows.
2. Run verify block below on a machine without GPU — expect `gpu_timing_ns: N/A`.
3. Next: real Vulkan compute dispatch (lavapipe CI), PTX emit, G-gpu Lean proofs.
4. Blocked: timed CUDA/HIP without hardware; full `device[T]` types (WP-GPU-02).

## Stub→Real

| Stub behavior | Real behavior | Verification |
|---------------|---------------|----------------|
| Vulkan `bid=5` → `-1` unavailable | SPIR-V header validate → `0` stub_ok; lavapipe hint via `LIG_VULKAN_LAVA` / `VK_ICD_FILENAMES` | `lic check packages/lig/li-tests/smoke/kernel_launch_status.li` |
| CUDA emit `1`, `ratio=0` | CPU 2×2 ref matmul sets `li_rt_lig_kernel_last_validity_ratio` when `CUDA_HOME` set | `LIG_EMIT_CUDA=1 lic check packages/lig/li-tests/smoke/kernel_matmul_parity.li` |
| `async_env_pool_tick_stub` single worker | 4-slot serial batch `async_env_pool_tick_serial_batch` | `lic check packages/li-ml-rl/li-tests/smoke/async_env_pool_serial.li` |
| WP-GPU-05 doc-only | `gpu_device_type_reserved_compile_fail.li` + [gpu-host-device-alias.md](../verification/gpu-host-device-alias.md) | `lic check li-tests/gpu/gpu_device_type_reserved_compile_fail.li` |
| Bench all `N/A` | JSON reports emit status + host validity from parity | `scripts/bench-lig-gpu-suite.sh` |
| Stub-only WP **done** | Tracker `partial` / `in_progress` with evidence | See tracker diff |

## Verify

```bash
./scripts/build.sh
build/compiler/lic/lic check packages/lig/li-tests/smoke/**
build/compiler/lic/lic check packages/li-ml-rl/li-tests/smoke/**
build/compiler/lic/lic check li-tests/gpu/gpu_device_type_reserved_compile_fail.li
scripts/bench-lig-gpu-suite.sh
```

## Changed

| WP | State after | Evidence |
|----|-------------|----------|
| WP-HW-07 | partial → in_progress | `li_rt_lkir_spirv_*`, `lig_run_vulkan_spirv_path` |
| WP-HW-08/09 | partial → in_progress | CPU ref matmul + emit status `1` |
| WP-RL-04 | stub → in_progress | `async_env_pool_serial.li` |
| WP-GPU-05 | stub → partial | verification doc + compile_fail |
| WP-ML-07/08 | done (documented) | `w1_scale` + full `w2` comment in `nn/lib.li` |
| WP-BENCH-ML-05 | done | bench JSON wave `4b` |

## Not changed

- No `gpu_timing_ns` numeric claims.
- No forked RL worker IPC.
- Agent-kit mirror: `roadmap/agent-kit` manifest 1.3.5 (sibling repo; lic rule lands in this PR).

## Breaking / Security / Performance / Downstream

| | |
|-|-|
| Breaking | N/A — launch status `0` for Vulkan smokes (was `-1`) |
| Security | N/A |
| Performance | N/A — timings remain `N/A` |
| Downstream | Smokes expecting Vulkan `-1` must expect `0` |
