# Release notes: 2026-05-27 — ph-am-slicer-workflow

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** (pending)  
**PH / REQ:** PH-AM, WP-AM-01  
**Author:** agent

---

## Summary (one sentence)

Deepens `li-sim-additive` with PH-AM AM-0 slicer workflow stage gates (slice → preview → export), `require_sim_pass` export gate, and package/composable smokes.

## Agent continuation (required)

1. Read: `docs/game-dev/specs/li-sim-additive-rfc.md`, `packages/li-sim-additive/src/lib.li`
2. Run: `./build/compiler/lic/lic check packages/li-sim-additive/li-tests/smoke/slicer_workflow.li`
3. Then: WP-AM-02 thermal `require_sim_pass` witness tied to tier-2 heat; WP-AM-03 `sim.export.print` 3MF/G-code
4. Blocked on: PH-SCI-2 heat tier-2 for real thermal gate (not composable-only)

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| `packages/li-sim-additive/src/lib.li` | AM-0 slicer stages, export format ids, `run_additive_slicer_workflow`, version bump to 2 | `lic check` green |
| `packages/li-sim/src/lib.li` | `algo_am_slice_layers` / `algo_am_thermal_warp` / `algo_am_export_gcode_3mf` (601–610 registry) | composable imports resolve |
| Smokes | `slicer_workflow.li`, `import_sim_additive_slicer_workflow.li` | `lic check` exit 0 |

## Not changed (scope fence)

- Thermal/warp simulation kernels (WP-AM-02) — **not** in this PR
- `sim.export.print` printer I/O (WP-AM-03) — **not** in this PR
- Studio export wizard UI (PH-UX) — **not** in this PR
- Compiler / Lean / tier-1 benches — **not** in this PR

## Breaking changes

None — additive API; `li_sim_additive_version()` returns 2 (smoke updated).

## Security

N/A — no trusted FFI or export I/O in this stub workflow.

## Performance

N/A — composable stage stubs only; no bench oracle row.

## Downstream

| Repo | Action |
|------|--------|
| li-sim-additive mirror | sync after merge via `push-official-package-repo.sh` |
| lip / lit / lis | N/A |

## CHANGELOG entry (paste into Unreleased)

```markdown
### Added
- **PH-AM AM-0:** slicer workflow stages in `li-sim-additive` (slice/preview/export gates, `run_additive_slicer_workflow`) — [2026-05-27-ph-am-slicer-workflow.md](docs/release-notes/2026-05-27-ph-am-slicer-workflow.md).
```
