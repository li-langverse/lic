# Orchestrator note — `orch-r14-performance-gap-orchestration`

**Date:** 2026-06-08  
**Agent:** `swarm_observer`  
**Worker:** `5bc2e236`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `performance`  
**Work item:** Reconcile performance-related gap rows; route PH-7e numerics + httpd wrk soak without new systemd loops

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (65.3); `unattended_safe: false` |
| Gap registry | **64 open** (`plan_debt` 31, `competitor_feature` 30, `missing_package` 3) |
| Ingest/apply | **Blocked** — `swarm-gap-ingest.py:229` syntax **remediated**; PyYAML still missing in container |
| Performance lens | Control-plane **orchestration latency** + **numerics yellow** (`num_eig_symmetric`, `num_root_newton`) dominate; proof-before-perf holds |
| Unattended? | **No** — briefing P0 (`pr_merger`, `ci_maintainer`) not yet executed this tick; gap pipeline incomplete |

Evidence: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`, `/workspace/benchmarks/data/latest/agent-briefing.json`, `/workspace/lic/data/swarm-gap-registry/registry.yaml`.

---

## Performance gap taxonomy (Mode B reconcile)

| `gap_kind` | Performance-relevant rows | Primary discoverer | Swarm route |
|------------|---------------------------|-------------------|-------------|
| `plan_debt` | `gap-plan-pending-httpd-gap-phase2-perf-wrk-soak`, sim `sim-p1-num-dot-axpy`, `sim-p2-qm-dft-scf`, PH-7e partial rows | `plan_verifier` | `numerics_researcher` / implement lane — **not** `install-goal-plan-loop-systemd.sh` |
| `competitor_feature` | 30 open (verticals.toml stubs) | `gap_explorer` | `numerics_researcher` + `md_sim_algorithms` / `chem_sim_algorithms` research goals |
| `missing_package` | `gap-line-profiler-001` (HPC profiling) | `gap_explorer` | `issue_planner` → `package_architect` |
| `ui_ux` | studio palette/GPU recovery (lic#575) | `gui_ux_tester` | `ui_ux_quality` goal — separate from PH-7e |

### PH-7e numerics (proof → fast)

Briefing `ecosystem_audit.benchmarks` (2026-06-01 matrix):

- **Yellow:** `num_eig_symmetric`, `num_root_newton`
- **Near threshold (ratio_vs_cpp > 1.18):** `num_opt_bfgs`, `num_integ_*`, `num_cg`
- **Green:** 145 workloads

**Handoff:** `bench_improver` + `numerics_researcher` (`numerics_sota`, `md_sim_algorithms`) — cite PH-7e; no `trusted.lean` auto-merge.

### httpd performance soak

Registry rows `gap-plan-pending-httpd-gap-phase2-perf-wrk-soak` (+ deduped variants) map to httpd runner `plan_pending`. Route via implement lane / `goal_researcher` (`server_platform`) after proof gates — wrk soak is observability, not codegen shortcut.

---

## Scripts (this pass)

```bash
# Syntax fix applied (line 229 Path fallback)
cd /workspace/lic && python3 scripts/swarm-gap-ingest.py
# → swarm-gap-ingest: PyYAML required (pip install pyyaml)

python3 scripts/swarm-gap-apply-actions.py
# → swarm-gap-apply-actions: PyYAML required
```

**Remediation shipped:** `_verticals_toml_candidates()` in `scripts/swarm-gap-ingest.py` — multi-path `verticals.toml` resolution.

**Still blocked:** PyYAML not in org-research Job image (`pip`/`apt` unavailable).

---

## Swarm routing (no new registry ids)

| Priority | Agent | Reason |
|----------|-------|--------|
| P0 | `pr_merger` | lip#52 gate-ready (deploy-pages bump) |
| P0 | `ci_maintainer` | 12 repos missing CI on main |
| P1 | `bench_improver` | Close yellow `num_eig_symmetric`, `num_root_newton` |
| P1 | `numerics_researcher` | PH-7e / sim-algo backlog patches (`md_sim_algorithms`, `chem_sim_algorithms`) |
| P1 | `gap_explorer` | 64 open gaps; `verticals.toml` stubs after ingest green |
| P2 | `plan_verifier` | 31 `plan_debt` rows + skipped `plan_audit` preflight |
| P2 | `security_auditor` | CWE Top-25 catalog delta (19 missing) — parallel security lane |

**Do not:** spawn lic systemd plan loops; merge governance/provability PRs without human review.

---

## Human-only blockers

- **lic#436** — swarm-gap-registry merge conflict (if still open on main)
- **lip#52** — protected-branch merge policy
- **lis#40–#42** — failing CI on registry/MCP/edge PRs
- **PyYAML bake** — `li-cursor-agents` org-research image
- **`trusted.lean`** — never auto-merge

---

## Related artifacts

- Observer report: `/app/data/runs/swarm_observer-1780895349832.md`
- Performance whitepaper (staging): `docs/research/swarm_coverage/performance/2026-06-08-whitepaper-5bc2e236.md`
- Scorecard: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` (regenerated 2026-06-08T05:31:53Z)
