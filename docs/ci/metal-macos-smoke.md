# Metal / Apple Silicon smoke (WP-HW-11, M1+)

**Host:** macOS on Apple Silicon (M1, M2, …).  
**Backend:** `lig_backend_metal()` → id **3**; device matmul requires **`LIG_EMIT_METAL=1`**.

## Prerequisites

- Xcode command-line tools (`xcode-select --install`)
- Branch `feat/ph-ml-gpu-swarm` (or newer with `li_rt_lig_metal.mm`)

## Quick verify (recommended)

```bash
cd lic
git pull origin feat/ph-ml-gpu-swarm
./scripts/macos-metal-smoke.sh
```

Expect `metal_device_ok: true`, integer `gpu_timing_ns`, matmul smoke `exit=0`, `li-tests/run_all.sh gpu` pass.

## Manual steps

```bash
export LIG_EMIT_METAL=1
unset CUDA_HOME CUDA_PATH
./scripts/build.sh
lic check packages/lig/li-tests/smoke/lig_device_probe.li
bash scripts/lig-metal-timing-probe.sh
lic build --allow-open-vc packages/lig/li-tests/smoke/kernel_matmul_parity.li -o /tmp/matmul_smoke
/tmp/matmul_smoke   # exit 0
LIG_EMIT_METAL=1 ./scripts/bench-lig-gpu-suite.sh
```

**Expected**

| Check | Value |
|-------|--------|
| `lig_backend_select_auto()` | **3** (Metal) |
| `lig_backend_available(cuda)` | **0** |
| `lig-metal-timing-probe` | `metal_device_ok: true` |
| Bench JSON `status` | `metal_device_pilot` |

## Source layout

| File | Role |
|------|------|
| `runtime/li_rt_lig_metal.mm` | MSL compile-at-runtime + 2×2 dispatch |
| `runtime/kernels/lig_matmul2x2.metal` | Reference MSL (mirrors embedded source) |
| `scripts/lig-metal-timing-probe.sh` | Honest `metal_timing_ns` for bench JSON |

See [hardware-platform-matrix.md](hardware-platform-matrix.md).
