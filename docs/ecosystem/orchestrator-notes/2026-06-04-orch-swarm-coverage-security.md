# Orchestrator note — swarm_coverage @ security (2026-06-04)

**Goal:** `swarm_coverage`  
**Dimension:** `security` (worker `57df6e65`)  
**north_star_fit:** ecosystem, ai — secure pillar; proof-before-perf on exploit gates  

## Security gap reconciliation (Mode B)

| Gap id | Kind | Backlog patch | Handoff |
|--------|------|---------------|---------|
| `gap-plan-pending-security-research-sec-r1-httpd-fuzz-smoke` | plan_debt | `security-research-backlog.md` → pending | `security_auditor` via `offensive_security` goal |
| `gap-plan-pending-security-research-sec-r2-tier5-gap-exploit` | plan_debt | same | `security_auditor` |
| `gap-plan-pending-security-research-sec-r3-runtime-surface` | plan_debt | same | `security_auditor` |
| CWE Top 25 catalog delta (19 missing) | catalog | `lic/security/cve-catalog.json` | `security_auditor` + `issue_planner` |

**Evidence:** `/workspace/benchmarks/data/latest/security-cwe-feed.json`, `/workspace/lic/docs/ecosystem/security-research-backlog.md`, `/workspace/benchmarks/data/latest/swarm-gap-actions.json`

## Control-plane blockers fixed this pass

1. **`swarm-gap-ingest.py` syntax error** (line 229) — blocked ingest; repaired Path fallback for `verticals.toml`.
2. **Missing `BENCHMARKS_COMPETITIVE` env** — ingest now defaults to `benchmarks/workloads/competitive`.
3. **PyYAML** — required `python3-yaml` on host; document in supervisor preflight.

## Do not auto-merge

- `trusted.lean` / provability policy changes
- Tier5 exploit expectation downgrades
- Bulk CWE catalog rows without human review

## Next swarm actions (no new registry ids)

1. Enable full preflight (`security_cwe_audit` not `--skip-slow`) on supervisor ticks.
2. Dispatch `security_auditor` for `sec-r1` (httpd fuzz smoke) — unblocks tier5 parity narrative.
3. Route `offensive_security` whitepaper to `research-findings/whitepapers/2026-06/offensive_security/sec-r1-httpd-fuzz-smoke/`.
4. Human: extend `cve-catalog.json` for Top 25 gaps (19 CWEs) — governance PR.

## Registry apply (2026-06-04T05:47:48Z)

- Ingest + apply ran after script repair.
- Open gaps: **62** (was 64 stale snapshot).
- `verticals_stubs`: 0 new (file present at `benchmarks/workloads/competitive/verticals.toml`).
