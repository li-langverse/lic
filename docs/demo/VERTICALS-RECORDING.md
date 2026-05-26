# Studio verticals — recording honesty matrix (UX-14)

| Vertical | Native compose (`lic check`) | User demo MP4 frame | `native_pixels` | Not implemented |
|----------|------------------------------|---------------------|-----------------|-----------------|
| `game` | `studio_vertical_profile_roundtrip`, `studio_sim_step_by_profile` (physics + replay + world stub) | CPU present host chip (cyan, h=21) | **1** | Full li-player ship loop, scene sync |
| `sim_rl` | Profile roundtrip + `env_pool_stub` + `studio_sim_step_by_profile` (4× step) | Present host (mint, h=22) | **1** | Async parallel env pools / live training |
| `sim_automotive` | Bicycle kinematics `(x,y,yaw,v)` + sensor placeholder spec; `sim_automotive_tick_at` in `studio_sim_step_hook` | Present host (amber, h=23) | **1** | HD maps, raycast lidar, CARLA-class sim |
| `sim_robotics` | 2-DOF FK + torque-limited integration + `robo_workspace` bounds; `sim_robotics_tick_at` | Present host (amber, h=24) | **1** | IK, Gazebo/Isaac, factory cells, ROS2 |
| `sim_additive` | Layer slice plan (mesh→layers×4 path pts) + `sim_additive_require_sim_pass_ok` | Present host (amber, h=25) | **1** | `sim.export.print`, live printer send |
| `sim_scientific` | Tier labels + `scientific_tick_tiers` (MD/heat/rigid smokes) | Present host (amber, h=26) | **1** | CFD/MD oracles, `sim.viz`, full SimWorld |
| `sim_drug_design` | LITL composable + violet chip + tick stub | Present host (violet, h=27) | **1** | live `studio.adaptive`, ORCA/Psi4 queue |

**User MP4 policy:** native frames only — `deploy/studio-demo/native/studio_verticals_present_host.c` under `LIG_HOST_PRESENT=1`, or future screen capture of `li-studio-demo`. **No** Chrome headless on HTML mocks (archived under `deploy/studio-demo/archive/verticals-html-mocks/`).

**CPU present (CI / headless):** `STUDIO_CPU_PRESENT=1` with optional `LIG_HOST_PRESENT=1` uses the CPU framebuffer path when SDL `STUDIO_SHELL_PRESENT_HOST_BIN` is unset (`runtime/li_rt.c`).

## Commands

```bash
# Smokes (all vertical profile ids)
lic check packages/li-studio/li-tests/smoke/studio_vertical_profile_roundtrip.li
lic check packages/li-studio/li-tests/smoke/studio_sim_step_by_profile.li
./scripts/check-automotive-bench.sh
./scripts/check-robotics-bench.sh
./scripts/check-additive-bench.sh

# Native PNGs (requires cc; SDL optional for present tick)
LIG_HOST_PRESENT=1 ./scripts/studio-verticals-capture-native.sh

# MP4 — exits 1 with NO_MP4_NATIVE if capture fails (no HTML fallback)
LIG_HOST_PRESENT=1 ./scripts/record-studio-verticals-demo.sh

# Dry-run
STUDIO_VERTICALS_DRY_RUN=1 ./scripts/record-studio-verticals-demo.sh

# Optional single present tick JSON (SDL when available)
LIG_HOST_PRESENT=1 ./scripts/studio-shell-present-tick.sh
```

## Blocker repro (when `NO_MP4_NATIVE`)

1. Run `LIG_HOST_PRESENT=1 ./scripts/studio-verticals-capture-native.sh` and inspect stderr.
2. Confirm `docs/demo/media/native-verticals/png/game.png` exists and `capture.json` has `"native_pixels": true`.
3. Common fixes: install `cc`; remove stale `deploy/studio-demo/native/studio_verticals_present_host` binary; rebuild via `native-sdl-build.sh`.
4. On Linux CI without display: CPU framebuffer path does not need Xvfb; SDL present tick may still use `xvfb-run`.

## MP4

- **Path:** `docs/demo/media/studio-verticals-demo.mp4`
- **Frames:** `docs/demo/media/native-verticals/png/{game,sim_*}.png`
- **Scenes:** 7 × 10s + 5s outro (`STUDIO_VERTICAL_SCENE_SEC`)

## Fix roadmap (product capture)

1. Wire `STUDIO_DEMO_PROFILE` into `studio_shell_demo_frame` → wgpu/SDL swapchain pixels from `li-studio-demo`.
2. Replace CPU framebuffer stub with `studio_shell_present_host` SDL readback once stable on all CI targets.
3. Splice live window capture on macOS/Linux for marketing refresh.
