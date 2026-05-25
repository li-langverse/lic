# Studio per-vertical examples and demo capture (UX-14)

## Summary

Adds seven World Studio runtime profile examples, HTML marketing mocks with honest banners, `studio_vertical_profile_roundtrip` smoke, and `record-studio-verticals-demo.sh` MP4 capture.

## Agent continuation

1. **Read** — `docs/demo/VERTICALS-RECORDING.md`, `packages/li-studio/examples/verticals/`, `deploy/studio-demo/screenshots/verticals/manifest.json`.
2. **Run** — `lic check packages/li-studio/li-tests/smoke/studio_vertical_profile_roundtrip.li`; `./scripts/record-studio-verticals-demo.sh`.
3. **Next** — Wire `STUDIO_DEMO_PROFILE` into `studio_shell_demo_frame`; splice native `LIG_HOST_PRESENT` frames into MP4 when wgpu surface is stable.
4. **Blocked** — Full domain packs (`li-sim-automotive`, export.print, adaptive drug GUI) remain PH-SIM / PH-GD follow-ups.

## Changed

| Path | Notes |
|------|-------|
| `packages/li-studio/examples/verticals/*/` | `studio.toml` + README per profile |
| `packages/li-studio/li-tests/smoke/studio_vertical_profile_roundtrip.li` | T-PKG-li-studio-vertical-profile-roundtrip |
| `deploy/studio-demo/screenshots/verticals/` | HTML mocks, `manifest.json`, `capture.sh`, `generate-mocks.py` |
| `scripts/record-studio-verticals-demo.sh` | Chrome PNG → ffmpeg MP4 |
| `docs/demo/studio-verticals-demo-script.md` | Voiceover beats |
| `docs/demo/VERTICALS-RECORDING.md` | Honesty matrix |

## Not changed

- `studio_profile_*` id table / runtime `li_rt.c` mapping
- Native wgpu swapchain product capture (still optional present-tick JSON)
- `li-langverse/studio` org repo (sync in follow-up PR if needed)

## Breaking

N/A — additive examples and demo assets.

## Security

N/A — static HTML and local capture scripts only.

## Performance

N/A — no bench threshold changes; optional `deploy/studio-demo/native` tick unchanged.

## Downstream

- **studio** org repo: mirror `examples/verticals` on `feat/studio-vertical-demos` when syncing from lic.
