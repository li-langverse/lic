# Release notes: 2026-05-25 — sim-replay-sim2-stub

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**Branch:** `feat/gap-sim2-replay` → PR into `main`  
**PH / REQ:** PH-SIM SIM-2  
**Author:** agent

---

## Summary (one sentence)

PH-SIM SIM-2 adds deterministic replay stubs `sim_checkpoint_tick` and `sim_replay_from_tick` on `SimSessionStub` (tick counter restore only; no physics buffer).

## Agent continuation (required)

1. Read: `packages/li-sim/src/lib.li` (SIM-2 block), `docs/game-dev/specs/li-engine-unified-sim-rfc.md`, `packages/li-studio/src/lib.li` (`studio_sim_step_hook`).
2. Run: `lic check packages/li-sim/src/lib.li`; `lic check packages/li-sim/li-tests/smoke/sim_replay_stub.li`.
3. Then: PH-SIM SIM-3 — wire `ml.rl.EnvPool` to `sim_step` per unified-sim RFC; optional Studio timeline hook calling `sim_replay_from_tick`.
4. Blocked on: `SimWorld` state buffers, `li-physics-runtime` integrators, lis MCP tick persistence — **none** for this merge.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| `packages/li-sim` | `sim_checkpoint_tick`, `sim_replay_from_tick`, `sim_status_invalid_tick`, `checkpoint_at` | `li-tests/smoke/sim_replay_stub.li` |
| `docs/game-dev/specs/li-engine-unified-sim-rfc.md` | SIM-2 API + lib/smoke pointers | RFC phase line |
| `docs/release-notes/2026-05-25-sim-replay-sim2-stub.md` | this file | agent continuation |

## Not changed (scope fence)

- Physics / entity / `SimWorld` snapshot buffers — **not** implemented.
- `studio_*` replay timeline hook — **not** wired (Studio still uses SIM-1 step hook only).
- `ml.rl.EnvPool` → `sim_step` (SIM-3) — **not** implemented.
- LLVM / httpd / tier5 / `li-physics-runtime` — **not** touched.

## Breaking / Security / Performance / Downstream

- **Breaking:** None — new `checkpoint_at` defaults to `-1`; existing `SimSessionStub` literals gain one field with default initializer path via `sim_session_stub_default`.
- **Security:** N/A — in-memory int fields, no I/O.
- **Performance:** N/A — O(1) tick assign per replay.
- **Downstream:** Studio deterministic replay can call `sim_replay_from_tick` after checkpointing; full world rewind waits on `SimWorld` buffers.

## CHANGELOG entry (paste into Unreleased)

```markdown
### Added
- **PH-SIM SIM-2 replay stub** — `sim_checkpoint_tick` / `sim_replay_from_tick` on `SimSessionStub`; smoke `sim_replay_stub.li` — [2026-05-25-sim-replay-sim2-stub.md](docs/release-notes/2026-05-25-sim-replay-sim2-stub.md).
```
