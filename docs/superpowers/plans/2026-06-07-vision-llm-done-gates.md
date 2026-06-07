# Vision-LLM Done gates (agent manifest + test export CI)

> **Issue:** [#425](https://github.com/li-langverse/lic/issues/425) · **Repo:** li-langverse/lic  
> **Vision:** **AI-first** (agent-safe defaults, diagnosable errors), **Provable** (no proof shortcuts)  
> **north_star_fit:** scientific computing + AI agent workflows · **Vision-LLM** (master plan L476)  
> **Learned from:** [2026-05-16-li-llm-first-design.md](../specs/2026-05-16-li-llm-first-design.md), [agent-handover-formats.md](../../ecosystem/agent-handover-formats.md), [diagnostic-v1.json](../../schemas/diagnostic-v1.json), [2026-05-25-vision-llm-diag-manifest.md](../../release-notes/2026-05-25-vision-llm-diag-manifest.md)

## Goal

Define explicit **Done** exit gates for the master-plan **Vision-LLM** row so agents and humans flip the tracker checkbox only when manifest generation, CI export, diagnostic smokes, and studio-ai handoff loops are non-placeholder — without weakening `lic build` or Lean contracts.

## Non-goals

- Skipping `requires` / `ensures` / `decreases` in shipped Li source.
- Replacing Lean with `lic build` using LLM verification.
- Breaking default human `lic check` output (JSON stays opt-in via `--format=json` / `lic diagnose`).
- Full `lic edit --patch=json` (spec-only; separate PH track).
- Populating rich `fix_hint` objects in every diagnostic code (follow-up slice; `lic-fix-suggest.sh` remains jq hints).
- Copying harness into **benchmarks** (catalog-only changes insufficient).

## Dependencies

- **Vision-LLM** master-plan row (partial at L476).
- Sibling: [#464](https://github.com/li-langverse/lic/issues/464) — manifest stub → CI-backed agent entry ([2026-06-07-vision-llm-manifest-ship-gate.md](2026-06-07-vision-llm-manifest-ship-gate.md), gates **M1–M4**).
- Related: [#19](https://github.com/li-langverse/benchmarks/issues/19) — cross-repo manifest CI scope (benchmarks side only if export artifacts land there).
- Registry: `gap-plan-debt-lic-master-plan-vision-llm-llm-first-agent-json-` (plan_debt, open).
- **Human-only:** confirm new CI steps fit Actions budget; no secrets in generated manifests.

## Current state (evidence, 2026-06-07)

| Shipped (green) | Partial / stub |
|-----------------|----------------|
| `lic check --format=json`, `lic diagnose`, `docs/schemas/diagnostic-v1.json` | `scripts/gen-li-agent-manifest.sh` **not** invoked in default `scripts/ci.sh` |
| `li-tests/tooling/diagnose_json_smoke.sh` in CI (`scripts/ci.sh` L123–131) | `li-agent.json` + `.cursor/AGENTS.generated.md` not smoke-tested |
| `scripts/export-li-tests-agent-slice.sh` + `agent_manifest_smoke.sh` in CI | `docs/ecosystem/li-agent-manifest.toml` `[exports]` still marked “Future” |
| `li-tests/tooling/check_workspace_cache_smoke.sh` in CI | `scripts/lic-fix-suggest.sh` — jq hints only (stub) |
| WP-AG-04 apply_patch + lic-check retry loop (`packages/li-studio-ai/src/lib.li` L206–254) | `studio_ai_complete` returns honest `"."` stub when fixture weights absent (L256–271) |
| Package smokes: `studio_ai_apply_patch_loop.li`, `studio_ai_patch_eval.li` | End-to-end agent fix loop not linked from llm-first spec § Done |

**Note:** Issue #425 originally cited L88 as STUB; that line is now task FSM (`studio_ai_create_task`). Apply-patch loop is implemented; remaining studio-ai gap is fixture-bound completion + handover doc linkage.

## Sub-phases (exit gates)

| Gate | ID | Deliverable | Exit gate | Primary paths |
|------|-----|-------------|-----------|---------------|
| **A** | REQ-VLLM-MANIFEST | **Manifest schema v1** — canonical TOML + generated JSON in CI | `gen-li-agent-manifest.sh` runs in default CI; new `agent_manifest_gen_smoke.sh` asserts `li-agent.json` fields + fragment | `docs/ecosystem/li-agent-manifest.toml`, `scripts/gen-li-agent-manifest.sh`, `li-tests/tooling/agent_manifest_gen_smoke.sh` (**#464 M1–M2**) |
| **B** | REQ-VLLM-EXPORT | **Test manifest export** — compact agent slice | `export-li-tests-agent-slice.sh` + `agent_manifest_smoke.sh` green in CI | `scripts/export-li-tests-agent-slice.sh`, `li-tests/agent-manifest.json`, `li-tests/tooling/agent_manifest_smoke.sh` |
| **C** | REQ-VLLM-DIAG | **Diagnostic CI** — JSON envelope + workspace cache | Both smokes green on `main` default CI path | `li-tests/tooling/diagnose_json_smoke.sh`, `li-tests/tooling/check_workspace_cache_smoke.sh`, `docs/schemas/diagnostic-v1.json` |
| **D** | REQ-VLLM-STUDIO | **studio-ai handoff loop** — apply_patch → lic check → retry | Package smokes pass; README + llm-first spec document fixture vs cloud stub; patch_eval ≥70% gate green | `packages/li-studio-ai/src/lib.li`, `packages/li-studio-ai/li-tests/smoke/studio_ai_apply_patch_loop.li`, `studio_ai_patch_eval.li` |
| **E** | VLLM-TRACKER | **Tracker closure** | Master plan Vision-LLM `[x]` in same PR as gates A–D + sibling M3–M4 | `docs/superpowers/plans/2026-05-14-li-master-plan.md` L476 |

### Gate status snapshot

| Gate | Status | Blocker |
|------|--------|---------|
| A | **Partial** | #464 implementation (M1–M2) |
| B | **Green** | — |
| C | **Green** | — |
| D | **Partial** | Doc linkage + optional fixture weights path for non-stub `studio_ai_complete` |
| E | **Blocked** | A + D + #464 M3–M4 |

## Tests / benches

| ID | Path | Role |
|----|------|------|
| REQ-VLLM-DIAG | `li-tests/tooling/diagnose_json_smoke.sh` | diagnostic-v1 envelope, severity mix, optional jq |
| REQ-VLLM-CACHE | `li-tests/tooling/check_workspace_cache_smoke.sh` | workspace + per-file JSON cache |
| REQ-VLLM-EXPORT | `li-tests/tooling/agent_manifest_smoke.sh` | test manifest JSON slice + suite index |
| REQ-VLLM-GEN | `li-tests/tooling/agent_manifest_gen_smoke.sh` | **new (#464)** — manifest generation + JSON schema |
| WP-AG-04 | `packages/li-studio-ai/li-tests/smoke/studio_ai_apply_patch_loop.li` | apply_patch + retry loop |
| WP-AG-06 | `packages/li-studio-ai/li-tests/smoke/studio_ai_patch_eval.li` | patch eval ≥70% fix-rate |

No perf benches; not perf-sensitive.

## Provability

| Gap | Move | Notes |
|-----|------|-------|
| **G-*** | **No new row** | Agent/diagnostics surface only |
| **G-dec / G-par** | Unchanged | Manifest must not advertise `Any`, `sorry`, or skip-proof flags |
| Honest limit | JSON diagnostics + manifest are **elaboration/display** layers | `lic build` certificate unchanged |

## Doc linkage (this plan → specs)

Implementation PR(s) must update:

1. [2026-05-16-li-llm-first-design.md](../specs/2026-05-16-li-llm-first-design.md) — add **Done checklist** table pointing to gates A–E.
2. [agent-handover-formats.md](../../ecosystem/agent-handover-formats.md) — replace “optional” on generated artifacts; link agent fix loop to smoke paths.
3. [plan-cross-links.md](../../ecosystem/plan-cross-links.md) — Vision-LLM row links this plan + sibling #464 plan.

Master plan L476 flips to `[x]` **only** in the PR where gates A, B, C, D are green and #464 M3–M4 doc gates pass.

## Rollout

1. **This PR (plan only):** add this file; cross-link from `plan-cross-links.md`, llm-first spec, agent-handover.
2. **#464 implementation PR (after `plan-approved`):** gates A (M1–M4).
3. **#425 implementation PR (after `plan-approved`):** gate D doc + optional fixture completion; verify B/C still green.
4. **Tracker PR:** gate E — same PR as final evidence; release note under `docs/release-notes/`.
5. Close registry `gap-plan-debt-lic-master-plan-vision-llm-llm-first-agent-json-` when E passes.

## Human-only

- [ ] Add label **`plan-approved`** on #425 before implementation agents run.
- [ ] Acknowledge sibling plan on #464; coordinate M5 / gate E in one tracker PR.
- [ ] Confirm CI step budget if gate A adds >30s wall time ([actions-budget](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/actions-budget.md)).
