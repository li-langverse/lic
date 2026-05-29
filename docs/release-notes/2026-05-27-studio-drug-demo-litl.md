# Release notes: 2026-05-27 — studio-drug-demo-litl

## Summary

`studio_vertical_demo_frame` and `studio_shell_demo_frame` now compose sim_drug_design (profile 7) via `studio_compose_shell_drug_litl` so native vertical capture and paint blit use the adaptive LITL inspector layout.

## Agent continuation

1. **Read:** `packages/li-studio/src/lib.li` (`studio_vertical_demo_frame`), `docs/game-dev/wgpu-readback-path.md`.
2. **Run:** `lic check packages/li-studio/li-tests/smoke/studio_drug_demo_frame.li`; `STUDIO_DEMO_PROFILE=7 ./build/li-studio-demo` (if built); `scripts/studio-verticals-capture-native.sh` with present host.
3. **Next:** wgpu readback #342; optional C host tick arg if capture needs non-zero LITL stage without Li frame_id.
4. **Blocked:** Real `studio.adaptive` panel IR — layout rects only.

## Changed

| Area | What | Evidence |
|------|------|----------|
| Demo compose | Drug profile branches to `studio_compose_shell_drug_litl(1280, 720, frame_id, 1)` | `packages/li-studio/src/lib.li` |
| Smoke | `studio_drug_demo_frame.li` frames 0–2 + wider inspector at tick 2 | `packages/li-studio/li-tests/manifest.toml` |
| Capture script | Comment: profile 7 uses LITL adaptive layout via Li `frame_id` | `scripts/studio-verticals-capture-native.sh` |

## Not changed

- `lig_present_blit_paint_summary` / `li_rt_lig_present_blit_rgba8` contract (viewport from `gui_viewport_region_from_layout`; tag_h 27 for profile 7)
- Non-drug vertical demo compose (`studio_compose_shell_palette`)
- wgpu swapchain readback (#342)
- `sim.drug_design` chemistry payloads

## Breaking

N/A — demo path only; public API unchanged.

## Security

N/A — no trusted surface change.

## Performance

N/A — same paint/chrome path; drug layout widens inspector (narrows viewport region for blit dims unchanged at 1280×720 gate).

## Downstream

| Repo | Action |
|------|--------|
| benchmarks / demo PNGs | Re-run `studio-verticals-capture-native.sh` for `sim_drug_design.png` when present host available |
| N/A | — |

## CHANGELOG entry (paste into Unreleased)

```markdown
### Added
- **Studio drug vertical demo:** `studio_vertical_demo_frame` uses `studio_compose_shell_drug_litl` for profile 7 — [2026-05-27-studio-drug-demo-litl.md](docs/release-notes/2026-05-27-studio-drug-demo-litl.md).
```
