# PH-Pkg ecosystem governance — exit gates + goal-directed runner (REQ-Pkg-GOV)

> **Issue:** [#476](https://github.com/li-langverse/lic/issues/476) · **Repo:** li-langverse/lic  
> **Vision:** secure (official package policy), easy (traceability + templates), provable (honest audit counts) · **Learned from:** [2026-05-16-li-ecosystem-governance.md](2026-05-16-li-ecosystem-governance.md), [ph-sci-simulation-gap-close-plan.md](../../data/goal-directed-sprints/ph-sci-simulation-gap-close-plan.md), [plan-completion-audit.py](https://github.com/li-langverse/benchmarks/blob/main/scripts/plan-completion-audit.py), [create-li-package skill](../../.cursor/skills/create-li-package/SKILL.md)

## Goal

Close the remaining **exit gate** in `2026-05-16-li-ecosystem-governance.md`, wire a **goal-directed runner loop** (like PH-SCI / httpd sprints), and drop `plan-completion-audit.json` `plan_files_open` rows for the governance sub-plan — without falsely re-opening the master-plan **PH-Pkg** tracker row (tracker is `[x]`; sub-plan checkbox hygiene is separate).

## Audit reconciliation (2026-06-07)

| Gate (May 30 audit) | Current state | Evidence |
|---------------------|---------------|----------|
| Confirm org access | **Done** | `gh api orgs/li-langverse` succeeds with org token; human ack if agent lacks scope |
| `official-packages.md` PKG- table | **Done** | [docs/ecosystem/official-packages.md](../../ecosystem/official-packages.md) |
| mkdocs `repo_url` / Pages alignment | **Open** | Repo home is `li-langverse/lic`; stale `li-language` refs remain in handbook cross-links — see **Gov-3** |
| `governance.md` user-facing summary | **Done** | [docs/ecosystem/governance.md](../../ecosystem/governance.md) → roadmap canonical |
| `scripts/templates/github-repo/` + `check-traceability.sh` | **Done** | Templates present; [scripts/check-traceability.sh](../../../scripts/check-traceability.sh) in CI path |
| `create-li-package` `--official` → org checklist | **Done** | [.cursor/skills/create-li-package/SKILL.md](../../../.cursor/skills/create-li-package/SKILL.md) § Org repo |
| Example `PUBLISH.md` traceability block | **Partial** | `packages/li-demo/PUBLISH.md` has `PKG-` id; add explicit `Traceability:` PH/T/REQ row in **Gov-7** |

**Open count:** 1 checkbox in governance sub-plan + Gov-7 traceability enrichment (implementation, not audit checkbox until checked).

## Non-goals

- New org repos or GitHub org settings without human checklist ([governance](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/governance.md)).
- Compiler / language features (`plan-approved` required elsewhere).
- Self-merge of **roadmap** governance PRs.
- Weakening `plan-completion-audit` filters to hide gates.

## Dependencies

- **PH-Pkg** master-plan row (scaffold + governance stubs shipped).
- **8-sync** downstream notifications — separate track.
- Human-only: org token for Gov-1 smoke; roadmap PR for canonical `official-packages.md` table edits.
- **benchmarks** `plan-completion-audit.py` with `LIC_ROOT` for verification JSON.

## Sub-phases

| Sub | Gate | Deliverable | Exit gate |
|-----|------|-------------|-----------|
| **Gov-1** | Confirm org access | Document agent/human procedure in governance plan § checklist | Comment on #476 with `gh api orgs/li-langverse` result or human-only block |
| **Gov-2** | PKG- table | Verify [official-packages.md](../../ecosystem/official-packages.md) vs monorepo packages | Every listed std slice has `PKG-*` id + link |
| **Gov-3** | mkdocs / Pages | Replace stale `li-language` repo_url refs with `li-langverse/lic`; align handbook README satellite map post [#535](https://github.com/li-langverse/lic/pull/535) | `grep -r li-langverse/li-language docs/handbook docs/ecosystem/plan-cross-links.md` → zero stale repo home refs; lic Pages 200 |
| **Gov-4** | `governance.md` summary | Ensure stub points to normative plan + roadmap | Link check passes |
| **Gov-5** | Templates + traceability script | Template set matches governance § checklist; script in CI | `./scripts/check-traceability.sh` exit 0 |
| **Gov-6** | `create-li-package --official` | Skill step links governance § repo creation; agent-kit sync | Skill diff reviewed; `./scripts/sync-agent-kit.sh` in benchmarks after roadmap merge |
| **Gov-7** | Example `PUBLISH.md` | Add `## Traceability` block to `packages/li-demo/PUBLISH.md` (PH-Pkg, T-*, REQ-*) | Gate script + audit count drop |

## Goal-directed runner mapping

Unlike httpd/sim loops, governance had **no sprint file** — this plan adds one.

| Artifact | Path | Role |
|----------|------|------|
| Sprint goal | [data/goal-directed-sprints/ph-pkg-governance-exit-gates.md](../../data/goal-directed-sprints/ph-pkg-governance-exit-gates.md) | `goal-directed-loop.sh --goal-file` target |
| Completion gate | [scripts/ph-pkg-governance-gates.sh](../../../scripts/ph-pkg-governance-gates.sh) | Exit 0 when Gov-1…Gov-7 evidence passes |
| Agent | `code_implementer` | One sub-phase per iteration; docs/templates only |
| Workflow repo | `lic` | Branch `cursor/ph-pkg-governance-exit-gates` |
| K8s worker (optional) | `li-cursor-agents/deploy/k8s/engine/` | Human applies ConfigMap mirroring PH-SCI pattern — **no cron** |

### Local loop

```bash
cd li-cursor-agents
./scripts/goal-directed-loop.sh \
  --goal-file ../lic/data/goal-directed-sprints/ph-pkg-governance-exit-gates.md \
  --workflow-repo lic \
  --cwd ../lic \
  --agent code_implementer
```

### Completion gate

```bash
cd lic
bash scripts/ph-pkg-governance-gates.sh
```

## Tests / benches

| Path | Purpose |
|------|---------|
| `scripts/ph-pkg-governance-gates.sh` | Sprint completion (Gov-1…Gov-7) |
| `scripts/check-traceability.sh` | Gate 5/7 evidence |
| `curl -sf https://li-langverse.github.io/lic/` | Gate 3 Pages reachability |
| `LIC_ROOT=. python3 ../benchmarks/scripts/plan-completion-audit.py` | Audit regression |
| No tier-N bench | Policy/docs only |

## Provability

| G-* | Change |
|-----|--------|
| **G-meta** | **Partial → Partial** — doc hygiene only; governance docs ≠ proof certificate |
| **G-authz** | Unchanged (**Missing**) — out of scope |
| Honest limit | Closing checkboxes ≠ closing PH-Pkg master tracker; audit distinguishes `stale_spec_checklists` |

## Rollout

1. **`plan-approved`** on #476 → implementation agents run goal loop.
2. Single **lic** PR batching Gov-3 + Gov-7; Gov-1 human ack comment if needed.
3. Check off final governance sub-plan checkbox when Gov-3 merges.
4. **roadmap** agent-kit sync for Gov-6 if skill drift detected.
5. Refresh `benchmarks/data/latest/plan-completion-audit.json` on bot branch.
6. Close #476 when gate script + audit both green.

## north_star_fit

**Domain:** ecosystem governance / official packages · **PH ids:** PH-Pkg, 8-sync (notification track separate)
