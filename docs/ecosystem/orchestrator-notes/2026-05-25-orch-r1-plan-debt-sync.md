# Orchestrator note — `orch-r1-plan-debt-sync`

**Date:** 2026-05-25  
**Agent:** `swarm_observer`  
**Branch:** `cursor/swarm-observer-plan-loop`  
**Work item:** Map goal-directed snapshot `plan_pending` per runner → registry `plan_debt`; patch loop backlogs where stale.

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** (ecosystem grade **D**, 62.4; `unattended_safe: false`) |
| Goal-directed loops | **Healthy** — 8 runners active |
| Gap registry | **~29 open** after sync (from 48): 5 `missing_package`, ~24 `plan_debt` |
| Unattended? | **No** — CI failures, preflight errors, stuck SDK runs |

Plan-debt sync closed duplicate httpd mirror rows, reconciled `completed_ids`, and fixed ingest/apply to use canonical `plan_todo_id` (no nested `gap-httpd-gap-*` backlog ids).

---

## Gap counts by `gap_kind`

| `gap_kind` | Open (post-sync) | Closed this cycle | Discoverer |
|------------|------------------:|------------------:|------------|
| `missing_package` | 5 | 0 | `gap_explorer` |
| `plan_debt` | ~24 | ~19 | `plan_verifier`, snapshot |
| `competitor_feature` | 0 | — | `gap_explorer` (orch-r2) |
| `ui_ux` | 0 | — | `gui_ux_tester` (orch-r4) |

---

## Scripts executed

```bash
python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py --dry-run
python3 scripts/swarm-gap-apply-actions.py
SWARM_OBSERVER_REQUIRE_NOTE=docs/ecosystem/orchestrator-notes/2026-05-25-orch-r1-plan-debt-sync.md \
  ./scripts/swarm-observer-plan-gates.sh
```

---

## Backlog patches applied

| Target | Action |
|--------|--------|
| `docs/superpowers/plans/2026-05-16-li-httpd-plan.md` | Removed mirror orchestrator todos; `gap-phase2-mitigation-exploits` → completed |
| `docs/ecosystem/security-research-backlog.md` | Removed mirror rows; `sec-r0-cwe-delta` → completed |
| `docs/ecosystem/swarm-observer-plan-backlog.md` | `orch-r1` → completed |
| `scripts/swarm-gap-ingest.py` | normalize + reconcile + dedupe |
| `scripts/swarm-gap-apply-actions.py` | canonical backlog todo ids |

**Systemd:** No new lic plan loops.

---

## Self-heal actions (control plane)

- Ingest/apply hardened; httpd/security backlogs deduped.
- Registry rows closed when `state.completed_ids` matches.
- Next: snapshot writer dedupe (`goal-directed-agents-snapshot.py`), stuck SDK run sweep.

No product code in lic.

---

## Human-only blockers

40 failing PRs, 32 repos without CI, governance merges, `CURSOR_API_KEY` for SDK.

---

## Agent deliverable checklist

- [x] Ingest + apply-actions
- [x] Registry + orchestrator note
- [x] Gates OK
- [x] Report under `data/runs/`
