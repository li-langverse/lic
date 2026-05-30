# World Studio + lillm — Wave 0 (2026-05-29)

## Summary

Initial cleanup and scaffold wave for native World Studio + **lillm** battle plan.
Product logic remains stub-honest; PR queue hygiene executed via `gh` CLI.

## PR hygiene (Phase 0)

### Closed (stale / superseded / policy)

- **#271** — demo release MP4 (policy: no GitHub Release artifacts)
- **#288** — wgpu readback duplicate (on main via #342)
- **#319**, **#318** — superseded by #350 / #356
- **#317**, **#301**, **#295**, **#294**, **#291**, **#286**, **#283**, **#282**, **#281**
- **#272**, **#268**, **#266**, **#264**, **#263**, **#262**, **#254**
- **#194**, **#188**, **#183** — stale plan-loop / compiler PRs

### Merge queue (branch update triggered; auto-merge disabled on repo)

- **#357**, **#351**, **#347**, **#350**, **#353**, **#359** — `update-branch` (rebase) requested 2026-05-29; merge after CI green
- **#360** — needs human review; branch policy blocked immediate merge

## New packages

### `packages/li-llm` (PH-LLM)

- Stubs: `llm_tokenize`, `llm_load_weights`, `llm_forward`, `llm_generate`
- WP-LLM-01..08 defined in program + RFC
- `li_llm_version() == 0` until WP gates pass

### `packages/li-studio-ai`

- Stubs: `studio_ai_complete`, `studio_ai_apply_patch`, `studio_ai_mcp_dispatch`
- Agentic task FSM: idle / running / done / cancelled / failed

## Documentation

- `docs/game-dev/PH-LLM-program.md`
- `docs/game-dev/specs/lillm-rfc.md`
- `docs/game-dev/specs/studio-cursor-sdk-rfc.md` (expanded)
- `docs/game-dev/specs/c-host-retirement-plan.md`
- `docs/demo/VERTICALS-RECORDING.md` — local-only, no release MP4

## Cursor toolchain

- `rules/ph-llm-wp-scope.mdc`
- `skills/execute-ph-llm-wp`, `skills/record-studio-demo`
- `guard-li-surface.sh` wired in `hooks.json`

## Verification

```bash
lic check packages/li-llm/li-tests/smoke/llm_tokenize_roundtrip.li
lic check packages/li-studio-ai/li-tests/smoke/studio_ai_task_state.li
lic check packages/li-studio/li-tests/smoke/studio_vertical_profile_roundtrip.li
```

## What remains

- [ ] **PR #356** — rebase `feat/studio-real-implementation`; fix `import_render_wgpu_fps.li` + registry-and-tier0
- [ ] C-host retirement Steps 1–4 (after #356)
- [ ] WP-LLM-01..04 implementation
- [ ] PR **#362** agentic run state merge
- [ ] PH-ML-GPU Wave 1–2 for CPU/GPU matmul spine

## Branch

`feat/world-studio-lillm-wave0` from `origin/main`
