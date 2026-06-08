# Orchestrator note — `orch-r17-api-coverage-gap-orchestration`

**Date:** 2026-06-08  
**Agent:** `swarm_observer`  
**Worker:** `bbcdbaea`  
**Dimension:** `api-coverage`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Work item:** Unblock competitive-vertical API ingest path; reconcile org repo API 404 gaps

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded (critical recovery)** — grade **D** (60.9); `unattended_safe: false` |
| `orch-r17` | **In progress** — ingest syntax fixed locally; apply blocked by missing PyYAML |
| API-coverage signal | 12 stub verticals in `verticals.toml`; 25 org repos HTTP 404 |
| Gap registry | 64 open (frozen @ 2026-05-31) — re-ingest pending infra |
| Unattended? | **No** — gap pipeline + CI failures require human or infra PR |

---

## API-coverage reconciliation

### Competitive vertical stubs (`ingest_verticals_stubs`)

| Source | Path | Status |
|--------|------|--------|
| Vertical registry | `benchmarks/workloads/competitive/verticals.toml` | 12 `workload_class = "stub"` rows |
| Ingest function | `lic/scripts/swarm-gap-ingest.py` → `ingest_verticals_stubs()` | **Blocked** — line 229 SyntaxError on main |
| Default env | `BENCHMARKS_COMPETITIVE` → `benchmarks/workloads/competitive` | Fixed in local diff (this pass) |

**Fix applied (local, pending PR):**

```python
vert = Path(
    os.environ.get("BENCHMARKS_COMPETITIVE", str(LANGVERSE / "benchmarks/workloads/competitive"))
) / "verticals.toml"
```

### Org GitHub API coverage (`org_ci_audit`)

| Signal | Count | Evidence |
|--------|-------|----------|
| `repos_audit_incomplete` | 25 | `org-repo-ci-audit.json` — `gh: Not Found (HTTP 404)` |
| `repos_missing_ci_main` | 12 | `ecosystem-audit.json` metrics |
| Examples | li-api-kit, li-os, li-research-mcp | phantom or private repos in catalog |

**Action:** `ci_maintainer` + human catalog prune — do not auto-create repos.

---

## Scripts attempted

```bash
cd /workspace/benchmarks && python3 scripts/ecosystem-quality-grade.py
# → 60.9 grade D unattended_safe=False

cd /workspace/lic && python3 scripts/swarm-gap-ingest.py
# → SyntaxError line 229 (remediated locally)

python3 scripts/swarm-gap-apply-actions.py
# → PyYAML required (not installed in worker)
```

---

## Swarm routing (no new systemd loops)

| Next agent | Reason | north_star_fit |
|------------|--------|----------------|
| `gap_explorer` | Re-run vertical stub ingest after PyYAML + syntax fix land | ecosystem, PH-catalog |
| `ci_maintainer` | 12 missing CI + 25 org 404 audit gaps | ecosystem |
| `plan_verifier` | `plan_audit` skipped; 31 plan_debt registry rows | provable |
| `issue_planner` | 3 `missing_package` backlog todos still pending | easy, ecosystem |

**Config touchpoints (no edits this pass):**

- `li-cursor-agents/config/research-goals.yaml` — `swarm_coverage` already enabled, priority 10
- `li-cursor-agents/config/implement-goals.yaml` — no new rows required

---

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/benchmarks/benchmarks/workloads/competitive/verticals.toml`
- `/workspace/benchmarks/data/latest/org-repo-ci-audit.json`
- `/app/data/runs/swarm_observer-1780908855046.md`

---

## Deferred

- Merge ingest fix PR on `lic` (coordinate with open lic#1332 stack)
- Bake `python3-yaml` in org-research worker (`li-cursor-agents` deploy)
- Live registry refresh after ingest unblocks
- `orch-r3` / `orch-r4` snapshot todos — mark complete when backlogs verified
