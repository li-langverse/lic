# Release notes: 2026-05-27 — vertical-game-checkpoint-roundtrip

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**Branch:** `cursor/vertical-game-5599`  
**PH / REQ:** PH-GD-2  
**Author:** agent

---

## Summary (one sentence)

PH-GD-2 partial: `li-studio` wires `li-world` checkpoint helpers after game sim steps and adds smoke `studio_game_step_hook.li` covering physics hook + buffer round-trip.

## Agent continuation (required)

1. Read: `packages/li-studio/src/lib.li` (`studio_game_world_checkpoint_*`), `packages/li-world/src/lib.li`, `docs/game-dev/studio-full-implementation-plan.md` WP-GD-02/03.
2. Run: `lic check packages/li-studio/src/lib.li`; `lic check packages/li-studio/li-tests/smoke/studio_game_step_hook.li`.
3. Then: WP-GD-03 — multi-field world text format + scene entity refs; restore checkpoint into physics/scene handles.
4. Blocked on: scene graph sync, filesystem save — **not** in this PR.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| `packages/li-studio/src/lib.li` | `studio_game_entity_count_stub`, `studio_game_world_checkpoint_from_session`, `studio_game_world_checkpoint_stub`, `studio_game_world_checkpoint_roundtrip` | `lic check` |
| `packages/li-studio/li.toml` | path dependency `li-world` | workspace resolve |
| `packages/li-studio/li-tests/smoke/studio_game_step_hook.li` | game step hook + checkpoint after `studio_sim_step_hook` | manifest `compile_open_ok` |
| `packages/li-studio/li-tests/manifest.toml` | register smoke | CI package check |

## Not changed (scope fence)

- Scene graph / entity serialization — **not** implemented.
- Filesystem world save/load — **not** wired.
- `studio_sim_step_by_profile.li` scientific/MD paths — unchanged (game smoke is separate).
- Physics pose restore from checkpoint — **not** in scope.

## Breaking changes

None.

## Security

N/A — in-memory text buffer only (existing `li_rt_world_*` seam); no new trusted I/O.

## Performance

N/A — O(1) text line round-trip scaffold.

## Downstream

| Repo | Action |
|------|--------|
| li-world mirror | sync after merge if publishing separately |
| li-studio mirror | bump when pushed via `push-official-package-repo.sh` |

## CHANGELOG entry (paste into Unreleased)

```markdown
### Added
- **PH-GD-2 game checkpoint roundtrip** — `studio_game_world_checkpoint_roundtrip` in `li-studio`; smoke `studio_game_step_hook.li` — PH-GD-2.
```
