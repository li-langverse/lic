# Release notes: 2026-05-25 — vertical-gap-rl-envpool

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PH / REQ:** PH-SIM SIM-3 (partial)

## Summary

PH-SIM SIM-3 partial: `ml.rl.EnvPoolStub` with `env_pool_step` → `sim_step`; `sim_rl` uses `studio_sim_step_hook` env-pool route.

## Agent continuation

1. Read `packages/li-ml-rl/src/lib.li`, `studio_sim_step_hook` in `packages/li-studio/src/lib.li`.
2. Run `lic check` on `env_pool_step_stub.li`, `studio_sim_rl_env_pool.li`, `import_studio_sim_rl_env_pool.li`.
3. Then async multi-env pool or SIM-2 replay.
4. Blocked on: none.

## Not changed

Async pools, Gym API, lis MCP tick persistence.
