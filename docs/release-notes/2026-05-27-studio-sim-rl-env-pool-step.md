# Release notes: 2026-05-27 — studio-sim-rl-env-pool-step

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**Branch:** `feat/studio-real-implementation`  
**PH / REQ:** PH-SIM SIM-3, Li Studio real implementation  

---

## Summary (one sentence)

`studio_sim_step_hook` for the `sim_rl` profile now runs `env_pool_stub_step` on the caller's `SimSessionStub` instead of a detached `sim_rl_tick_stub` self-test plus a single `sim_step`.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| `li-sim` | `sim_rl_session_env_pool_step` — shared env-pool batch + contract checks | `env_pool_stub.li`, `sim_rl_tick_stub` |
| `li-studio` | `studio_sim_rl_step_hook`; RL branch early-returns after pool step | `studio_sim_rl_step_hook.li`, `studio_sim_step_by_profile.li` |

## Not changed (scope fence)

- PH-ML async workers, persistent `EnvPool` in `li-ml-rl` — **not** in this change.
- Game physics session coupling — **not** in this change (`studio_game_step_hook` still uses ephemeral `PhysicsWorld`).
- Oracle / tier-2 bench claims — **none**.

## Breaking changes

None — RL profile `studio_sim_step_hook` now advances `tick` by `sim_rl_env_pool_size_default()` (4) per frame instead of 1; callers depending on tick==1 after one hook call should use pool size (smokes updated).

## Downstream

| Repo | Action |
|------|--------|
| Native timeline | Expect `tick += pool_size` per RL frame until persistent pool lands |
| `li-ml-rl` | Re-export `sim_rl_session_env_pool_step` when package scaffold merges |

## CHANGELOG entry (paste into Unreleased)

```markdown
### Added
- **PH-SIM SIM-3 studio RL step** — `studio_sim_rl_step_hook`, `sim_rl_session_env_pool_step`; `sim_rl` profile in `studio_sim_step_hook` batches env pool on live session; smokes `studio_sim_rl_step_hook.li`, extended `studio_sim_step_by_profile.li`.
```
