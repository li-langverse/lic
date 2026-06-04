# Orchestrator note — `swarm_coverage` @ security dimension

**Date:** 2026-06-04  
**Agent:** `swarm_observer` (worker `0ce8605b`)  
**Research goal:** `swarm_coverage` — north_star_fit: ecosystem, ai (secure pillar)  
**Dimension:** `security`

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (64.8); `unattended_safe: false` |
| Security P0 | **19** MITRE Top25 CWEs missing from `lic/security/cve-catalog.json` |
| Security backlog | `sec-r1` / `sec-r2` / `sec-r3` **pending** in `security-research-backlog.md` |
| Gap pipeline | **Green** after ingest syntax fix + `python3-yaml` — 62 open gaps; sec-r rows patched |
| Control plane | **No** `latest-report.json` / `state.json` on this host — programmatic observer idle |
| Next dispatch | `security_auditor` (`offensive_security` goal) → `ci_maintainer` |

---

## Security gap reconcile (Mode B)

| Registry id | `gap_kind` | Backlog / route | Handoff |
|-------------|------------|-----------------|---------|
| `gap-plan-pending-security-research-sec-r1-httpd-fuzz-smoke` | `plan_debt` | `security-research-backlog.md` → pending | `security_auditor` via `offensive_security` |
| `gap-plan-pending-security-research-sec-r2-tier5-gap-exploit` | `plan_debt` | same | `security_auditor` |
| `gap-plan-pending-security-research-sec-r3-runtime-surface` | `plan_debt` | same | `security_auditor` |
| CWE Top25 delta (19 missing) | catalog hygiene | `benchmarks/data/latest/security-cwe-feed.json` | `security_auditor` — **human-gated** catalog PR |

**Do not** install `security-research` systemd plan loop — route through `config/research-goals.yaml` → `offensive_security` / `security_auditor`.

Evidence:

- `benchmarks/data/latest/security-cwe-feed.json` (`top25_missing_in_catalog=19`)
- `lic/docs/ecosystem/security-research-backlog.md` (sec-r1..r3 `status: pending`)
- `benchmarks/data/latest/swarm-gap-actions.json` @ 2026-06-04T16:14:17Z

---

## Scripts executed

```bash
export BENCHMARKS_COMPETITIVE=/workspace/benchmarks/competitive
cd /workspace/lic
# Fixed swarm-gap-ingest.py L229 Path fallback (unterminated string)
apt-get install -y python3-yaml
python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py
cd /workspace/benchmarks && python3 scripts/ecosystem-quality-grade.py
```

Registry after ingest: **92** rows ({missing_package: 5, plan_debt: 57, competitor_feature: 30}); apply file reports **62** open.

Studio-ui backlog apply skipped — `lic-studio-ui` plan path not mounted (expected in org-research Job).

---

## Control-plane / orchestration fixes (no product code)

1. **li-cursor-agents:** Bake `python3-yaml` in org-research image; set `LI_CURSOR_AGENTS_ROOT=/app` for grader `runs_dir`.
2. **li-cursor-agents:** Persist `data/control-plane/{state,latest-report}.json` on supervisor tick when Supabase down.
3. **li-cursor-agents:** Heap must enqueue `security_auditor` when briefing P0 matches CWE feed (not only `ci_maintainer`).
4. **lic:** Merge `swarm-gap-ingest.py` Path fix to `main` (blocks recurring ingest failures).
5. **benchmarks:** Unblock PH-5b catalog honesty PR stack (#329–#346) before more metrics churn.

---

## Human-only blockers

- Map **19 CWE** rows into `cve-catalog.json` (governance / sec review).
- Merge wave: **32** CI-failing open PRs (mostly `benchmarks` catalog stack).
- `trusted.lean` — no agent edits.

---

## Whitepaper staging

`lic/docs/research/swarm_coverage/security/2026-06-04-whitepaper.md` — publish to `research-findings/whitepapers/2026-06/swarm_coverage/security/` when repo mounted.
