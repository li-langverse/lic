# Studio verticals — recording honesty matrix (UX-14)

| Vertical | Native compose (`lic check`) | User demo MP4 frame | `native_pixels` | `capture_mode` | Not implemented |
|----------|------------------------------|---------------------|-----------------|----------------|-----------------|
| `game` | `studio_vertical_profile_roundtrip`, `studio_shell_demo` | Paint-blit shell (dock/timeline/inspector/viewport) | **1** | `paint_blit` | Full li-player ship loop |
| `sim_rl` | Profile roundtrip + topbar paint | Paint-blit shell + profile chip | **1** | `paint_blit` | Live env stepping / PH-ML pools |
| `sim_automotive` | Profile roundtrip | Paint-blit shell | **1** | `paint_blit` | Maps, sensors, `li-sim-automotive` |
| `sim_robotics` | Inspector rows when `has_selection=1` | Paint-blit shell | **1** | `paint_blit` | IK, factory cells |
| `sim_additive` | TOML `sim_additive` parse | Paint-blit shell | **1** | `paint_blit` | `sim.export.print`, printer profiles |
| `sim_scientific` | Viewport display compose (bg grid, MD tier 10k, cartoon biomol chip) + 3 viewport menu stubs | Paint-blit shell + 8 particle dot placeholders | **1** | `paint_blit` | wgpu MD draw, PDB, real cartoon/surface mesh |
| `sim_drug_design` | Viewport display (gradient bg, MD 1k, surface biomol) + drug LITL inspector | Paint-blit shell (wider inspector) | **1** | `paint_blit` | `studio.adaptive`, `li-chem` live, real 3D biomol |

**Honesty:** `capture_mode=paint_blit` means `studio_shell_paint_fb.c` rasterizes the same region geometry as `studio_paint_shell_chrome` / `layout_studio_shell_adaptive` — not a live `li-studio-demo` window or wgpu swapchain readback. Legacy `cpu_chip_only` (grid + topbar chip only) is available via `STUDIO_VERTICALS_CAPTURE_MODE=cpu_chip_only`.

**User MP4 policy:** native frames only — `deploy/studio-demo/native/studio_verticals_present_host` under `LIG_HOST_PRESENT=1`, or future screen capture of `li-studio-demo`. **No** Chrome headless on HTML mocks (archived under `deploy/studio-demo/archive/verticals-html-mocks/`).

## Commands

```bash
# Smokes (all vertical profile ids)
lic check packages/li-studio/li-tests/smoke/studio_vertical_profile_roundtrip.li

# Native PNGs (requires cc; SDL optional for present tick)
LIG_HOST_PRESENT=1 ./scripts/studio-verticals-capture-native.sh

# MP4 — exits 1 with NO_MP4_NATIVE if capture fails (no HTML fallback)
LIG_HOST_PRESENT=1 ./scripts/record-studio-verticals-demo.sh

# Dry-run
STUDIO_VERTICALS_DRY_RUN=1 ./scripts/record-studio-verticals-demo.sh

# Legacy chip-only frames (honesty regression)
STUDIO_VERTICALS_CAPTURE_MODE=cpu_chip_only ./scripts/studio-verticals-capture-native.sh

# Optional single present tick JSON (SDL when available)
LIG_HOST_PRESENT=1 ./scripts/studio-shell-present-tick.sh
```

## Blocker repro (when `NO_MP4_NATIVE`)

1. Run `LIG_HOST_PRESENT=1 ./scripts/studio-verticals-capture-native.sh` and inspect stderr.
2. Confirm `docs/demo/media/native-verticals/png/game.png` exists and `capture.json` has `"native_pixels": true` and `"capture_mode": "paint_blit"` for game.
3. Common fixes: install `cc`; remove stale `deploy/studio-demo/native/studio_verticals_present_host` binary; rebuild via capture script (compiles `studio_shell_paint_fb.c` + host).
4. On Linux CI without display: CPU framebuffer path does not need Xvfb; SDL present tick may still use `xvfb-run`.

## MP4

- **Path:** `docs/demo/media/studio-verticals-demo.mp4`
- **Frames:** `docs/demo/media/native-verticals/png/{game,sim_*}.png`
- **Scenes:** 7 × 10s + 5s outro (`STUDIO_VERTICAL_SCENE_SEC`)

## Fix roadmap (product capture)

1. Wire `studio_vertical_demo_frame` host readback → PNG from presented wgpu/SDL swapchain (`li-studio-demo`).
2. Replace CPU paint mirror with `RenderReadPixels` once stable on all CI targets.
3. Splice live window capture on macOS/Linux for marketing refresh.
