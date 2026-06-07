# Vision-LLM manifest ship gate (stub → CI-backed agent entry)

> **Issue:** [#464](https://github.com/li-langverse/lic/issues/464) · **Repo:** li-langverse/lic  
> **Vision:** **AI-first** (agent-safe defaults, diagnosable errors), **Provable** (no proof shortcuts)  
> **north_star_fit:** scientific computing + AI agent workflows · **Vision-LLM** (master plan L476)  
> **Learned from:** [2026-05-16-li-llm-first-design.md](../specs/2026-05-16-li-llm-first-design.md), [agent-handover-formats.md](../../ecosystem/agent-handover-formats.md), [2026-05-25-vision-llm-diag-manifest.md](../../release-notes/2026-05-25-vision-llm-diag-manifest.md), [2026-05-30-vision-llm-done-gates.md](2026-05-30-vision-llm-done-gates.md) (sibling plan for [#425](https://github.com/li-langverse/lic/issues/425))

## Goal

Close the **manifest stub ship gate** for master-plan **Vision-LLM**: turn `docs/ecosystem/li-agent-manifest.toml` + `scripts/gen-li-agent-manifest.sh` from v0 placeholder into a **CI-enforced agent entry** that agents can rely on without reading the whole repo. Flip the master-plan checkbox only when manifest generation, diagnostic smokes, and test-export smokes are green in the same PR.

## Non-goals

- Skipping `requires` / `ensures` / `decreases` in shipped Li source.
- Replacing Lean or `lic build` with LLM verification.
- Breaking default human `lic check` output (JSON stays opt-in via `--format=json` / `lic diagnose`).
- Full `lic edit --patch=json` (spec-only; separate PH track).
- Populating rich `fix_hint` objects in every diagnostic code (follow-up slice).
- **benchmarks** harness copy — catalog-only changes are insufficient.

## Dependencies

- **Vision-LLM** master-plan row (partial at L476).
- Sibling: [#425](https://github.com/li-langverse/lic/issues/425) — broader Done gates (studio-ai non-stub, tracker E); this plan owns **manifest + CI wiring** (gates M1–M4 below).
- Related: [benchmarks#19](https://github.com/li-langverse/benchmarks/issues/19) — cross-repo manifest CI scope (benchmarks side only if export artifacts land there).
- **Human-only:** confirm new CI steps fit Actions budget; no secrets in generated manifests.

## Current state (evidence)

| Shipped | Stub / gap |
|---------|------------|
| `lic check --format=json`, `lic diagnose`, `diagnostic-v1` schema | `gen-li-agent-manifest.sh` **not** invoked in default `scripts/ci.sh` |
| `li-tests/tooling/diagnose_json_smoke.sh` in CI | `li-agent.json` + `.cursor/AGENTS.generated.md` not smoke-tested |
| `scripts/export-li-tests-agent-slice.sh` + `agent_manifest_smoke.sh` in CI | TOML `[exports]` still marked “Future” in comments |
| `docs/ecosystem/li-agent-manifest.toml` v0 canonical source | No committed snapshot or hash gate for generated JSON |

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **M1** | **Manifest generation smoke** — new `li-tests/tooling/agent_manifest_gen_smoke.sh` runs `scripts/gen-li-agent-manifest.sh` and asserts `li-agent.json` schema fields + `.cursor/AGENTS.generated.md` fragment | Smoke green locally and in `scripts/ci.sh` Vision-LLM phase |
| **M2** | **CI wiring** — add `gen-li-agent-manifest.sh` + M1 smoke to default `scripts/ci.sh` path (same block as `diagnose_json_smoke.sh` / `agent_manifest_smoke.sh`) | PR shows both smokes in CI log; no manual-only generation |
| **M3** | **Handover docs** — update `agent-handover-formats.md` + llm-first spec § Tooling with “Done checklist” linking M1–M4; remove “optional” wording on generated artifacts | Docs cite smoke paths; `li-agent-manifest.toml` `[exports]` comments reflect CI truth |
| **M4** | **Agent workflow doc** — short “Agent fix loop” section in plan or llm-first spec: manifest → diagnose → edit → check → `run_all` suite from `li-tests/agent-manifest.json` | Linked from issue #464 acceptance; no duplicate AGENTS.md prose |
| **M5** | **Tracker closure (with #425 E)** — master plan Vision-LLM `[x]` only when M1–M4 **and** sibling gates C–D from [2026-05-30-vision-llm-done-gates.md](2026-05-30-vision-llm-done-gates.md) are green | Same PR as evidence; honest partial until then |

## Tests / benches

| ID | Path | Role |
|----|------|------|
| REQ-VLLM-DIAG | `li-tests/tooling/diagnose_json_smoke.sh` | diagnostic-v1 envelope (existing) |
| REQ-VLLM-EXPORT | `li-tests/tooling/agent_manifest_smoke.sh` | test manifest JSON slice (existing) |
| REQ-VLLM-GEN | `li-tests/tooling/agent_manifest_gen_smoke.sh` | **new** — manifest generation + JSON schema |
| REQ-VLLM-CACHE | `li-tests/tooling/check_workspace_cache_smoke.sh` | workspace JSON cache (existing) |
| WP-AG-04 | `packages/li-studio-ai/li-tests/` | apply_patch loop — tracked under #425 gate D, not blocking M1–M4 |

No perf benches; not perf-sensitive.

## Provability

| Gap | Move | Notes |
|-----|------|-------|
| **G-*** | **No new row** | Agent/diagnostics surface only |
| **G-dec / G-par** | Unchanged | Manifest must not advertise `Any`, `sorry`, or skip-proof flags |
| Honest limit | JSON diagnostics + manifest are **elaboration/display** layers | `lic build` certificate unchanged |

## Rollout

1. **This PR (plan only):** add this file; link from `plan-cross-links.md` Vision-LLM row.
2. **Implementation PR (after `plan-approved`):** M1 → M2 → M3 → M4 in one or two slices; release note under `docs/release-notes/`.
3. **Tracker:** update [2026-05-14-li-master-plan.md](2026-05-14-li-master-plan.md) L476 only when M5 criteria met (coordinate with #425).
4. **Downstream:** lip/lit/lis — optional pin of generated manifest pattern; no harness copy to **benchmarks**.

## Human-only

- [ ] Add label **`plan-approved`** on #464 before implementation agents run.
- [ ] Acknowledge sibling plan on #425 (gates D/E) or consolidate labels when one plan covers both.
- [ ] Confirm CI step budget if M2 adds >30s wall time ([actions-budget](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/actions-budget.md)).
