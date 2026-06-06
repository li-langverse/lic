# Orchestrator note — `orch-r7-api-coverage-handoffs`

**Date:** 2026-06-06  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage`  
**Dimension:** `api-coverage`  
**Worker:** `3ea0ca74`

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **C (71.3)**, `unattended_safe: false` |
| Gap registry open | **62** rows (`plan_debt` 31, `competitor_feature` 30, `missing_package` 1 open in registry) |
| Ingest/apply | **Blocked** — PyYAML missing; L229 syntax **fixed** this pass |
| API coverage | MCP briefing path wrong; 6 org repos 404; no MCP gap/scorecard readers |
| Unattended? | **No** |

---

## Programmatic prep status

| Step | Command | Status |
|------|---------|--------|
| Ingest | `lic/scripts/swarm-gap-ingest.py` | ❌ PyYAML required (syntax fixed) |
| Apply | `lic/scripts/swarm-gap-apply-actions.py` | ❌ PyYAML required |
| Scorecard | `benchmarks/scripts/ecosystem-quality-grade.py` | ✅ with `LI_CURSOR_AGENTS_ROOT=/app` |

---

## API-coverage handoff map (open gaps → swarm agents)

### `missing_package` → `issue_planner`

| gap_id | target_todo | handoff |
|--------|-------------|---------|
| `gap-line-profiler-001` | `pkg-line-profiler` | `issue_planner` |

(`pkg-std-summary`, `pkg-std-plot` closed in registry; verify on next ingest.)

### `plan_debt` with backlog patches (from last apply 2026-05-31)

| Runner | plan_todo | handoff agent / goal |
|--------|-----------|----------------------|
| `sim` | `sim-p1-num-dot-axpy`, `sim-p1-md-neighbor-cell`, `sim-p2-qm-dft-scf` | `numerics_researcher` → `md_sim_algorithms` |
| `sim-md-research` | `md-r3-oracle-plan` | `numerics_researcher` (sim worktree) |
| `sim-chem-research` | `chem-r2-dft-scf-gap`, `chem-r3-package-placement` | `numerics_researcher` → `chem_sim_algorithms` |
| `security-research` | `sec-r1/2/3-*` | `security_auditor` → `offensive_security` |
| `studio-ui-ux` | `studio-ux-21/24` | `gui_ux_tester` → `ui_ux_quality` (needs `lic-studio-ui` mount) |
| `ph-db` | 9 todos | **Deferred** — no backlog mapping in apply script |

### `competitor_feature` — research lane (no new systemd loops)

| Class | Examples | handoff |
|-------|----------|---------|
| Tier-1 red benches | `matmul_naive`, `num_gmres`, `num_opt_line_search` | `bench_improver`, `autoresearch` |
| HPC library gaps | Kokkos, PETSc, hypre, FFTW | `numerics_researcher` → `scientific_distributed_computing` |
| Vertical stubs | `md_lennard_jones`, `qm_dft`, `drug_litl` | `numerics_researcher` + sim backlogs |

### Swarm-observer orch todos

| plan_todo | registry gap | action |
|-----------|--------------|--------|
| `orch-r3-missing-package-sweep` | open | Close after ingest + `issue_planner` dispatch |
| `orch-r4-ui-ux-signals` | open | Link studio-ux-16/17; dispatch `gui_ux_tester` |

---

## Control-plane API gaps (this dimension)

1. **MCP `get_briefing_snapshot`** resolves fixture path, not `/workspace/benchmarks/data/latest/`.
2. **Missing MCP tools:** `read_gap_registry`, `read_ecosystem_quality_report`.
3. **404 repos:** `li-api-kit`, `li-research-gateway`, `li-research-ingest`, `li-research-mcp`, `li-sec-agent`, `token-telemetry-service` — audit cannot verify CI/API surface.
4. **Observer disk cache:** bootstrap `latest-report.json` / `state.json` when Supabase absent.

---

## Evidence paths

- Scorecard: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- Briefing: `/workspace/benchmarks/data/latest/agent-briefing.json`
- Gap registry: `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- Gap actions: `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- Observer report: `/app/data/runs/swarm_observer-1780763996698.md`
- Whitepaper: `/workspace/lic/docs/research/swarm_coverage/api-coverage/2026-06-06-whitepaper.md`

---

## Next dispatch order

1. `pr_merger` — lip#52  
2. `ci_maintainer` — 6 incomplete API repos + org CI  
3. `security_auditor` — CWE Top25 + `sec-r1-httpd-fuzz-smoke`  
4. `gap_explorer` — after PyYAML ingest unblocked  
5. `plan_verifier` — refresh snapshot + plan_audit preflight

**north_star_fit:** proof → easy → fast; orchestration only — no product code in `lic` this pass.
