# Orchestrator note — `orch-org-packages` (worker `c92ad220`)

**Date:** 2026-06-09  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `org-packages`  
**Work item:** Reconcile org-wide package gaps, CI holes, and registry/backlog drift

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (66.3); `unattended_safe: false` |
| Open `missing_package` | **1** — `gap-line-profiler-001` (actions JSON stale at 3) |
| Std modules (PH-IO) | **4 closed** — io, csv, summary, plot shipped; registry ingest not refreshed |
| Org CI gaps | **12 flagged** — **10× HTTP 404** (phantom/unmounted); 2 need live verification |
| Gap ingest | **Blocked** — `PyYAML required` |
| Unattended? | **No** — ingest blocked, CP state missing, merge queue has failing PRs |

---

## Org-packages → swarm routing

| Gap / repo signal | Evidence | Handoff | Goal / agent |
|-------------------|----------|---------|--------------|
| `gap-line-profiler-001` | `ecosystem-package-backlog.md` → `pkg-line-profiler` **pending** | Open tracking issue | **`issue_planner`** → **`package_architect`** |
| std.summary / std.plot (closed) | Registry `closed`; actions still count as open | Re-ingest closes rows | **`swarm_observer`** after PyYAML |
| 12 missing CI repos | `agent-briefing.missing_ci_on_main` | Scaffold only after `gh repo view` OK | **`ci_maintainer`** |
| Agent-kit mount | `org_agent_kit_audit` stderr | Sync roadmap/agent-kit | **`agent_kit_maintainer`** |
| Catalog harness pending (114) | `catalog-audit.json` | Bench coverage, not new packages | **`bench_improver`** |

**Do not** create new agent registry ids or lic systemd plan loops.

---

## Registry reconciliation (post-PyYAML)

1. Run `lic/scripts/swarm-gap-ingest.py` — close `gap-missing-std-*` rows matching backlog `completed`.
2. Run `lic/scripts/swarm-gap-apply-actions.py` — idempotent; expect **1** open `missing_package` patch.
3. When `issue_planner` opens li-line-profiler issue → set `gap-line-profiler-001` status `handoff` (not product code in lic from observer).

---

## Ingest blocker (unchanged)

```bash
swarm-gap-ingest: PyYAML required (pip install pyyaml)
swarm-gap-apply-actions: PyYAML required
```

**Action:** bake `python3-yaml` in org-research worker image (`li-cursor-agents` deploy entrypoint). Merge **lic#1504** after CI green for ingest Path fallback on main.

---

## Swarm routing (no new systemd loops)

| Next agent | Reason |
|------------|--------|
| `pr_merger` | lip#52 merge-approved, gate ready |
| `ci_maintainer` | 12 repos missing CI (verify live first) |
| `issue_planner` | `pkg-line-profiler` pending — close `orch-r3` |
| `security_auditor` | 19 Top-25 CWE rows missing in catalog |
| `gap_explorer` | Post-PyYAML registry refresh + competitor rows |

---

## Open orch todos (swarm-observer runner)

| Todo | Status | Next step |
|------|--------|-----------|
| `orch-r3-missing-package-sweep` | **partial** | Close after `issue_planner` + ingest refresh |
| `orch-r4-ui-ux-signals` | open | Link studio-ui plan_debt → `ui_ux_quality` goal |

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/agent-briefing.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/docs/ecosystem/ecosystem-package-backlog.md`
- `/workspace/benchmarks/data/latest/org-repo-ci-audit.json`
- `/app/data/runs/swarm_observer-1780963994480.md`
