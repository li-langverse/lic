# Release notes: 2026-05-29 — lig-gpu-suite-rtx3060

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** branch `cursor/gpu-benchmark-suite-5b3a`  
**PH / REQ:** PH-HW, `lig`, benchmark honesty  
**Author:** agent

---

## Summary (one sentence)

`lig` now has a GPU suite snapshot harness that reports visible NVIDIA hardware, enumerates every cataloged `lig.kernel.*` row, and records that CUDA timing is blocked until Li LKIR backend emit exists.

## Agent continuation (required)

1. Read: `scripts/bench-lig-gpu-suite.sh`, `benchmarks/competitive/lig-kernels.toml`, `benchmarks/results/lig-gpu-suite-latest.json`, and `docs/game-dev/specs/lig-rfc.md`.
2. Run: `./scripts/build.sh`, then `./scripts/bench-lig-gpu-suite.sh`.
3. Then: implement one proof-carrying LKIR -> CUDA pilot kernel, preferably `lig.kernel.matmul_f32`, before adding real GPU timing claims.
4. Blocked on: Li LKIR lowering, CUDA/HIP/Metal emit, device-buffer contracts, and a validity oracle that executes on device.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| GPU harness | Added `scripts/bench-lig-gpu-suite.sh` to record `nvidia-smi` hardware, run available `lig` checks, and emit whole-catalog JSON. | `./scripts/bench-lig-gpu-suite.sh` writes `benchmarks/results/lig-gpu-suite-latest.json`. |
| Benchmark scope | Added `lig` to `benchmarks/manifest.toml` with `lig_gpu_suite`, `lig_kernels`, and `lig_device_probe` hooks. | `benchmarks/manifest.toml`. |
| Scoped hook runner | `benchmarks/harness/bench_sim.py` now runs `lig_gpu_suite`, `lig_kernels`, and `lig_device_probe`, and fails on unknown hook IDs. | `python3 benchmarks/harness/bench_scope.py --package lig`; `./scripts/bench-package.sh lig --skip-verify`. |
| Result snapshots | Committed `benchmarks/results/lig-gpu-suite-latest.json`; refreshed `benchmarks/results/lig-lkir-matmul.json` with whole-catalog status, `lic_build_elapsed_sec`, and binary-run status. | RTX 3060 snapshot: 14 kernels, 0 CUDA-ready, 1 Li smoke binary passed, 13 blocked on LKIR/CUDA emit. |
| Results docs | Documented the `lig` GPU suite output and honesty policy. | `benchmarks/results/README.md`. |
| Changelogs | Noted the PH-HW GPU suite under root `CHANGELOG.md` and `packages/lig/CHANGELOG.md`. | `CHANGELOG.md`, `packages/lig/CHANGELOG.md`. |

## Not changed (scope fence)

- No CUDA, HIP/ROCm, Metal, Vulkan/wgpu, or SPIR-V kernel emitter was added.
- No new C/C++ kernel helper was added.
- No GPU performance speedup is claimed; CUDA timing rows are explicitly unavailable.
- No ML, deep learning, or RL package implementation was added.

## Breaking changes

N/A — benchmark harness addition only.

## Security

No new trusted vendor calls were added beyond invoking `nvidia-smi` for hardware reporting. The suite avoids source-level vendor kernels and records missing emitters instead of running opaque helper code. The `kernel_matmul_parity` smoke is recorded with `allow_open_vc=true` and `lean_verify=skipped`, so it is not represented as a strict proof certificate.

## Performance

No GPU timing claim yet. On the local run, the machine reported NVIDIA GeForce RTX 3060, driver 550.163.01, 12288 MiB VRAM, compute capability 8.6; all catalog CUDA execution rows remain blocked on LKIR backend emit. The ML status object reports `mlp_forward` cataloged but blocked, deep-learning training not timed, RL GPU batching not timed, and agent AI limited to Studio/MCP stubs.

## Downstream

| Repo | Action |
|------|--------|
| `benchmarks` dashboard | Can ingest `benchmarks/results/lig-gpu-suite-latest.json` after dashboard support is added. |
| `lig` | Use this harness as the acceptance target for the first real LKIR -> CUDA pilot. |

## CHANGELOG entry (paste into Unreleased)

```markdown
### Added
- **PH-HW lig GPU suite:** `scripts/bench-lig-gpu-suite.sh` records RTX-class GPU hardware via `nvidia-smi`, enumerates `benchmarks/competitive/lig-kernels.toml`, and writes `benchmarks/results/lig-gpu-suite-latest.json` with honest LKIR/CUDA blockers — [2026-05-29-lig-gpu-suite-rtx3060.md](docs/release-notes/2026-05-29-lig-gpu-suite-rtx3060.md).
```
