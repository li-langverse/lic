# Vision-LLM completion — agent manifest CI + compact test export (#19)

> **Issue:** [#19](https://github.com/li-langverse/lic/issues/19) · **Repo:** li-langverse/lic  
> **Vision:** **AI-first** (agent-safe defaults, diagnosable errors), **Provable** (no proof shortcuts)  
> **north_star_fit:** scientific computing + AI agent workflows · **Vision-LLM** (master plan L476)  
> **Learned from:** [2026-05-16-li-llm-first-design.md](../specs/2026-05-16-li-llm-first-design.md), [agent-handover-formats.md](../../ecosystem/agent-handover-formats.md), [2026-05-25-vision-llm-diag-manifest.md](../../release-notes/2026-05-25-vision-llm-diag-manifest.md), [2026-06-07-vision-llm-manifest-ship-gate.md](2026-06-07-vision-llm-manifest-ship-gate.md) (sibling [#464](https://github.com/li-langverse/lic/issues/464))

## Goal

Close the **remaining Vision-LLM stub gap** tracked on master plan L476: wire manifest generation into default CI, keep compact test export linked from `li-agent-manifest.toml`, and document `lic-fix-suggest.sh` scope so agents can rely on a **CI-backed agent entry** without reading the whole repo. Flip the master-plan checkbox only when smokes, handover docs, and sibling Done gates align.

This plan is the **implementation orchestration** lane for #19. Exit-gate definitions live in sibling plans ([#425](https://github.com/li-langverse/lic/issues/425) Done gates A–E, [#464](https://github.com/li-langverse/lic/issues/464) manifest ship M1–M4); this file sequences the **#19 acceptance** into shippable slices.

## Non-goals

- Skipping `requires` / `ensures` / `decreases` in shipped Li source.
- Replacing Lean or `lic build` with LLM verification.
- Breaking default human `lic check` output (JSON stays opt-in via `--format=json` / `lic diagnose`).
- Full `lic edit --patch=json` (spec-only; separate PH track).
- **Rich `fix_hint` objects** in every diagnostic code — **explicit deferral**; `lic-fix-suggest.sh` stays jq hints (see § Fix-suggest policy).
- Copying harness into **benchmarks** (catalog-only changes insufficient).
- Re-opening closed plan issues #425 / #464 — coordinate via cross-links only.

## Dependencies

| Dependency | Role |
|------------|------|
| **Vision-LLM** master-plan row (partial L476) | Tracker closure target |
| [#464](https://github.com/li-langverse/lic/issues/464) + [manifest ship gate](2026-06-07-vision-llm-manifest-ship-gate.md) | Gates **M1–M4** (gen smoke + CI wiring) |
| [#425](https://github.com/li-langverse/lic/issues/425) + [Done gates](2026-06-07-vision-llm-done-gates.md) | Gates **A–E** (broader closure incl. studio-ai) |
| [#16](https://github.com/li-langverse/lic/issues/16) | Tracker reconciliation — **out of scope** for #19 |
| **Human-only:** CI Actions budget; no secrets in generated manifests |

## Current state (evidence, 2026-06-07)

| Shipped (green) | Stub / gap (#19 scope) |
|-----------------|------------------------|
| `lic check --format=json`, `lic diagnose`, `diagnostic-v1` schema | `gen-li-agent-manifest.sh` **not** in default `scripts/ci.sh` |
| `diagnose_json_smoke.sh`, `check_workspace_cache_smoke.sh` in CI | `li-agent.json` + `.cursor/AGENTS.generated.md` not smoke-tested |
| `export-li-tests-agent-slice.sh` + `agent_manifest_smoke.sh` in CI | `li-agent-manifest.toml` `[exports]` comments still say “Future” |
| `docs/ecosystem/li-agent-manifest.toml` v0 canonical source | `lic-fix-suggest.sh` — jq hints only; no spec non-goal |
| Sibling plans drafted (PRs [#996](https://github.com/li-langverse/lic/pull/996), [#1010](https://github.com/li-langverse/lic/pull/1010)) | Master plan L476 still `[ ] partial` |

## Sub-phases (implementation slices)

| Slice | ID | Deliverable | Exit gate | Delegates to |
|-------|-----|-------------|-----------|--------------|
| **I1** | REQ-VLLM-GEN | **Manifest gen smoke** — `li-tests/tooling/agent_manifest_gen_smoke.sh` runs `gen-li-agent-manifest.sh`, asserts `li-agent.json` schema + `.cursor/AGENTS.generated.md` fragment | Smoke green locally | #464 **M1** |
| **I2** | REQ-VLLM-CI | **Default CI wiring** — invoke `gen-li-agent-manifest.sh` + I1 smoke in `scripts/ci.sh` Vision-LLM block (same phase as `diagnose_json_smoke.sh`) | CI log shows gen + export smokes; no manual-only path | #464 **M2** |
| **I3** | REQ-VLLM-EXPORT | **TOML ↔ export linkage** — update `li-agent-manifest.toml` `[exports]` + handover docs so `tests_agent_json` path matches CI artifact | `agent_manifest_smoke.sh` green; TOML no longer “Future” | #464 **M3**, Done gate **B** |
| **I4** | REQ-VLLM-FIX | **Fix-suggest policy** — document jq-hints-only as **non-goal** in llm-first spec; keep `fix_suggest` key in TOML pointing at stub script | Spec § Non-goals cites #19; no false “shipped” claim | #19 unique |
| **I5** | VLLM-TRACKER | **Tracker closure** — master plan L476 `[x]` when I1–I4 + sibling gates C–D green | Same PR as evidence; honest partial until then | #425 gate **E**, #464 **M5** |

### Gate status snapshot

| Slice | Status | Blocker |
|-------|--------|---------|
| I1 | **Open** | New smoke script |
| I2 | **Open** | `scripts/ci.sh` wiring |
| I3 | **Partial** | Export smoke green; TOML comments stale |
| I4 | **Open** | Spec non-goal paragraph |
| I5 | **Blocked** | I1–I2 + sibling D |

## Fix-suggest policy (I4)

`scripts/lic-fix-suggest.sh` prints jq-formatted diagnostic summaries. It does **not** emit structured `fix_hint` objects from `diagnostic-v1.json`.

**Decision:** defer rich fix hints to a future PH track. Implementation PR for I4 adds to [2026-05-16-li-llm-first-design.md](../specs/2026-05-16-li-llm-first-design.md):

> **Non-goal (2026-06):** per-code `fix_hint` population and LLM-driven patch application beyond studio-ai WP-AG-04. Agents use `lic diagnose` JSON + handover docs; `lic-fix-suggest.sh` remains optional human helper.

No CI smoke required for I4 (documentation-only).

## Tests / benches

| ID | Path | Role |
|----|------|------|
| REQ-VLLM-DIAG | `li-tests/tooling/diagnose_json_smoke.sh` | diagnostic-v1 envelope (existing, green) |
| REQ-VLLM-CACHE | `li-tests/tooling/check_workspace_cache_smoke.sh` | workspace JSON cache (existing, green) |
| REQ-VLLM-EXPORT | `li-tests/tooling/agent_manifest_smoke.sh` | test manifest JSON slice (existing, green) |
| REQ-VLLM-GEN | `li-tests/tooling/agent_manifest_gen_smoke.sh` | **new (I1)** — manifest generation + JSON schema |
| WP-AG-04 | `packages/li-studio-ai/li-tests/smoke/studio_ai_apply_patch_loop.li` | apply_patch loop — #425 gate D |

No perf benches; not perf-sensitive.

## Provability

| Gap | Move | Notes |
|-----|------|-------|
| **G-*** | **No new row** | Agent/diagnostics surface only |
| **G-dec / G-par** | Unchanged | Manifest must not advertise `Any`, `sorry`, or skip-proof flags |
| Honest limit | JSON diagnostics + manifest are **elaboration/display** layers | `lic build` certificate unchanged |

## Rollout

1. **This PR (plan only):** add this file; link from `plan-cross-links.md` Vision-LLM row.
2. **Implementation PR (after `plan-approved` on #19):** I1 → I2 → I3 in one slice; I4 doc in same or follow-up PR.
3. **Tracker PR:** I5 when sibling Done gates A–D green; release note under `docs/release-notes/`.
4. **Coordination:** merge sibling plan PRs [#996](https://github.com/li-langverse/lic/pull/996), [#1010](https://github.com/li-langverse/lic/pull/1010) before or with first implementation PR to avoid doc drift.

## Human-only

- [ ] Add label **`plan-approved`** on #19 before implementation agents run.
- [ ] Remove **`plan-needed`** when plan merged.
- [ ] Confirm CI step budget if I2 adds >30s wall time ([actions-budget](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/actions-budget.md)).
- [ ] Coordinate tracker flip (I5) with #425 / #464 maintainers — one honest PR.
