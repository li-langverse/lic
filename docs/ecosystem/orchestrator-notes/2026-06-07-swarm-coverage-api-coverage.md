# Orchestrator note — swarm_coverage @ api-coverage (2026-06-07)

**Worker:** `4d1e1caf` · **Goal:** `swarm_coverage` · **north_star_fit:** ecosystem, ai  
**Evidence:** `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`, `swarm-gap-actions.json`, `lic/data/swarm-gap-registry/registry.yaml`

## Prep executed this cycle

| Step | Result |
|------|--------|
| `python3 scripts/ecosystem-quality-grade.py` (benchmarks) | **OK** — score 63.4, grade D, `unattended_safe=false` |
| `python3 scripts/swarm-gap-ingest.py` | **OK** after Path fallback fix (line 227–232) |
| `python3 scripts/swarm-gap-apply-actions.py` | **OK** — 62 open gaps; 19 backlog patches applied |

## Open gap reconcile (api-coverage lens)

| `gap_kind` | Open | Primary route | Swarm handoff (no lic systemd loops) |
|------------|------|---------------|--------------------------------------|
| `plan_debt` | 31 | Master-plan partials + runner todos | `plan_verifier` → `issue_planner`; sim/httpd/security via research goals |
| `competitor_feature` | 30 | verticals.toml + tier-1 red rows | `numerics_researcher` / `bench_improver` via `numerics_sota`, `md_sim_algorithms` |
| `missing_package` | 1 | `pkg-line-profiler` | `issue_planner` → `ecosystem-package-backlog.md` |
| `ui_ux` (studio) | 2 skipped | studio-ux-16/17 | Mount `lic-studio-ui` or handoff `gui_ux_tester` / `ui_ux_quality` goal |

### Priority handoffs (this audit)

1. **sim plan_debt** — `sim-p1-md-neighbor-cell`, `sim-p2-qm-dft-scf` patched → `code_implementer` via lic implement lane (aligns lic#977/#980/#1005 dedup).
2. **security-research** — `sec-r1-httpd-fuzz-smoke` patched → `security_auditor` / `offensive_security` goal (briefing P0 CWE).
3. **swarm-observer orch** — `orch-r3-missing-package-sweep`, `orch-r4-ui-ux-signals` still open; close on next snapshot refresh after studio-ui mount.
4. **ph-db** — 9 wp-* todos deferred (no backlog mapping); route via `database_platform` research goal, not new systemd loop.

## API surface gaps (control plane)

- **Missing MCP tools:** `read_ecosystem_quality_report`, `read_swarm_gap_registry` (li-ecosystem-context has briefing snapshot only).
- **Missing disk mirrors:** `/app/data/control-plane/state.json`, `latest-report.json` — observer cannot auto-heal.
- **Grader path drift:** `runs_dir` → `/workspace/li-cursor-agents/data/runs` but org-research writes `/app/data/runs` → `runs_sampled=0`.
- **MCP briefing root:** `get_briefing_snapshot` reads `/app/fixtures/e2e-benchmarks/…` not `/workspace/benchmarks/…`.

## Do not auto-merge

- lic#992 governance exit gates (draft)
- lic md_neighbor PR stack (#967–#980) — human dedup
- benchmarks GPU picker stack (#406–#409) — human pick one
- lip#52 merge-approved — `pr_merger` only after gate
