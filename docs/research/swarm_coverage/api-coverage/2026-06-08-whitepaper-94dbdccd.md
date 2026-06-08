# Swarm gap orchestration — API coverage whitepaper

**Goal id:** `swarm_coverage`  
**Dimension:** `api-coverage`  
**Worker:** `94dbdccd`  
**Run id:** `1780876447048`  
**Agent:** `swarm_observer`  
**Generated:** 2026-06-08T00:15Z  
**north_star_fit:** ecosystem, ai — provable unattended swarm requires stable read APIs for registry, scorecard, and control-plane state

**Publish target (when repo mounted):**  
`research-findings/whitepapers/2026-06/swarm_coverage/api-coverage/2026-06-08-whitepaper-94dbdccd.md`

---

## Abstract

Meta-agent `swarm_observer` under goal `swarm_coverage` depends on three evidence layers: (1) ecosystem quality scorecard, (2) swarm gap registry + apply actions, (3) control-plane observer state. This pass audits **API coverage** — MCP tools, environment contracts, and script dependencies — that enable or block unattended gap orchestration. Grade **D** (65.3) with `unattended_safe: false`. Primary blockers are missing PyYAML in the worker image, absent MCP read tools for gap artifacts, and non-persisted control-plane reports.

---

## Method

1. Regenerated `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`.
2. Read `/workspace/lic/data/swarm-gap-registry/registry.yaml` (62 open gaps).
3. Read stale `/workspace/benchmarks/data/latest/swarm-gap-actions.json` (2026-05-31).
4. Attempted `swarm-gap-ingest.py` + `swarm-gap-apply-actions.py`.
5. Queried MCP `list_pending_handoffs` (empty) and `get_briefing_snapshot` (fixture path failure).
6. Compared briefing `recommended_agents` vs research lane dispatch logs.

---

## Results

### Ecosystem quality (2026-06-08)

| Dimension | Score | Weight |
|-----------|------:|-------:|
| briefing_health | 69.0 | 0.15 |
| ecosystem_posture | 63.0 | 0.25 |
| goal_directed_health | 70.0 | 0.20 |
| swarm_execution | 65.0 | 0.25 |
| gap_pressure | 60.0 | 0.15 |
| **Overall** | **65.3 (D)** | |

`runs_sampled=0` — grade script `runs_dir` does not match live `/app/data/runs`.

### MCP api-coverage matrix

| Operation | MCP tool | Filesystem fallback | Worker status |
|-----------|----------|---------------------|---------------|
| Briefing snapshot | `get_briefing_snapshot` | `agent-briefing.json` | MCP **broken** (fixture path) |
| Pending handoffs | `list_pending_handoffs` | N/A | OK (empty) |
| Gap registry | — | `registry.yaml` | OK via read tool |
| Quality report | — | `ecosystem-quality-report.json` | OK via read tool |
| Gap actions | — | `swarm-gap-actions.json` | OK (stale) |
| Control-plane state | — | `state.json`, `latest-report.json` | **Missing** |

### Script API dependencies

| Script | Requires | Blocker |
|--------|----------|---------|
| `swarm-gap-ingest.py` | PyYAML, `LIC_ROOT`, optional `BENCHMARKS_COMPETITIVE` | SyntaxError L229 (fixed); PyYAML missing |
| `swarm-gap-apply-actions.py` | PyYAML, registry + backlogs | PyYAML missing |
| `ecosystem-quality-grade.py` | briefing, snapshot, runs dir | runs dir mismatch |

---

## Recommendations

1. **Add MCP read tools** in `li-cursor-agents/src/mcp/ecosystem-briefing-tools.ts`:
   - `read_gap_registry` → parse `registry.yaml`, return open counts by `gap_kind`
   - `read_ecosystem_quality_report` → latest scorecard JSON
   - `read_swarm_gap_actions` → apply artifact + patch list

2. **Worker entrypoint contract** — export on org-research Jobs:
   - `BENCHMARKS_ROOT=/workspace/benchmarks`
   - `LIC_ROOT=/workspace/lic`
   - `LI_CURSOR_AGENTS_ROOT=/app`
   - Install `python3-yaml`

3. **Observer persistence** — write `data/control-plane/state.json` and `latest-report.json` each tick.

4. **Merge lic ingest fix** — Path fallback for `verticals.toml` (line 229).

---

## Evidence index

| Artifact | Path |
|----------|------|
| Run digest | `/app/data/runs/swarm_observer-1780876447048.md` |
| Orchestrator note | `lic/docs/ecosystem/orchestrator-notes/2026-06-08-orch-r6-api-coverage-94dbdccd.md` |
| Quality report | `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` |
| Gap registry | `/workspace/lic/data/swarm-gap-registry/registry.yaml` |
| Gap actions | `/workspace/benchmarks/data/latest/swarm-gap-actions.json` |
| Briefing | `/workspace/benchmarks/data/latest/agent-briefing.json` |

---

## Validity

| Field | Value |
|-------|-------|
| status | `staging` |
| validity_grade | `C` — live gap apply not executed; MCP briefing probe failed |
| domains | ecosystem, ai |
