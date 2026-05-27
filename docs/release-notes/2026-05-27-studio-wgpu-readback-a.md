# Release notes: 2026-05-27 — studio-wgpu-readback-a

**Status:** Ready for review (rebased onto `main` 2026-05-27)  
**Repo:** li-langverse/lic  
**PR:** cursor/studio-wgpu-readback-5599  
**PH / REQ:** PH-HW viewport, UX-14 native pixels  
**Author:** agent

---

## Summary (one sentence)

Phase A wgpu readback scaffold: `lig_present_blit_paint_summary` / `present_blit_rgba8` records `native_pixel_source=paint_blit` before host-present compose claims `native_pixels=1`.

## Agent continuation (required)

1. Read: `docs/game-dev/wgpu-readback-path.md`, `packages/lig/present/lib.li`, `docs/game-dev/lig-kernel-catalog.md` (`present_blit_rgba8` row).
2. Run: `LIC=build/compiler/lic/lic ./scripts/lic-workspace-build.sh packages/li.toml` (lig + li-studio); `lic check packages/lig/li-tests/smoke/present_blit_rgba8.li`; with `LIG_HOST_PRESENT=1` run studio vertical native capture scripts.
3. Then: Phase B — wire `li_rt_lig_kernel_run` kid=3 dispatch and in-tree wgpu-rs swapchain readback (`native_pixel_source_wgpu_readback`).
4. Blocked on: wgpu-rs surface in CI images for real GPU readback — **not** required for phase A merge.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| `packages/lig/present/lib.li` | `lig_present_blit_paint_summary`, `native_pixel_source` on `LigPresentFrame`, `lig_kernel_present_blit_rgba8` kid id | `present_blit_rgba8.li` |
| `runtime/li_rt.c` / `li_rt.h` | `li_rt_lig_present_blit_rgba8`, pixel source globals | host-present gate |
| `packages/li-studio/src/lib.li` | Vertical demo requires blit before present; checks `native_pixel_source_paint_blit` | compose path |
| `packages/lig/lkir/blit.lkir` | LKIR stub for kernel catalog | bench registry |
| `li-tests/manifest.toml` | `T-PKG-lig-present-blit` compile_open_ok | manifest row |

## Not changed (scope fence)

- Full wgpu-rs swapchain / texture readback (phase B).
- `li-render` HUD `native_pixels` simulation path (still `lig_present_surface_ok()`).
- LLVM LKIR lowering for `present_blit_rgba8` beyond stub comment file.
- Studio HTML mocks / tier-5 httpd.

## Breaking changes

None — `li_std_lig_present_version` is `2`; callers checking `>= 1` remain valid.

## Security

N/A — trusted runtime edge only; no new `trusted.lean` axioms.

## Performance

N/A — phase A is contract + runtime stub; no bench threshold changes.

## Downstream

| Repo | Action |
|------|--------|
| benchmarks | optional ingest after phase B readback benches |
| li-render / package mirrors | N/A until phase B |

## CHANGELOG entry (paste into Unreleased)

```markdown
### Added
- **PH-HW viewport phase A:** `lig_present_blit_paint_summary` / `present_blit_rgba8` scaffold (`native_pixel_source`); studio vertical demo requires paint blit before host present — [2026-05-27-studio-wgpu-readback-a.md](docs/release-notes/2026-05-27-studio-wgpu-readback-a.md).
```
