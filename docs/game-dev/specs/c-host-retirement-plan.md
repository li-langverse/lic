# C-host retirement plan (WP-UX-14b / WP-GD-05)

**Status:** IN_PROGRESS — step 1–3 landed on plan-loop branch; step 4 (delete C hosts) pending `li-studio-demo` without paint_blit  
**Policy:** [li-native-li-only.mdc](../../../.cursor/rules/li-native-li-only.mdc)

## Current C hosts (`deploy/studio-demo/native/`)

| File | Role | Li/wgpu replacement |
|------|------|---------------------|
| `studio_verticals_present_host.c` | CPU framebuffer per-vertical profile chips for MP4 frames | `lig` wgpu present + `RenderReadPixels` readback; `li-studio-demo` swapchain |
| `studio_shell_present_host.c` | SDL present tick for shell demo | `lig.present` host tick (already partially wired in `li-studio`) |
| `studio_viewport_capture.c` | SDL grid/particle viewport capture stub | `li-render` wgpu viewport smoke + tier-2 sim particles in Li |
| `studio_shell_input_probe.c` | Input probe for shell demos | `InputState` via Li runtime poll or `lig` window queue |
| `capture.sh`, `input_capture.sh`, `native-sdl-build.sh` | Build/capture scripts | Li-native capture scripts only |

**On `feat/studio-real-implementation` (PR #356, not on main yet):**

| File | Role | Replacement |
|------|------|-------------|
| `studio_shell_paint_fb.c` | paint_blit framebuffer for vertical demos | `li-render` blit paint summary → swapchain (Li path) |

## Retirement steps

| Step | Deliverable | Replaces | Depends on |
|------|-------------|----------|------------|
| 1 | `lig` wgpu present + `RenderReadPixels` readback (#342/#346 extended) | `studio_viewport_capture.c` grid path | PR **#356** merged |
| 2 | `li-render` blit paint summary → swapchain | `studio_shell_paint_fb.c` (branch) | Step 1 |
| 3 | `InputState` from Li poll / `lig` events | `studio_shell_input_probe.c` | Step 2 |
| 4 | Delete C paint/present hosts; update capture scripts | all rows above | Steps 1–3 |

## Scope fence (grandfathered until Step 4)

These C files are **temporary product fences** — do not extend with new features:

- `studio_verticals_present_host.c`
- `studio_shell_present_host.c`
- `studio_viewport_capture.c`
- `studio_shell_input_probe.c`
- `studio_shell_paint_fb.c` (when #356 lands)

New pixel paths: `packages/li-studio` + `packages/li-render` + `lig.present` only.

## Timeline

| When | Milestone |
|------|-----------|
| Prerequisite | PR #356 merged to `main` |
| +1 week | Step 1 readback path green on Linux + macOS CI |
| +2 weeks | Steps 2–3 |
| +1 week | Step 4 deletion + script updates |

## Verification

```bash
lic build packages/li-studio/src/main.li -o build/li-studio-demo
lic check packages/li-studio/li-tests/smoke/studio_vertical_profile_roundtrip.li
LIG_HOST_PRESENT=1 ./build/li-studio-demo
```

Exit: no product C under `deploy/studio-demo/native/` except harness scripts documented as build-only.
