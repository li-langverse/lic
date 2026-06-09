# Orchestrator note — `orch-r7-api-coverage` (worker `798a4302`)

**Date:** 2026-06-07  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `api-coverage`  
**Work item:** Reconcile swarm-gap registry apply + control-plane API surface gaps

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (69.6); `unattended_safe: false` |
| Gap registry | **62 open** (30 competitor, 31 plan_debt, 1 missing_package) after ingest @ 03:49:39Z |
| Gap scripts | **Unblocked** — fixed `swarm-gap-ingest.py` Path fallback; installed `python3-yaml` |
| API coverage | **Partial** — briefing JSON + file artifacts OK; MCP briefing snapshot broken; no `read_gap_registry` MCP |
| Unattended? | **No** — preflight failures, 24 failed PRs, 14 repos missing CI, thin runs sample |

Programmatic prep confirmed:

```bash
cd /workspace/lic
python3 scripts/swarm-gap-ingest.py    # registry 92 rows; ingest OK after Path fix
python3 scripts/swarm-gap-apply-actions.py
# wrote benchmarks/data/latest/swarm-gap-actions.json (62 open)
```

---

## api-coverage reconciliation (Mode B)

| Surface | Status | Evidence | Action |
|---------|--------|----------|--------|
| `agent-briefing.json` | OK | `/workspace/benchmarks/data/latest/agent-briefing.json` | Keep preflight cadence |
| `ecosystem-quality-report.json` | OK (refreshed) | grade D @ 03:49:35Z | Set `LI_CURSOR_AGENTS_ROOT=/app` in worker env |
| `swarm-gap-actions.json` | OK | 62 open @ 03:49:39Z | Re-run after snapshot refresh |
| MCP `get_briefing_snapshot` | **Broken** | expects `/app/fixtures/e2e-benchmarks/...` | Fix MCP root or mount briefing fixture |
| MCP gap registry reader | **Missing** | no tool in `li-ecosystem-context` | Add `read_swarm_gap_registry` |
| Control-plane disk API | **Bootstrapped** | `data/control-plane/state.json`, `latest-report.json` | Persist each supervisor tick |
| `LI_CURSOR_AGENTS_ROOT` | **Drift** | default `/workspace/li-cursor-agents` missing | Symlink or env default → `/app` |
| CVE catalog API | **19/25 Top25 missing** | `security-cwe-feed.json` | Handoff `security_auditor` (human-gated) |

---

## Open gap routing (this cycle)

| `gap_kind` | Open | Handoff |
|------------|------|---------|
| `missing_package` (1) | `gap-line-profiler-001` → `pkg-line-profiler` | `issue_planner` |
| `plan_debt` (31) | sim/security/studio/ph-db rows | `plan_verifier`, `implementation_gaps` |
| `competitor_feature` (30) | tier-1 reds + vertical stubs | `gap_explorer`, `numerics_researcher`, `bench_improver` |
| `ui_ux` (0 registry) | studio-ux-16/17 pending in snapshot | `gui_ux_tester` via `ui_ux_quality` goal |

Do **not** recommend `install-goal-plan-loop-systemd.sh` — route via `li-cursor-agents` research/implement goals.

---

## Registry plan-debt rows (swarm-observer)

- `orch-r3-missing-package-sweep` — **close on next ingest** (std.summary/plot closed in registry; line-profiler remains open)
- `orch-r4-ui-ux-signals` — deferred to `gui_ux_tester` + benchmarks GPU picker stack (#400–409)
- `orch-r7-api-coverage` — **this note**; close when MCP + CP path fixes land

---

## Human-only

- CWE Top25 catalog backfill (19 rows) — security governance
- Merge lip#52 — `pr_merger` only with human gate if needed
- Consolidate benchmarks GPU chip picker PR stack (#147)
- `trusted.lean` / governance PRs — never auto-merge

---

## Evidence paths

- `lic/data/swarm-gap-registry/registry.yaml`
- `benchmarks/data/latest/swarm-gap-actions.json`
- `benchmarks/data/latest/ecosystem-quality-report.json`
- `benchmarks/data/latest/agent-briefing.json`
- `li-cursor-agents/data/control-plane/latest-report.json` (bootstrapped)
- Whitepaper: `lic/docs/research/swarm_coverage/api-coverage/2026-06-07-whitepaper-798a4302.md`
