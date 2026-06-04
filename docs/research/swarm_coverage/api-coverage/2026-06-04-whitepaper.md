# Swarm gap orchestration — API coverage dimension

**Goal:** `swarm_coverage`  
**Dimension:** `api-coverage`  
**Date:** 2026-06-04  
**Worker:** `fa3519e7`  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/api-coverage/2026-06-04-whitepaper.md` (staged under `lic/docs/research/` until publish repo is mounted)

## Abstract

Swarm gap orchestration depends on a small set of **machine-readable APIs**: briefing snapshots, gap registry YAML, gap-action JSON, MCP ecosystem tools, and lic diagnostic JSON. This pass audits **coverage and operability** of those surfaces for the 62-row open gap backlog—not application runtime APIs in product repos.

## 1. Orchestration API inventory

| Surface | Role | Coverage | Gap |
|---------|------|----------|-----|
| `agent-briefing.json` | Preflight + dispatch | **High** — 6k+ lines, `recommended_agents`, metrics | 8 scripts `--skip-slow`; 2 failures (GH 403, roadmap kit) |
| `ecosystem-quality-report.json` | Scorecard | **High** — 5 dimensions | `runs_sampled: 0` in fresh CP — blind to run errors |
| `registry.yaml` | Canonical gaps | **High** — 62 open | Ingest cannot refresh without PyYAML + ingest fix |
| `swarm-gap-actions.json` | Apply log | **Stale** (2026-05-31) | Re-run apply after image fix |
| MCP `li-ecosystem-context` | Agent read API | **7 tools** — briefing, packages, handoffs, repo search | No write path for gap rows (by design) |
| `lic check --format=json` / diagnose | Vision-LLM plan debt | **Partial** | `gap-plan-debt-lic-master-plan-vision-llm-*` open |

## 2. api-coverage findings (gap kinds)

### `missing_package` (3 open)

- **`gap-line-profiler-001`** — no std/HPC line profiler hook; route `issue_planner` → `docs/ecosystem/ecosystem-package-backlog.md`.
- Closed std modules (`std.io`, `std.csv`, `std.summary`, `std.plot`) demonstrate backlog API works when ingest/apply runs.

### `plan_debt` (31 open)

- **Vision-LLM JSON API** — highest leverage for agent self-service; handoff `issue_planner`.
- **Runner snapshots** (sim, chem, security-research, ph-db, studio-ui-ux) — patched in last successful apply; implement via research goals, not new systemd loops.

### `competitor_feature` (30 open)

- **`gap-infra-verticals-toml-missing-benchmarks-main`** — blocks `ingest_verticals_stubs()` API path; requires benchmarks `verticals.toml` on `main`.
- Tier-1 red benches — handoff `bench_improver` / `numerics_researcher` after catalog CI green.

## 3. Operability blockers (API runtime)

```text
swarm-gap-ingest.py:229  — SyntaxError on main (Path fallback)
swarm-gap-*               — PyYAML required; not in container
org_ci_audit              — GitHub REST 403 rate limit
```

**Local fix validated:** default `BENCHMARKS_COMPETITIVE` → `{LANGVERSE}/benchmarks/competitive/verticals.toml` (branch `fix/swarm-gap-ingest-api-coverage-fa3519e7`).

## 4. Recommendations

1. Merge lic ingest Path PR stack; bake `python3-yaml` in agent image.
2. Refresh `swarm-gap-actions.json` after ingest; enqueue `gap_explorer` + `ci_maintainer`.
3. Complete Vision-LLM JSON diagnostics plan debt for agent API completeness.
4. Publish this doc to `research-findings` when repo available.

## References

- `benchmarks/data/latest/ecosystem-quality-report.json`
- `lic/data/swarm-gap-registry/registry.yaml`
- `li-cursor-agents/docs/ecosystem/research-verticals.md` — `swarm_coverage` goal row
- Observer run: `li-cursor-agents/data/runs/swarm_observer-1780606004228.md`
