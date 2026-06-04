# Orchestrator note — swarm_coverage @ security (2026-06-04)

**Worker:** `eb399737`  
**Goal:** `swarm_coverage`  
**Dimension:** `security`  
**north_star_fit:** Swarm gap orchestration — registry, backlog apply, handoffs — domains: ecosystem, ai; security lens on CWE catalog, security-research backlog, httpd exploit parity.

## Evidence read

| Artifact | Path |
|----------|------|
| Ecosystem grade (refreshed) | `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` |
| Agent briefing | `/workspace/benchmarks/data/latest/agent-briefing.json` |
| Swarm gap actions (refreshed) | `/workspace/benchmarks/data/latest/swarm-gap-actions.json` |
| Gap registry | `/workspace/lic/data/swarm-gap-registry/registry.yaml` |
| CWE feed | `/workspace/benchmarks/data/latest/security-cwe-feed.json` |
| Security backlog | `/workspace/lic/docs/ecosystem/security-research-backlog.md` |
| Goal-directed snapshot | `/workspace/lic/data/goal-directed-agents/snapshot.json` (runner `security-research`) |
| Observer run digest | `/app/data/runs/swarm_observer-1780576297348.md` |

## Security gap reconcile (Mode B)

| Gap / todo | `gap_kind` | Action |
|------------|------------|--------|
| `gap-plan-pending-security-research-sec-r1-httpd-fuzz-smoke` | `plan_debt` | Patched → `security-research-backlog.md` (`sec-r1`, pending). Handoff **`security_auditor`** via goal `offensive_security` — not a new systemd loop. |
| `gap-plan-pending-security-research-sec-r2-tier5-gap-exploit` | `plan_debt` | Patched → backlog (`sec-r2`). Links httpd tier5 / `nginx_mitigations.toml` exploit rows. |
| `gap-plan-pending-security-research-sec-r3-runtime-surface` | `plan_debt` | Patched → backlog (`sec-r3`). Runtime parse/crypto/HTTP; ASan slice. |
| CWE Top 25 missing in catalog (19) | catalog hygiene | **Human-gated** expansion of `lic/security/cve-catalog.json`. Briefing P0 → `security_auditor`; do not auto-merge catalog rows without review. |
| `gap-infra-verticals-toml-missing-benchmarks-main` | `competitor_feature` | Blocks vertical security stub ingest until benchmarks catalog honesty PRs land on `main`. |

**Runner state:** `security-research` supervisor **off** (~4.6d idle); `sec-r0-cwe-delta` completed; `sec-r1` last attempt exit 1 (gates OK). Re-enable via agents control plane / `offensive_security` research goal — **not** `install-goal-plan-loop-systemd.sh`.

## Control-plane fixes (this pass)

1. **`lic/scripts/swarm-gap-ingest.py`** — fix `verticals.toml` Path fallback (L229 syntax + `BENCHMARKS_COMPETITIVE` default → `BENCHMARKS/competitive` with workloads fallback).
2. **Org-research image** — bake `python3-yaml` so `swarm-gap-apply-actions.py` runs without apt on every tick (recurring failure in prior observer runs).
3. **`li-cursor-agents`** — heap should enqueue `security_auditor` when briefing cites CWE P0 (compact briefing recommends it; heap currently only schedules `ci_maintainer`).
4. **Quality grader** — set `runs_dir` to `/app/data/runs` (or mount path) so `swarm_execution` is not scored with `runs_sampled: 0`.

## Handoffs (existing agent ids only)

- `security_auditor` → `offensive_security` / `sec-r1-httpd-fuzz-smoke`
- `ci_maintainer` → 3 repos missing CI on main + benchmarks metrics PR CI
- `gap_explorer` → registry pressure (62 open gaps post-apply)
- `plan_verifier` → re-enable `plan_audit` preflight (currently `--skip-slow`)

## Deferred

- `orch-r3-missing-package-sweep`, `orch-r4-ui-ux-signals` (swarm-observer plan todos)
- Whitepaper publish to `research-findings` (repo not mounted in this Job)
- Supabase MCP / `data/control-plane/latest-report.json` persistence
