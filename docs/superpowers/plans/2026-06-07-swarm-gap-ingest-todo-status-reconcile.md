---
workflow_repo: lic
issue: https://github.com/li-langverse/lic/issues/471
ph_ids: [PH-SIM, PH-UX, PH-H]
gap_ids: [G-orch-plan-debt]
status: plan-draft
north_star_fit: "Orchestration honesty — registry plan_debt must mirror goal-directed snapshot completion so swarm_observer and plan_verifier do not chase stale sim/studio/httpd gaps."
---

# Swarm-gap-ingest: reconcile plan_debt from todo.status (#471)

**Date:** 2026-06-07  
**Issue:** [lic#471](https://github.com/li-langverse/lic/issues/471)  
**Related:** [lic#436](https://github.com/li-langverse/lic/issues/436) (ingest path on main), [lic#619](https://github.com/li-langverse/lic/issues/619) (httpd reconcile — closed, plan-approved)  
**Owner agent:** `code_implementer` after `plan-approved`  
**Handoff after merge:** `swarm_observer` (re-run ingest + apply-actions)

## Executive summary

`scripts/swarm-gap-ingest.py` closes registry `plan_debt` rows only when a todo id appears in `runner.state.completed_ids`. Goal-directed runners (**sim**, **studio-ui-ux**, **httpd**) often mark completion via `todos[].status in {completed, done}` while `completed_ids` is empty or partial. That leaves stale open `gap-plan-pending-*` rows and blocks honest `swarm-gap-actions.json` backlog patches.

This plan extends reconcile to union `completed_ids` + completed todo statuses, reopens rows still in `plan_pending`, and adds smoke tests. No language/compiler changes.

## Problem (evidence 2026-05-30)

| Registry `gap_id` (open on main) | Snapshot evidence |
|----------------------------------|-------------------|
| `gap-plan-pending-sim-sim-p1-num-dot-axpy` | `sim` todo `status: completed`; `completed_ids: []` |
| `gap-plan-pending-sim-sim-p1-md-neighbor-cell` | same |
| `gap-plan-pending-studio-ui-ux-studio-ux-04-particle-display` … `-14` | `studio-ui-ux` todos `done`; partial `completed_ids` |
| `gap-plan-pending-httpd-gap-phase2-*` | `httpd` todos pending in `plan_pending` — must **stay open** until gates green (#619) |

Audit: `benchmarks/data/latest/plan-completion-audit.json` (`generated_at` 2026-05-30T01:25Z).  
Snapshot: `lic/data/goal-directed-agents/snapshot.json`.

## Vision / philosophy check

| Check | Result |
|-------|--------|
| Proof-before-perf | **Pass** — orchestration tooling only; no `trusted.lean` or compiler surface |
| Strict-by-default | **Pass** — improves honest gap register; does not weaken bench thresholds |
| Duplicate PH work | **Pass** — distinct from PH-SIM/PH-UX implementation; closes **registry sync** debt |
| #436 ingest on main | **Partial** — script + registry exist on main; reconcile logic still pre-#471 |

**Defer:** None. In scope for master-plan orchestration track.

## Learned from

1. [orch-r1-plan-debt-sync](../../ecosystem/orchestrator-notes/2026-05-25-orch-r1-plan-debt-sync.md) — first reconcile + dedupe cycle; `completed_ids`-only gap.
2. [orch-r0-ingest-snapshot](../../ecosystem/orchestrator-notes/2026-05-25-orch-r0-ingest-snapshot.md) — ingest/apply pipeline contract.
3. [lic#619](https://github.com/li-langverse/lic/issues/619) + draft PR [#879](https://github.com/li-langverse/lic/pull/879) — httpd reopen/close semantics and `_runner_completed_todo_ids` prototype.
4. [swarm-observer-plan-backlog](../../ecosystem/swarm-observer-plan-backlog.md) — programmatic prep before observer agent.

## Scope

### In scope

| WP | Deliverable |
|----|-------------|
| **WP-1** | `_runner_completed_todo_ids(runner)` — union `state.completed_ids` + `todos[].status in (completed, done)` with `_normalize_plan_todo_id` |
| **WP-2** | Replace `reconcile_snapshot_completed` → `reconcile_snapshot_plan_debt(snap, gaps)` returning `{closed, reopened}` |
| **WP-3** | Close open `plan_debt` when `norm in completed` and **not** in `plan_pending` |
| **WP-4** | Reopen closed `plan_debt` when `norm in plan_pending` (httpd wrk todos stay open until gates) |
| **WP-5** | `scripts/test-swarm-gap-ingest-reconcile.py` — sim close-without-completed_ids, httpd reopen-when-pending, studio close-on-done |
| **WP-6** | Post-merge: run ingest + apply-actions; commit registry delta; handoff `swarm_observer` |

### Out of scope

- Weakening `threshold_ratio_cpp` or bench gates to close rows
- Merging duplicate httpd PRs (#841–#898) — pick one implementer PR after this plan merges
- Resolving all open `plan_debt` on master plan (audit `master_plan_open` rows) — separate `plan_verifier` cycle

## Implementation sketch

```python
def _runner_completed_todo_ids(runner: dict) -> set[str]:
    rid = runner.get("id") or "runner"
    done = {_normalize_plan_todo_id(str(t), rid)
            for t in runner.get("state", {}).get("completed_ids") or []}
    for todo in runner.get("todos") or []:
        if isinstance(todo, dict) and todo.get("status") in ("completed", "done"):
            if tid := todo.get("id"):
                done.add(_normalize_plan_todo_id(str(tid), rid))
    return done

def reconcile_snapshot_plan_debt(snap, gaps_by_id) -> dict[str, int]:
    # Build runner_pending[rid] from plan_pending
    # Build runner_completed[rid] from _runner_completed_todo_ids
    # For each plan_debt gap with runner_id + plan_todo_id:
    #   if norm in pending and status closed → reopen
    #   elif norm in completed and not in pending and status open → close
```

**Main stats key:** `plan_debt_reconcile` (replaces `snapshot_completed` int).

**Path fix (bundled):** `ingest_verticals_stubs` `Path(...)/verticals.toml` syntax — already fixed in #879; include if still broken on target branch.

## PH / REQ / G-* mapping

| ID | Role |
|----|------|
| **G-orch-plan-debt** | Orchestration gap register honesty (not in provability-gaps.md — ecosystem orchestration) |
| **PH-SIM** | Stale `gap-plan-pending-sim-*` blocks sim backlog patches |
| **PH-UX** | Stale `gap-plan-pending-studio-ui-ux-*` blocks studio capture/bench handoffs |
| **PH-H** | httpd rows must reconcile with **plan_pending** + gate evidence (#477), not todo.status alone |
| **REQ-orch-ingest-01** | `swarm-gap-ingest.py` runs without YAML error on lic main |
| **REQ-orch-ingest-02** | Reconcile idempotent: second run `closed=0 reopened=0` on unchanged snapshot |

## Tests & verification

```bash
# Unit smoke (no PyYAML registry write)
python3 scripts/test-swarm-gap-ingest-reconcile.py

# Dry-run ingest against live snapshot
python3 scripts/swarm-gap-ingest.py --dry-run

# Full cycle (after human review of registry diff)
python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py --dry-run
python3 scripts/swarm-gap-apply-actions.py
```

**Expected post-ingest (2026-05-30 snapshot):**

- Close: `gap-plan-pending-sim-sim-p1-num-dot-axpy`, `gap-plan-pending-sim-sim-p1-md-neighbor-cell`, completed studio-ui-ux rows not in `plan_pending`
- Stay open: httpd `gap-phase2-perf-wrk-soak`, `gap-phase2-streaming-wrk` (still in `plan_pending`)
- Stay open: studio todos still `pending` (`studio-ux-16`, `studio-ux-17`, …)

## Acceptance criteria

- [ ] `reconcile_snapshot_plan_debt` honors `todos[].status in {completed, done}`
- [ ] Smoke tests pass in CI (add to existing Python lint job or `scripts/run-ci-tests.sh` slice)
- [ ] `python3 scripts/swarm-gap-ingest.py --dry-run` reports `plan_debt_reconcile` with `closed > 0` for sim/studio stale rows
- [ ] httpd wrk rows reopen/remain open per `plan_pending` (no false close)
- [ ] `benchmarks/data/latest/swarm-gap-actions.json` regenerates after apply-actions
- [ ] `swarm_observer` handoff note filed under `docs/ecosystem/orchestrator-notes/`
- [ ] Close #471 when ingest evidence on main; #436 when ingest path fully unblocked (no conflict markers, reconcile shipped)

## Agent dispatch

| Step | Agent | Action |
|------|-------|--------|
| 1 | `code_implementer` | Implement WP-1–5 on branch `plan/471-swarm-gap-todo-reconcile`; open PR; **do not self-merge** |
| 2 | `swarm_observer` | Post-merge ingest + apply-actions + orchestrator note |
| 3 | `plan_verifier` | Confirm `plan-completion-audit.json` open count drops for reconciled runners |

**PR-only.** No Actions `schedule:` cron. No secrets in plan or registry commits.

## Completion gate

```bash
python3 scripts/test-swarm-gap-ingest-reconcile.py
python3 scripts/swarm-gap-ingest.py --dry-run | grep plan_debt_reconcile
# After merge + live ingest:
grep -c 'status: open' data/swarm-gap-registry/registry.yaml  # expect drop vs pre-merge baseline
test -f ../benchmarks/data/latest/swarm-gap-actions.json
```
