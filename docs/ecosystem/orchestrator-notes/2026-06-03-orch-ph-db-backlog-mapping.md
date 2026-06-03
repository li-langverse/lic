# Orchestrator: PH-DB backlog mapping (plan-loop supervisor)

**Date:** 2026-06-03  
**Runner:** `ph-db`  
**Plan loop:** [2026-06-03-ph-db-plan-loop.md](../../superpowers/plans/2026-06-03-ph-db-plan-loop.md)  
**Canvas:** [ph-db-swarm-plan.md](../../superpowers/plans/ph-db-swarm-plan.md)  
**Issue:** [lic#576](https://github.com/li-langverse/lic/issues/576)

## Summary

Wire nine `plan_debt` registry rows (`gap-plan-pending-ph-db-wp-*`) to the **ph-db plan-loop YAML** and async swarm agents. Reconcile stale **2026-05-30** snapshot (9 pending) with **2026-06-03** canvas (2 pending: `wp-h-containers`, `wp-prod-lidb-default`).

## Programmatic prep

```bash
cd lic
python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py --dry-run
python3 scripts/swarm-gap-apply-actions.py
python3 scripts/goal-directed-agents-snapshot.py
```

`swarm-gap-apply-actions.py` maps `runner_id: ph-db` → `docs/superpowers/plans/2026-06-03-ph-db-plan-loop.md`.

## Handoff table

| plan_todo_id | gap_id | to_agent | workflow_repo | Backlog target |
|--------------|--------|----------|---------------|----------------|
| wp-g-ci-cross-repo | gap-plan-pending-ph-db-wp-g-ci-cross-repo | ci_maintainer | li-cursor-agents | implement-goals `ph_db_sprint` slice G |
| wp-h-containers | gap-plan-pending-ph-db-wp-h-containers | code_implementer | lis | plan-loop todo + lis branch |
| wp-k-postgres-nightly | gap-plan-pending-ph-db-wp-k-postgres-nightly | ci_maintainer | benchmarks | nightly workflow (dispatch) |
| wp-pr-merge-wave | gap-plan-pending-ph-db-wp-pr-merge-wave | pr_merger | lic | org-pr-merge queue |
| wp-h0-default-main | gap-plan-pending-ph-db-wp-h0-default-main | ci_maintainer | lidb | admin script |
| wp-n3-realtime | gap-plan-pending-ph-db-wp-n3-realtime | code_implementer | lis | lis#10 |
| wp-n5-security-bench | gap-plan-pending-ph-db-wp-n5-security-bench | bench_improver | benchmarks | benchmarks#96 |
| wp-d-registry-v2 | gap-plan-pending-ph-db-wp-d-registry-v2 | issue_planner | lidb, lip | PH-8d-v2 human gate |
| wp-prod-lidb-default | gap-plan-pending-ph-db-wp-prod-lidb-default | human | li-cursor-agents | production profile |

## Close registry row (per todo)

1. Mark todo `status: completed` in **both** plan-loop YAML and swarm canvas.
2. Re-run ingest + apply-actions (above).
3. Confirm `gap-plan-pending-ph-db-wp-*` absent or `status: closed` in `data/swarm-gap-registry/registry.yaml`.
4. Refresh snapshot; `plan_pending` for ph-db should be empty (or only human-deferred prod flip).

## Deferred / human-only

- **wp-prod-lidb-default** — production store flip; requires human `plan-approved` on ops runbook.
- **wp-d-registry-v2** — PH-8d-v2 remote registry v2 blocked on PH-DB-4 human sign-off ([#423](https://github.com/li-langverse/lic/issues/423)).
- New org repo — not in scope; see [governance](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/governance.md).

## Acceptance mapping (lic#576)

| # | Acceptance | This note + plan-loop PR |
|---|------------|--------------------------|
| 1 | Wire ph-db runner to plan-loop supervisor | `ph-db-plan-loop.py` + `implement-goals.yaml` `ph_db_sprint` |
| 2 | Map wp-* → agents + `swarm-gap-apply-actions.py` | `RUNNER_BACKLOGS["ph-db"]` + table above |
| 3 | Close registry on todo complete | § Close registry row |
