# Release notes: 2026-05-27 — wgpu-readback-phase-b

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** cursor/wgpu-readback-phase-b-5599  
**PH / REQ:** PH-HW viewport, UX-14 native pixels  
**Author:** agent

---

## Summary (one sentence)

Phase B wgpu readback scaffold: `LIG_WGPU_READBACK=1` selects `lig_present_wgpu_readback_paint_summary` / `native_pixel_source_wgpu_readback` (stub) before host present; kid=4 kernel dispatch; studio exit codes 54/55.

## Agent continuation (required)

1. Read: `docs/game-dev/wgpu-readback-path.md`, `packages/lig/present/lib.li`, `runtime/li_rt.c` (`li_rt_lig_wgpu_readback_stub`).
2. Run: `LIC=build/compiler/lic/lic ./scripts/lic-workspace-build.sh packages/li.toml`; `lic check packages/lig/li-tests/smoke/present_wgpu_readback_stub.li`; `LIG_HOST_PRESENT=1 LIG_WGPU_READBACK=1` studio vertical smokes.
3. Then: in-tree wgpu-rs swapchain readback (real GPU texture → CPU RGBA8) — replace stub globals.
4. Blocked on: wgpu-rs surface in CI images for real GPU readback — **not** required for phase B scaffold merge.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| `runtime/li_rt.c` / `li_rt.h` | `li_rt_lig_wgpu_readback_stub`, `li_rt_lig_wgpu_readback_active`, `LIG_WGPU_READBACK` | stub sets source 3 |
| `runtime/li_rt_lig.c` | `li_rt_lig_kernel_run` kid 3 blit, kid 4 readback | kernel bench path |
| `packages/lig/present/lib.li` | `lig_present_wgpu_readback_paint_summary`, blit fallthrough | `present_wgpu_readback_stub.li` |
| `packages/li-studio/src/lib.li` | readback branch in `studio_vertical_demo_frame`; exit 54/55 | host-present gate |
| `li-tests/manifest.toml` | `T-PKG-lig-present-wgpu-readback` | manifest row |
| `docs/game-dev/wgpu-readback-path.md` | Phase B scaffold status + env table | doc |

## Not changed (scope fence)

- Real wgpu-rs swapchain / texture readback (phase B future).
- `trusted.lean` axioms.
- LLVM LKIR lowering beyond existing `blit.lkir` stub.
- Benchmark threshold / dashboard ingest.

## Breaking changes

None — `li_std_lig_present_version` remains `2`.

## Security

N/A — trusted runtime edge only; no new `trusted.lean` axioms.

## Performance

N/A — stub only; no bench threshold changes.

## Downstream

| Repo | Action |
|------|--------|
| benchmarks | optional row after real readback benches land |
| li-render | N/A until swapchain readback |

## CHANGELOG entry (paste into Unreleased)

```markdown
- **PH-HW viewport phase B:** `LIG_WGPU_READBACK=1` wgpu readback present stub (`native_pixel_source=3`, kid=4); studio vertical demo exit 54/55 — [2026-05-27-wgpu-readback-phase-b.md](docs/release-notes/2026-05-27-wgpu-readback-phase-b.md).
```
