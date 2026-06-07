# Release notes: 2026-05-27 — sim-3-env-pool-stub

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** (pending)  
**PH / REQ:** PH-SIM SIM-2, PH-SIM SIM-3  
**Author:** agent

---

## Summary (one sentence)

`li-sim` gains SIM-2 replay metadata and SIM-3 `EnvPoolStub`/`env_pool_stub_step` so RL profile ticks batch `sim_step` with obs/reward contract stubs.

## Agent continuation (required)

1. Read: `packages/li-sim/src/lib.li`, `docs/game-dev/studio-full-implementation-plan.md` § WP-SIM-03.
2. Run: `lic check packages/li-sim/li-tests/smoke/env_pool_stub.li`; wire `studio_sim_step_hook` sim_rl branch if not merged from sibling vertical PR.
3. Then: promote persistent `EnvPool` in `li-ml-rl` re-exporting `sim` types; add `env_pool_step_contract.li` composable test.
4. Blocked on: async multi-env sampling (PH-ML) — **none** for this stub merge.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| SIM-2 | `SimSessionStub.replay_*`, `sim_session_replay_record`, `sim_replay_*` | `packages/li-sim/src/lib.li` |
| SIM-3 | `EnvPoolStub`, `env_pool_stub_step`, `sim_rl_tick_stub` | `lic check packages/li-sim/li-tests/smoke/env_pool_stub.li` |
| Tests | smoke `env_pool_stub.li` registered in package manifest | `packages/li-sim/li-tests/manifest.toml` |

## Not changed (scope fence)

- `li-studio` `studio_sim_step_hook` sim_rl branch — **not** in this PR (sibling vertical batch).
- `li-ml-rl` package scaffold — **not** created; types live in `li-sim` per SIM-3 deepen task.
- Physics kernels, tier-2 benches, MCP — **not** touched.

## Breaking changes

None — additive fields on `SimSessionStub` with defaults in `sim_session_stub_default()`.

## Security

N/A — deterministic stub counters only; no IO or trusted surface.

## Performance

N/A — composable stub; no bench row.

## Downstream

| Repo | Action |
|------|--------|
| li-ml-rl | Re-export `EnvPoolStub` from `sim` when package lands |
| li-studio | Call `sim_rl_tick_stub` in `studio_sim_step_hook` when merging vertical ticks PR |

## CHANGELOG entry (paste into Unreleased)

```markdown
### Added
- **PH-SIM SIM-3 RL env pool stub** — `EnvPoolStub`, `env_pool_stub_step`, `sim_rl_tick_stub` in `packages/li-sim`; SIM-2 replay on `SimSessionStub`; smoke `env_pool_stub.li`.
```
