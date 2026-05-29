# Release notes: 2026-05-28 — gpu-decorator-mir

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** branch `cursor/gpu-decorator-mir-5b3a`  
**PH / REQ:** PH-7d, G-gpu, T-decorators-gpu-mir  
**Author:** agent

---

## Summary (one sentence)

`@gpu` and `@gpu(devices=N)` now survive MIR lowering and appear in `lic verify` telemetry, establishing compiler-visible Li GPU placement before LKIR/vendor codegen.

## Agent continuation (required)

1. Read: `compiler/mir/include/li/mir.hpp`, `compiler/mir/lower.cpp`, `compiler/mir/mir.cpp`, `compiler/lic/main.cpp`, `docs/game-dev/specs/lig-rfc.md`, and `docs/verification/provability-gaps.md` (**G-gpu**).
2. Run: `cmake --build build --target lic -j 4`, `./scripts/check-mir-gpu-decorator.sh`, and `LI_REPO_ROOT=$PWD ./li-tests/run_all.sh decorators`.
3. Then: connect MIR `@gpu` placement to a proof-carrying LKIR/catalog launch path in `lig`; add fail tests before any device-buffer/address-space lowering.
4. Blocked on: address-space proofs, LKIR lowering, device-buffer contracts, and backend emitters for CUDA/HIP/Metal/SPIR-V are still open **G-gpu** work.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| MIR | `MirDecorator` now carries `gpu` and `gpu_devices`; `copy_decorators()` records `@gpu` and `@gpu(devices=N)`. | `lic verify li-tests/decorators/gpu_multi_device_ok.li` reports `mir_gpu_proc=1 mir_gpu_multi_device_proc=1`. |
| Verify telemetry | `count_mir_gpu_proc`, `count_mir_gpu_multi_device_proc`, and `lic verify` output expose GPU placement counts. | `./scripts/check-mir-gpu-decorator.sh` exit `0`. |
| Policy | `@gpu(devices=0)`, non-integer `devices`, and vendor/backend arguments are rejected rather than accepted as impossible or vendor-specific placement. | `lic check --format=json li-tests/decorators/gpu_devices_zero_fail.li` returns `E0322` with `gpu_devices`; decorators suite compile-fail rows cover `gpu_devices_ident_fail.li` and `gpu_vendor_arg_fail.li`. |
| Tests | Added `gpu_only_ok.li`, `gpu_multi_device_ok.li`, `gpu_devices_zero_fail.li`, `gpu_devices_ident_fail.li`, `gpu_vendor_arg_fail.li`, and manifest rows. | `LI_REPO_ROOT=$PWD ./li-tests/run_all.sh decorators` exit `0`. |
| Docs | Updated execution decorators, `lig` RFC, and provability gaps to mark G-gpu as partial. | `docs/superpowers/specs/2026-05-16-li-execution-decorators.md`, `docs/game-dev/specs/lig-rfc.md`, `docs/verification/provability-gaps.md`. |

## Not changed (scope fence)

- No CUDA, HIP/ROCm, Metal, Vulkan/wgpu, SPIR-V, or LKIR codegen was added.
- No vendor driver calls, new trusted axioms, device allocation API, or device memory copy path was added.
- No performance numbers or benchmark thresholds changed; `lig` still benchmarks backend/runtime paths separately from compiler placement metadata.
- No multi-GPU scheduler, stream overlap, peer-to-peer copy, or distributed runtime was implemented.

## Breaking changes

N/A — `@gpu(devices=0)` was previously inert/meaningless and is now rejected; valid `@gpu` source remains accepted.

## Security

No new trusted runtime surface was added. Security improvement is static rejection of impossible GPU placement (`devices=0`), non-literal device counts, and source-level vendor strings, plus explicit telemetry so future agents can gate GPU lowering before vendor/runtime calls are introduced.

## Performance

N/A — no GPU execution path or performance claim changed. This PR only adds MIR metadata and verification telemetry.

## Downstream

| Repo | Action |
|------|--------|
| `lig` | Use `mir_gpu_proc` / `mir_gpu_multi_device_proc` as the compiler-side handoff for future LKIR launch work. |
| `benchmarks` | N/A — no benchmark rows changed; future `lig` perf PRs should update `lig-kernels.toml`. |
| `lip` / `lit` / `lis` | N/A — no package manager, test runner, or server API changed. |

## CHANGELOG entry (paste into Unreleased)

```markdown
### Added
- **PH-7d / G-gpu decorator telemetry:** `@gpu` and `@gpu(devices=N)` now survive MIR lowering and `lic verify` reports `mir_gpu_proc` / `mir_gpu_multi_device_proc`; invalid device counts and source-level vendor args are rejected before LKIR/codegen — [2026-05-28-gpu-decorator-mir.md](docs/release-notes/2026-05-28-gpu-decorator-mir.md).
```
