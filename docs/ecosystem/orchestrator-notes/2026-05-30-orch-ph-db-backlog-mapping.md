# Orchestrator note — ph-db plan_debt backlog mapping

**Date:** 2026-05-30  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Work item:** Document 9 deferred `ph-db` plan_debt gaps that lack apply-actions backlog targets.

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded (recoverable)** — ecosystem grade **C** (79.5); `unattended_safe: true` |
| ph-db `plan_debt` open | **9** rows — all `deferred (no runner backlog mapping)` in apply-actions |
| ph-db runner | **stopped** — not in goal-directed snapshot runners list (orphan plan todos) |
| Action | Route via new backlog file + `research-goals.yaml` handoff; **no systemd plan loop** |

---

## Deferred gap ids

| Gap id | `plan_todo_id` | Suggested handoff |
|--------|----------------|-------------------|
| `gap-plan-pending-ph-db-wp-g-ci-cross-repo` | `wp-g-ci-cross-repo` | `ci_maintainer`, `issue_planner` |
| `gap-plan-pending-ph-db-wp-h-containers` | `wp-h-containers` | `issue_planner`, `package_architect` |
| `gap-plan-pending-ph-db-wp-k-postgres-nightly` | `wp-k-postgres-nightly` | `ci_maintainer` |
| `gap-plan-pending-ph-db-wp-pr-merge-wave` | `wp-pr-merge-wave` | `pr_merger`, `pr_alignment` |
| `gap-plan-pending-ph-db-wp-h0-default-main` | `wp-h0-default-main` | `ci_maintainer`, `docs_maintainer` |
| `gap-plan-pending-ph-db-wp-n3-realtime` | `wp-n3-realtime` | `issue_planner`, `package_architect` |
| `gap-plan-pending-ph-db-wp-n5-security-bench` | `wp-n5-security-bench` | `security_auditor` |
| `gap-plan-pending-ph-db-wp-d-registry-v2` | `wp-d-registry-v2` | `issue_planner` |
| `gap-plan-pending-ph-db-wp-prod-lidb-default` | `wp-prod-lidb-default` | `issue_planner`, `code_implementer` |

---

## Recommended next steps

1. Create `lic/docs/ecosystem/ph-db-plan-backlog.md` with checkbox todos mirroring the 9 rows above.
2. Extend `lic/scripts/swarm-gap-apply-actions.py` runner mapping: `ph-db` → `ph-db-plan-backlog.md`.
3. Add or enable `ph_db` research goal in `li-cursor-agents/config/research-goals.yaml` (if not present) — route to `issue_planner` / `ci_maintainer`, not a retired systemd loop.
4. Re-run ingest + apply; close registry rows when todos complete.

---

## Evidence paths

| Artifact | Path |
|----------|------|
| Apply manifest | `benchmarks/data/latest/swarm-gap-actions.json` (`suggested_new_loops` includes `ph-db`) |
| Gap registry | `lic/data/swarm-gap-registry/registry.yaml` |
| Meta audit | `benchmarks/data/runs/swarm_observer-1780172528837.md` |

---

## Human-only blockers

- **lidb default / prod rollout** — requires human approval for production posture changes.
- **Cross-repo CI** — touches multiple org repos; governance review before auto-PR.
