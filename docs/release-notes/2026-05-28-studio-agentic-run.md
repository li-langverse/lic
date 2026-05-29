# Release notes: 2026-05-28 — studio-agentic-run

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** branch `cursor/real-agentic-studio-5b3a`  
**PH / REQ:** PH-AGENT-2, PH-UX-06, T-PKG-li-studio-agentic-run  
**Author:** agent

---

## Summary (one sentence)

`li-studio` now exposes an importable `StudioAgentRun` state model for the world-patch -> `lic_check` -> `lic_build` tool sequence, with `used_html_mock == 0` so Studio agent progress no longer depends on HTML mock assets.

## Agent continuation (required)

1. Read: `packages/li-studio/src/lib.li`, `packages/li-studio/README.md`, `docs/game-dev/studio-full-implementation-plan.md`, and `docs/game-dev/world-studio-vision.md`.
2. Run: `LI_REPO_ROOT=$PWD build/compiler/lic/lic check packages/li-studio/li-tests/smoke/studio_agentic_run.li` and `LI_REPO_ROOT=$PWD build/compiler/lic/lic check li-tests/composable/import_studio_agentic_run.li`.
3. Then: wire the next PH-AGENT slice to `lis mcp li-engine` or the Cursor SDK apply-patch loop so the `lic_check` / `lic_build` steps execute real commands; keep `StudioAgentRun.used_html_mock == 0` as the product truth invariant.
4. Blocked on: full `./li-tests/run_all.sh composable` is still red for pre-existing `import_physics_runtime.li`, `import_sim_scientific_run.li`, and `import_render_wgpu_fps.li`; this PR's new `import_studio_agentic_run.li` row passed in that run.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| `packages/li-studio/src/lib.li` | Added `StudioAgentRun`, `studio_agent_run_start`, `studio_agent_run_next`, `studio_agent_run_complete`, `studio_agent_run_complete_ok`, `studio_agent_tool_request_for_run`, and `studio_agent_real_pipeline_steps`; bumped `li_std_studio_version()` to `11`. The state model records `patch_applied`, `check_step_done`, `build_step_done`, and `used_html_mock`. | `LI_REPO_ROOT=$PWD build/compiler/lic/lic check packages/li-studio/src/lib.li` exit `0`; `studio_agentic_run.li` check exit `0`; `lic build --allow-open-vc --no-lean-verify ...` plus binary run exit `0`. |
| `packages/li-studio/li-tests/` | Added package smoke `smoke/studio_agentic_run.li` and manifest row `T-PKG-li-studio-agentic-run PH-AGENT-2 Studio agent state model`. | RED before implementation: missing `StudioAgentRun` / `studio_agent_run_start`; green after implementation: check exit `0`, dev build/run with `--allow-open-vc --no-lean-verify` exit `0`. |
| `li-tests/composable/` | Added `import_studio_agentic_run.li` and root manifest row so main `li-tests` imports the Studio agent state model. | Direct check exit `0`; dev build/run with `--allow-open-vc --no-lean-verify` exit `0`; composable suite output includes `PASS check_ok composable/import_studio_agentic_run.li`. |
| Docs | Updated `packages/li-studio/README.md`, `packages/li-studio/CHANGELOG.md`, `CHANGELOG.md`, and `docs/game-dev/studio-full-implementation-plan.md` to mark this as an in-process Studio agent state model, not an HTML mock. | This release note plus changelog entries. |

## Not changed (scope fence)

- `deploy/studio-demo/screenshots/*.html`, archived vertical HTML mocks, and screenshot capture scripts were not used or modified.
- `lis mcp li-engine`, `@cursor/sdk`, network transport, real `lic` process execution, and external agent execution are still not implemented in this PR.
- `lic check --format=json`, diagnostic schemas, Lean trusted axioms, and compiler proof policy were not changed.
- GPU/wgpu readback, SDL present host, viewport rendering, and performance benchmark thresholds were not changed.

## Breaking changes

N/A — this only adds `li-studio` APIs and a version constant bump for package smokes; existing Studio APIs remain in place.

## Security

N/A — no new network server, file write path, process spawn, trusted axiom, or credential surface was added. The new run model is a pure Li state machine over existing MCP tool IDs.

## Performance

N/A — no hot path or performance claim changed. The new code is a small fixed-step state model; no benchmark threshold or dashboard row was touched.

## Downstream

| Repo | Action |
|------|--------|
| `li-studio` package mirror | Pick up the new `StudioAgentRun` API and changelog when the monorepo package mirror is next pushed. |
| `lis` | N/A for this PR; future PH-AGENT work should map `StudioAgentRun` steps to `lis mcp li-engine`. |
| `lip` / `lit` | N/A — no lockfile, package schema, or test runner behavior changed. |

## CHANGELOG entry (paste into Unreleased)

```markdown
### Added
- **PH-AGENT-2 Studio agent run:** `packages/li-studio/src/lib.li` now exposes `StudioAgentRun` for the world-patch -> `lic_check` -> `lic_build` tool sequence with `used_html_mock == 0`; package/root smokes `studio_agentic_run.li` and `import_studio_agentic_run.li` — [2026-05-28-studio-agentic-run.md](docs/release-notes/2026-05-28-studio-agentic-run.md).
```
