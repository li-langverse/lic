# Swarm gap orchestration — API coverage whitepaper

**Goal:** `swarm_coverage`  
**Dimension:** `api-coverage`  
**Date:** 2026-06-06  
**north_star_fit:** ecosystem, ai — proof-before-perf orchestration (no product shortcuts)

## Abstract

This pass audits whether the Li agent swarm has sufficient **API and script surface** to run gap registry ingest, backlog apply, and meta-health observation without human intervention. Grade **C** (73.6); `unattended_safe: false`.

## Coverage matrix

### MCP (li-ecosystem-context)

| Tool | Used | Gap |
|------|------|-----|
| `get_briefing_snapshot` | Yes | — |
| `list_pending_handoffs` | Yes | Empty; no enqueue API |
| `read_ecosystem_quality_report` | **Missing** | Observer reads filesystem manually |
| `read_swarm_gap_registry` | **Missing** | Observer reads YAML manually |

### Preflight / briefing scripts

| Script | Exit | API signal |
|--------|------|------------|
| `ecosystem-audit.py` | 0 | 77 open PRs, 38 failed CI |
| `org_ci_audit.py` | 1 | GitHub rate limit — incomplete repo list |
| `org_agent_kit_audit.py` | 1 | `/workspace/roadmap/agent-kit` missing |
| `workspace-dirty-sweep.py` | 0 | clean |
| `agent_deliverable_gate` | skipped | `LI_CURSOR_AGENTS_ENABLED=0` |

### Gap pipeline

```
swarm-gap-ingest.py  → registry.yaml (92 gaps, 62 open)
swarm-gap-apply-actions.py → swarm-gap-actions.json + backlog patches
```

**Blockers remediated this run:** ingest L229 syntax; PyYAML install.

**Remaining:** bake PyYAML in org-research image; merge lic ingest fix to main.

### Control plane

Expected artifacts missing on org-research host:

- `data/control-plane/latest-report.json`
- `data/control-plane/state.json`

Without these, programmatic observer cannot record `retry_counts` or dispatch healers.

## Recommendations (orchestration only)

1. Add MCP read tools for quality report + gap registry (api-coverage completeness).
2. Persist control-plane disk cache on Job exit.
3. Enable `LI_CURSOR_AGENTS_ENABLED=1` for deliverable gate in preflight.
4. Merge lic#884-class ingest fixes; unblock benchmarks metrics PR CI.

## Evidence paths

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1780725286338.md`
- `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-06-orch-api-coverage-bcb35ec7.md`

## Publish target (deferred)

`research-findings/whitepapers/2026-06/swarm_coverage/api-coverage/2026-06-06-whitepaper.md`
