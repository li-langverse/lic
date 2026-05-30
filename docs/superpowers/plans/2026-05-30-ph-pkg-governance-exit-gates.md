# PH-Pkg ecosystem governance — close 7 stale exit gates (REQ-Pkg-GOV)

> **Issue:** [#476](https://github.com/li-langverse/lic/issues/476) · **Repo:** li-langverse/lic  
> **Vision:** secure (official package policy), easy (traceability + templates), provable (honest audit counts) · **Learned from:** [2026-05-16-li-ecosystem-governance.md](2026-05-16-li-ecosystem-governance.md), [plan-completion-audit.py](https://github.com/li-langverse/benchmarks/blob/main/scripts/plan-completion-audit.py), [official-packages.md](../../ecosystem/official-packages.md), [create-li-package skill](https://github.com/li-langverse/roadmap/tree/main/agent-kit/skills/create-li-package)

## Goal

Close the **7 open checkbox gates** in `2026-05-16-li-ecosystem-governance.md` that `plan-completion-audit.py` still reports as `plan_files_open`, with file/CI evidence per gate — without falsely marking the master-plan **PH-Pkg** tracker row complete (tracker is `[x]`; sub-plan gates are stale).

## Non-goals

- New org repos or GitHub org settings changes without human checklist ([governance](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/governance.md)).
- Compiler / language features (`plan-approved` required elsewhere).
- Self-merge of **roadmap** governance PRs.
- Weakening `plan-completion-audit` filters to hide gates.

## Dependencies

- **PH-Pkg** master-plan row (scaffold + governance stubs shipped).
- **8-sync** downstream notifications — separate track; do not conflate with these 7 gates.
- Human-only: `gh api orgs/li-langverse` confirmation if agent lacks org token (gate 1).
- **benchmarks** `plan-completion-audit.py` run with `LIC_ROOT` for verification JSON.

## Sub-phases

| Sub | Gate (from audit) | Deliverable | Exit gate |
|-----|-------------------|-------------|-----------|
| **Gov-1** | Confirm org access | Document agent/human procedure in governance plan § checklist; CI optional smoke | File cites `gh api orgs/li-langverse` success or explicit human-only block |
| **Gov-2** | `official-packages.md` PKG- table | Verify table complete vs monorepo packages; fix stale rows | Every listed std slice has `PKG-*` id + link |
| **Gov-3** | mkdocs `repo_url` / Pages | Align `mkdocs.yml` + satellite repo map with `li-langverse` URLs (#535 follow-up) | `mkdocs build --strict` green; no broken repo_url |
| **Gov-4** | User-facing `governance.md` summary | Ensure `docs/ecosystem/governance.md` stub points to normative plan | Link check in CI or handbook build |
| **Gov-5** | `scripts/templates/github-repo/` + `check-traceability.sh` | Template set matches governance § checklist; script in CI | `check-traceability.sh` exit 0 on example package |
| **Gov-6** | `create-li-package` `--official` → org checklist | Skill step links governance § repo creation | Skill diff reviewed; agent-kit sync PR |
| **Gov-7** | Example `PUBLISH.md` traceability block | One official package (e.g. `li-net-httpd`) has full REQ/PKG/T block | `plan-completion-audit` `plan_files_open` count drops for governance file |

## Tests / benches

| Path | Purpose |
|------|---------|
| `scripts/check-traceability.sh` | Gate 5/7 evidence |
| `mkdocs build --strict` | Gate 3 |
| `python3 ../benchmarks/scripts/plan-completion-audit.py` | Gate count regression (with `LIC_ROOT`) |
| No tier-N bench | Policy/docs only |

## Provability

| G-* | Change |
|-----|--------|
| **G-meta** | **Partial → Partial** — honest doc hygiene only; no claim that governance docs = proof |
| **G-authz** | Unchanged (**Missing**) — out of scope |
| Honest limit | Closing checkboxes ≠ closing PH-Pkg master tracker; audit distinguishes `stale_spec_checklists` |

## Rollout

1. Single **lic** PR batching Gov-2…Gov-7 doc/template fixes; Gov-1 human ack comment on #476.
2. **roadmap** agent-kit sync for Gov-6 (`./scripts/sync-agent-kit.sh` in benchmarks after roadmap merge).
3. Refresh `benchmarks/data/latest/plan-completion-audit.json` on bot branch.
4. Maintainer: **`plan-approved`** then **`plan-needed` removal** on #476.
