# Swarm gap orchestration — api-coverage dimension

**Goal:** `swarm_coverage`  
**Dimension:** `api-coverage`  
**Date:** 2026-06-04  
**Author:** `swarm_observer` (worker `be3500c1`)  
**Publish target:** `research-findings/whitepapers/swarm_coverage/api-coverage/2026-06-04-whitepaper.md` (staged)

---

## Abstract

This pass audits **machine-consumable API surfaces** that bind the Li agent swarm: compiler/agent JSON diagnostics, briefing and gap-registry JSON contracts, and control-plane run persistence. Orchestration is **degraded** because the gap **ingest** script is syntactically broken and **apply** lacks PyYAML—freezing 64 registry rows. The highest-impact product API gap for agents remains **Vision-LLM JSON diagnostics** (`lic check --format=json`, `lic diagnose`); the highest-impact infra gap is **reliable vertical ingest** from `benchmarks/competitive/verticals.toml`.

---

## 1. Scope (api-coverage × swarm_coverage)

| Layer | Artifacts | Coverage question |
|-------|-----------|-------------------|
| Compiler → agent | `lic check --format=json`, `lic diagnose` | Can agents parse failures without scraping stderr? |
| Briefing | `agent-briefing.json` | Are preflight APIs complete (not `--skip-slow`)? |
| Gap pipeline | `registry.yaml` → `swarm-gap-actions.json` | Does ingest→apply API run deterministically? |
| Quality score | `ecosystem-quality-report.json` | Does `runs_dir` resolve to live agent runs? |
| Control plane | `agent_runs`, `state.json` mirror | Are runs finalized and queryable? |

---

## 2. Findings

### 2.1 Vision-LLM agent JSON (product API)

Registry row `gap-plan-debt-lic-master-plan-vision-llm-llm-first-agent-json-` documents **partial** coverage: structured check output exists; full agent-first diagnostic loop is not closed. **Recommendation:** `plan_verifier` opens/updates master-plan exit gate; `issue_planner` files scoped issues—no `trusted.lean` changes via swarm.

### 2.2 Gap ingest Path API (orchestration)

```text
File ".../swarm-gap-ingest.py", line 229
SyntaxError: unterminated string literal
```

Broken fallback prevents `ingest_verticals_stubs()` from executing—**zero** new `competitor_feature` rows from `verticals.toml`. Fix is in flight: lic PR **#828** (`verticals.toml Path fallback`).

### 2.3 Apply-actions contract

`swarm-gap-actions.json` (2026-05-31) lists 64 open gaps; 22 backlog patches recorded. Without apply, sim/security/studio backlogs drift from registry. **Blocker:** PyYAML not in runtime.

### 2.4 Scorecard `runs_dir` API

Default `LI_CURSOR_AGENTS_ROOT` → `/workspace/li-cursor-agents` (missing) yielded `runs_sampled: 0` and falsely depressed `swarm_execution`. Override `LI_CURSOR_AGENTS_ROOT=/app` restores sampling. **Control-plane fix:** document default in benchmarks `env.defaults` or autodetect package mount.

### 2.5 Control-plane persist API

Historical org-research audits show `agent_runs upsert: undefined` — operators lack durable API to query failed meta-audits. Disk mirror (`state.json`, `latest-report.json`) absent in `/app/data/control-plane/` this run.

---

## 3. Metrics (2026-06-04)

| Metric | Value |
|--------|-------|
| Ecosystem grade | C (73.6) |
| Open registry gaps | 64 |
| Failed open PRs (CI) | 32 |
| Preflight failures | 2 (`org_ci_audit`, `org_agent_kit_audit`) |
| Ingest/apply success | 0/2 |

---

## 4. Recommendations

1. **Merge lic#828** — restore ingest Path API.  
2. **Ship PyYAML** in lic swarm prep image.  
3. **Set `LI_CURSOR_AGENTS_ROOT`** in grade + briefing preflight.  
4. **Dispatch `gap_explorer`** after ingest fix — vertical + catalog API coverage.  
5. **Human gate** benchmarks catalog PR stack before further agent catalog edits.

---

## 5. Evidence index

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/agent-briefing.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/lic/scripts/swarm-gap-ingest.py` (line 229 defect)
- `/app/data/runs/swarm_observer-1780584401691.md`
- `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-04-orch-api-coverage.md`

---

*north_star_fit: ecosystem orchestration supports provable, agent-first Li — JSON APIs before perf work (PH-2e, PH-2f, Vision-LLM).*
