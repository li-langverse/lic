# LLVM 22 cloud VM bootstrap + Studio vertical tick hooks

## Summary

Cloud Agent VMs install LLVM 22 via `scripts/cloud-vm-bootstrap.sh`, and all seven Studio sim profiles call domain `*_tick_stub` hooks from `studio_sim_step_hook`.

## Agent continuation

1. **Read:** `docs/ecosystem/cloud-agent-vm.md`, `docs/game-dev/studio-full-implementation-plan.md` §1.2.
2. **Run:** `bash scripts/cloud-vm-bootstrap.sh`; `lic check packages/li-studio/li-tests/smoke/studio_sim_step_by_profile.li`.
3. **Next:** Deepen each vertical (IK, printer export, LITL stages, RL env pool) on `cursor/vertical-*-5599` branches.
4. **Blocked:** Wave A `lic build` Lean gate — domain kernels remain stub-level.

## Changed

- `scripts/cloud-vm-bootstrap.sh` — LLVM 22, env file, lic build
- `docs/ecosystem/cloud-agent-vm.md`, `docs/guide/devbox-li-development.md`, `AGENTS.md`
- `packages/li-sim-{robotics,automotive,additive,drug-design}/src/lib.li` — `*_tick_stub` / `*_tick_at`
- `packages/li-sim/src/lib.li` — `sim_rl_tick_stub`
- `packages/li-studio/src/lib.li` — `studio_sim_step_hook` dispatches all sim profiles
- Smokes: `tick_stub.li` per domain pack; extended `studio_sim_step_by_profile.li`

## Not changed

- Compiler Wave A (2e/2f/7e), wgpu viewport, `lis mcp li-engine`, benchmarks `verticals.toml` ingest.

## Breaking

N/A — install script path change only for Cloud VMs using the old LLVM 18 inline cmake line.

## Security

N/A — toolchain bootstrap only.

## Performance

N/A — stub ticks; no bench threshold changes.

## Downstream

Point Cursor Cloud install script at `bash /agent/repos/lic/scripts/cloud-vm-bootstrap.sh`.
