# Orchestrator note — `orch-r5-api-coverage`

**Date:** 2026-06-06  
**Agent:** `swarm_observer` (worker `63010bbd`)  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `api-coverage`  
**Work item:** Gap registry ingest/apply API surface + briefing preflight coverage audit

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (60.9); `unattended_safe: false` |
| Gap pipeline | **Unblocked locally** — ingest + apply @ 2026-06-06T23:24:15Z; 62 open (was 64) |
| Ingest fix | `swarm-gap-ingest.py:227-229` Path fallback — **remediated** (env optional + syntax) |
| PyYAML | Installed via `apt` this cycle; **bake into org-research worker image** |
| API coverage gaps | MCP lacks `read_gap_registry` / `read_ecosystem_quality_report`; briefing org CI 404; agent-kit path missing |
| Unattended? | **No** — 32 failed PRs, 14 repos missing CI, preflight rate-limit |

---

## Programmatic prep (confirmed)

```bash
apt-get install -y python3-yaml   # worker image gap
cd /workspace/lic
python3 scripts/swarm-gap-ingest.py    # registry 92 rows; 62 open
python3 scripts/swarm-gap-apply-actions.py
# wrote benchmarks/data/latest/swarm-gap-actions.json @ 23:24:15Z
cd /workspace/benchmarks
python3 scripts/ecosystem-quality-grade.py  # 60.9 grade D @ 23:23:58Z
```

**Apply patches this cycle:** 19 backlog rows (sim, security-research, sim-md vertical stubs, pkg-line-profiler).  
**Deferred:** 9 master-plan `plan_debt` (no runner mapping), 9 ph-db todos, 2 studio-ui-ux (missing lic-studio-ui worktree).

---

## API-coverage reconciliation

| Surface | Status | Evidence | Handoff |
|---------|--------|----------|---------|
| `ecosystem-quality-report.json` | Present, refreshed | `benchmarks/data/latest/` | `ecosystem_grader` |
| `swarm-gap-actions.json` | Present, refreshed | @ 23:24:15Z | `gap_explorer` |
| `registry.yaml` | Present, 62 open | `lic/data/swarm-gap-registry/` | `plan_verifier` |
| `agent-briefing.json` | Present | @ 23:23Z; 2 preflight failures | supervisor |
| Control-plane CP JSON | **Bootstrapped** | `/app/data/control-plane/{state,latest-report}.json` | `li-cursor-agents` PR |
| MCP gap/grade readers | **Missing** | no tool in li-ecosystem-context | `li-cursor-agents` issue |
| `verticals.toml` ingest | **0 stubs** | path `benchmarks/workloads/competitive/` not mounted; gap-infra row open | `docs_maintainer` |
| org CI audit API | **403/404** | `org_ci_audit` exit 1 | human + backoff |
| Goal snapshot API | **Stale** | snapshot @ 2026-05-30 | `plan_verifier` |

---

## Swarm routing (no new systemd loops)

| Next agent | Reason |
|------------|--------|
| `pr_merger` | lip#52 merge-approved, gate ready |
| `ci_maintainer` | 14 repos missing CI; 32 failed PRs |
| `gap_explorer` | 62 open registry rows; competitor_feature=30 |
| `plan_verifier` | Refresh snapshot + plan audit preflight |
| `issue_planner` | `pkg-line-profiler` + std module backlog |
| `numerics_researcher` | sim backlog todos patched (p1 dot/axpy, md neighbor, qm dft) |

**north_star_fit:** ecosystem orchestration API completeness supports proof-before-perf dispatch (PH-IO-4/5/7 package gaps routed, not implemented here).

---

## orch-r3 / orch-r4 status

- `orch-r3-missing-package-sweep`: functionally complete (ingest+apply); registry row still `open` until snapshot refresh marks todo done.
- `orch-r4-ui-ux-signals`: prior ux pass @ 22:54Z; studio-ux-16/17 backlog path missing in container.

---

## Related

- Whitepaper: `lic/docs/research/swarm_coverage/api-coverage/2026-06-06-whitepaper-63010bbd.md`
- Run report: `/app/data/runs/swarm_observer-1780787402802.md`
- Prior dimension passes: `org-research-audit.jsonl` (ux @ 22:54Z, performance @ 22:15Z)
