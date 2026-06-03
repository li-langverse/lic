# Orchestrator note — `swarm_coverage` @ `api-coverage` (orch-r5)

**Date:** 2026-06-03  
**Agent:** `swarm_observer`  
**Worker:** `308cd172`  
**Research goal:** `swarm_coverage`  
**Dimension:** `api-coverage`  
**north_star_fit:** ecosystem, ai — programmatic gap pipeline API audit  

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **C** (70.3); `unattended_safe: false` |
| Gap pipeline API | **Broken** — ingest syntax error + PyYAML missing on apply |
| Control-plane API | **Down** — MCP Postgres refused; no disk CP mirrors |
| Open gaps | **64** (31 plan_debt, 30 competitor_feature, 3 missing_package) |
| Briefing | Fresh 2026-06-03T23:14Z; heap → ci_maintainer + security_auditor |
| Unattended? | **No** — agents cannot refresh registry/actions without infra fixes |

Programmatic prep attempted:

```bash
cd /workspace/benchmarks && python3 scripts/ecosystem-quality-grade.py  # OK → 70.3
cd /workspace/lic && python3 scripts/swarm-gap-ingest.py                 # FAIL SyntaxError L229
cd /workspace/lic && python3 scripts/swarm-gap-apply-actions.py          # FAIL PyYAML required
```

---

## api-coverage matrix (gap orchestration surfaces)

| API | Status | Blocker |
|-----|--------|---------|
| Briefing JSON | ✅ | — |
| Ecosystem quality report | ✅ | regenerated this run |
| Registry YAML | ✅ read-only | apply stale |
| Ingest CLI | ❌ | L229 syntax |
| Apply CLI | ❌ | PyYAML |
| CP DB MCP | ❌ | ECONNREFUSED |
| CP disk cache | ❌ | not persisted in Job |
| Ecosystem MCP snapshot | ❌ | wrong fixture path |

---

## Open gap routing (no new systemd loops)

| Kind | Count | Route via |
|------|------:|-----------|
| `competitor_feature` | 30 | `numerics_researcher`, `bench_improver`, sim backlogs |
| `plan_debt` | 31 | `plan_verifier`, research goals (`md_sim_algorithms`, `database_platform`, `ui_ux_quality`) |
| `missing_package` | 3 | `issue_planner` → `ecosystem-package-backlog.md` |

**Sim plan_debt (patched backlogs, implement lane):**

- `sim-p1-num-dot-axpy`, `sim-p1-md-neighbor-cell`, `sim-p2-qm-dft-scf` → `md_sim_algorithms` / `chem_sim_algorithms`
- `md-r3-oracle-plan`, `chem-r2-dft-scf-gap`, `chem-r3-package-placement` → numerics research goals

**Security plan_debt:**

- `sec-r1-httpd-fuzz-smoke`, `sec-r2-tier5-gap-exploit`, `sec-r3-runtime-surface` → `offensive_security` / `security_auditor`

**Studio UI (ui_ux):**

- `studio-ux-16-palette-search-latency`, `studio-ux-17-gpu-fail-recovery` → `ui_ux_quality` → `gui_ux_tester`

**Ph-db plan_debt (9 rows, no backlog mapping):**

- Route via `database_platform` research goal + human ph-db plan — not lic systemd loop.

---

## Swarm-observer registry todos

| Todo | Status | Next step |
|------|--------|-----------|
| `orch-r3-missing-package-sweep` | open | Handoff `issue_planner` for pkg-line-profiler + std.plot/summary |
| `orch-r4-ui-ux-signals` | open | Link studio-ux-16/17 to `ui_ux_quality` goal |
| `orch-r5-api-coverage` | **this note** | Close on ingest when snapshot records completion |

---

## Human-only

- Fix ingest L229 on `lic` main via open PR (#774–#782 family) — do not bypass branch protection.
- Install PyYAML in org-research image — not pip in restricted Job pod.
- Restore Supabase for MCP SQL audits.
- Product CI on benchmarks#306, li-httpd#30, studio#67.

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/agent-briefing.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1780527805809.md`
- `/app/docs/research/swarm_coverage/api-coverage/2026-06-03-whitepaper.md`
