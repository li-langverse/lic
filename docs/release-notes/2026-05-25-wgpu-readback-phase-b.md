# wgpu readback phase B scaffold (vertical gap #2)

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** feat/wgpu-readback-phase-b → main  
**PH / REQ:** PH-HW HW-1, vertical gap #2 (after #288 phase A)  
**Author:** agent

---

## Summary (one sentence)

Scaffolds `native_pixel_source=3` with `LIG_WGPU_READBACK=0` default and an honest runtime stub (`li_rt_lig_wgpu_readback_rgba8` returns `0`); documents phase B+1 wgpu-rs checklist — full GPU readback is **N/A** in this PR.

## Agent continuation

1. **Read:** `docs/game-dev/wgpu-readback-phase-b.md`, `docs/game-dev/wgpu-readback-path.md`, `runtime/li_rt.c` (`li_rt_lig_wgpu_readback_rgba8`), `packages/lig/present/lib.li`.
2. **Run:** `lic check packages/lig/li-tests/smoke/wgpu_readback_stub.li`; `LIG_WGPU_READBACK=1 lic check packages/lig/li-tests/smoke/wgpu_readback_stub.li` (still expects exit 0 until crate).
3. **Then:** After #288 merges, rebase; phase B+1 adds `wgpu` crate + surface readback; wire `studio_vertical_demo_frame` to call `lig_present_wgpu_readback_rgba8` when gate on.
4. **Blocked on:** in-tree `wgpu-rs` dependency policy and SDL window-handle FFI — **human/PH-HW** before enabling real readback.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| Runtime | `LIG_WGPU_READBACK` gate; `li_rt_lig_host_native_pixel_source`; `li_rt_lig_wgpu_readback_rgba8` stub | `runtime/li_rt.c`, `runtime/li_rt.h` |
| lig.present | `lig_native_pixel_source_wgpu_readback`, `lig_present_wgpu_readback_rgba8`, `LigPresentFrame.native_pixel_source` | `packages/lig/present/lib.li` v2 |
| Smoke | `wgpu_readback_stub.li` | `packages/lig/li-tests/manifest.toml` `T-PKG-lig-wgpu-readback-stub` |
| Docs | Phase B checklist + path taxonomy | `docs/game-dev/wgpu-readback-phase-b.md`, `wgpu-readback-path.md` |
| Catalog | `lig.kernel.present_wgpu_readback_rgba8` | `lig-kernel-catalog.md`, `lig-kernels.toml`, `lkir/readback.lkir` |

## Not changed

- Full **wgpu-rs** swapchain readback implementation — N/A this session.
- Phase A **`present_blit_rgba8`** / `native_pixel_source=2` — lives in PR #288, not required for stub smoke.
- `studio_verticals_present_host.c` MP4 capture binary.
- `li-studio-demo` SDL window splice and aarch64 native CI readback row.

## Breaking changes

None — additive runtime export and present API version bump (`li_std_lig_present_version` 1 → 2).

## Security

N/A — no new `system()` paths; readback stub does not load untrusted GPU shaders.

## Performance

N/A — stub is O(1) env check; no bench row until wgpu-rs lands.

## Downstream

| Repo | Action |
|------|--------|
| benchmarks | Optional dashboard row after real readback — N/A |
| studio / li-render | Call `lig_present_wgpu_readback_rgba8` after #288 + wgpu crate — follow-up PR |

## CHANGELOG entry (paste into Unreleased)

```markdown
### Added
- **wgpu readback phase B (scaffold):** `LIG_WGPU_READBACK=0` gate, `native_pixel_source=3` stub, phase B checklist — [2026-05-25-wgpu-readback-phase-b.md](docs/release-notes/2026-05-25-wgpu-readback-phase-b.md).
```
