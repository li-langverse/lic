# Vision-LLM Done gates (agent manifest + test export CI)

> **Issue:** [#425](https://github.com/li-langverse/lic/issues/425) · **Repo:** li-langverse/lic  
> **Vision:** **AI-first** (agent-safe defaults, diagnosable errors), **Provable** (no proof shortcuts)  
> **Learned from:** [2026-05-16-li-llm-first-design.md](../specs/2026-05-16-li-llm-first-design.md), [agent-handover-formats.md](../../ecosystem/agent-handover-formats.md), [diagnostic-v1.json](../../schemas/diagnostic-v1.json), [2026-05-16-vision-llm-agent-diagnostics.md](../../release-notes/2026-05-16-vision-llm-agent-diagnostics.md)

## Goal

Define explicit **Done** exit gates for the master-plan **Vision-LLM** row so agents and humans can flip the tracker checkbox only when manifest, CI export, and studio-ai stubs are non-placeholder — without weakening `lic build` or Lean contracts.

## Non-goals

- Skipping `requires` / `ensures` in shipped source.
- Replacing Lean with LLM verification.
- Breaking default human `lic check` output (JSON remains opt-in).
- Full `lic edit --patch=json` (spec-only; separate PH track).

## Dependencies

- **Vision-LLM** master-plan row (partial).
- Related: [#464](https://github.com/li-langverse/lic/issues/464) (manifest stub ship gate), [#19](https://github.com/li-langverse/benchmarks/issues/19) (manifest CI scope — benchmarks side if any).
- **Human-only:** org CI budget for new export job; no secrets in manifest.

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| A | **Manifest schema v1** — `docs/ecosystem/li-agent-manifest.toml` lists canonical agent commands with stable ids | Schema doc + TOML validates in CI (`toml` lint or smoke) |
| B | **Test manifest export** — `scripts/export-li-tests-manifest.sh` → compact JSON slice for agents | CI job runs export; artifact or committed snapshot under `docs/ecosystem/` with stable ordering |
| C | **Diagnostic CI** — `li-tests/tooling/diagnose_json_smoke.sh`, `check_workspace_cache_smoke.sh` green on `main` | Already partial; gate = both in default `ci.sh` path |
| D | **studio-ai non-stub** — `packages/li-studio-ai/src/lib.li` apply_patch + check loop implements real handoff (not STUB at L88) | `li-tests/` or package smoke passes; release note |
| E | **Tracker closure** — master plan Vision-LLM `[x]` in same PR as gates A–D | All sub-phases green |

## Tests / benches

- `li-tests/tooling/diagnose_json_smoke.sh`
- `li-tests/tooling/check_workspace_cache_smoke.sh`
- New: `li-tests/tooling/agent_manifest_export_smoke.sh` (export + schema hash)
- No perf benches; not perf-sensitive.

## Provability

- **No new G-* row** — agent/diagnostics surface only.
- **G-dec / G-par** unchanged; manifest must not advertise unsafe shortcuts (`Any`, `sorry`, skip-proof flags).
- Honest limit: JSON diagnostics are **display/elaboration** layers; `lic build` certificate unchanged.

## Rollout

1. **lic** draft PR: this plan + gate checklist in llm-first spec § "Done".
2. Implement A→B→C (mostly CI/docs); D may stack after `plan-approved`.
3. Update [2026-05-14-li-master-plan.md](2026-05-14-li-master-plan.md) Vision-LLM row when E passes.
4. **benchmarks:** no harness copy; optional cross-link in agent-automations doc.

## Human-only

- [ ] Add label **`plan-approved`** before implementation PRs
- [ ] Confirm CI job addition fits Actions budget ([actions-budget](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/actions-budget.md))
