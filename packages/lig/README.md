# lig

Li GPU **device layer** (PH-HW **HW-0**): backend identifiers, runtime probe via `li_rt_lig_*`, TOML `backend` line parsing, and wgpu compile-time smoke.

## API

| Symbol | Role |
|--------|------|
| `lig_device_kind()` | Selected backend id (1=cuda, 2=rocm, 3=metal, 4=webgpu) |
| `lig_backend_available(id)` | 1 if env/platform probe sees the backend |
| `lig_backend_select_auto()` | Pick metal/rocm/cuda/webgpu and update selection |
| `lig_capability_json()` | JSON probe snapshot for agents/bench |
| `lig_parse_toml_backend_line(line)` | Parse `[engine.lig] backend = "cuda\|rocm\|metal\|webgpu"` (legacy `[engine.gpu]` one release) |
| `lig_present_surface_ok()` | Honest native surface flag (0 until wgpu-rs presents) |
| `lig_wgpu_smoke_run()` | Smoke struct with `surface_ok = lig_present_surface_ok()` |

## TOML

```toml
[engine.lig]
backend = "webgpu"   # cuda | rocm | metal | webgpu

# legacy (one release):
[engine.gpu]
backend = "metal"
```

## Bench

- `bench/device_probe.toml` — hook for `./scripts/bench-studio-viewport-perf.sh`
- Smoke: `li-tests/smoke/lig_device_probe.li`

## Verify

```bash
lic check packages/lig/li-tests/smoke/lig_device_probe.li
# lig (`import lig.present`)

PH-HW **HW-1** — swapchain create and present frame contracts for World Studio viewport.

## Trusted FFI edge

| Symbol | Role |
|--------|------|
| `li_rt_lig_wgpu_swapchain_create` | wgpu/SDL surface init (host) or stub `surface_ok=0` |
| `li_rt_lig_wgpu_present_frame` | Present one frame; sets `native_pixels` when host active |
| `li_rt_lig_host_present_active` | `1` on **aarch64-apple-darwin** with `LIG_HOST_PRESENT=1`, else `0` |
| `li_rt_lig_host_present_dt_ms` | Wall-clock ms for FPS counter (not simulate-only) |
| `li_rt_lig_host_native_pixels` | `1` after successful host present |

Implementations live in `runtime/li_rt.c`. Native SDL+Metal path: `deploy/studio-demo/native/studio_shell_present_host.c`.

**Out of scope (WP3):** LKIR kernels, VRAM budgets, full wgpu-rs crate.

## Bench

`bench/wgpu_smoke.toml` — consumed by `scripts/bench-studio-viewport-perf.sh` (prefer over `packages/li-gpu/bench/wgpu_smoke.toml`).

## Smokes

```bash
lic check packages/lig/li-tests/smoke/wgpu_smoke.li
lic check packages/li-render/li-tests/smoke/viewport_fps_counter.li
```
