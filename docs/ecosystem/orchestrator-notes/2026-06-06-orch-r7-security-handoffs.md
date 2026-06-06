# Orchestrator note — security dimension handoffs (`orch-r7`)

**Date:** 2026-06-06  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `security` · **Worker:** `fffe2637`  
**Run report:** `/app/data/runs/swarm_observer-1780755892210.md`

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (62.6); `unattended_safe: false` |
| Security runner | **Stopped** — `security-research` off since 2026-05-30 |
| Open security plan_debt | **3** (sec-r1, sec-r2, sec-r3) + ph-db wp-n5-security-bench |
| CWE catalog | **19/25** Top25 missing in `cve-catalog.json` |
| Gap prep | Ingest L229 syntax **fixed**; apply **blocked** (PyYAML) |
| Next handoff | `security_auditor` on `offensive_security` → `sec-r1-httpd-fuzz-smoke` |

---

## Security gap reconciliation

| Registry id | Backlog todo | Apply patch (2026-05-31) | Handoff |
|-------------|--------------|--------------------------|---------|
| `gap-plan-pending-security-research-sec-r1-httpd-fuzz-smoke` | `sec-r1-httpd-fuzz-smoke` | pending in `security-research-backlog.md` | `security_auditor` |
| `gap-plan-pending-security-research-sec-r2-tier5-gap-exploit` | `sec-r2-tier5-gap-exploit` | pending | `security_auditor` |
| `gap-plan-pending-security-research-sec-r3-runtime-surface` | `sec-r3-runtime-surface` | pending | `security_auditor` |
| `gap-plan-pending-ph-db-wp-n5-security-bench` | — | deferred (no runner backlog mapping) | `plan_verifier` |

Evidence:

- `lic/data/swarm-gap-registry/registry.yaml` — rows open, `handoff_to: [swarm_observer]` on plan_debt
- `lic/docs/ecosystem/security-research-backlog.md` — sec-r1/2/3 `status: pending`
- `benchmarks/data/latest/swarm-gap-actions.json` — patches @ 2026-05-31T01:45:58Z
- `lic/issues/521` — master-plan-gap security-research supervisor off 4d+

---

## Swarm routing (no new systemd loops)

Per `docs/ecosystem/swarm-architecture.md`, route via research lane goals — **not** `install-goal-plan-loop-systemd.sh`.

| Agent | Goal / trigger | Action |
|-------|----------------|--------|
| `security_auditor` | `offensive_security` (priority 9, cadence 12h) | Execute `sec-r1-httpd-fuzz-smoke` study + gates |
| `security_auditor` | Briefing P0 CWE signal | Map 19 missing Top25 → catalog gap issues (human merge) |
| `plan_verifier` | Briefing weak plan audit | Refresh snapshot; close stale `plan_debt` rows |
| `gap_explorer` | `ecosystem_gaps` | After ingest unblocked — competitor/security infra gaps |
| `ci_maintainer` | 6 repos missing CI | Unblock org_ci_audit when rate limit clears |

**north_star_fit on handoffs:** domain=ecosystem,web; proof-before-perf; no unproved `unsafe` in security harnesses.

---

## Scripts (this run)

```bash
# Fixed L229 syntax; PyYAML still missing in image
cd /workspace/lic
python3 scripts/swarm-gap-ingest.py    # FAIL: PyYAML required
python3 scripts/swarm-gap-apply-actions.py  # FAIL: PyYAML required

cd /workspace/benchmarks
python3 scripts/ecosystem-quality-grade.py   # OK: grade D 62.6
```

---

## Control-plane fixes needed

1. Merge lic PR stack fixing `swarm-gap-ingest.py` (L229) — e.g. #904, #920.
2. Bake `python3-yaml` in org-research Job (`li-cursor-agents` deploy).
3. Persist observer artifacts to `/app/data/control-plane/` on every tick.
4. Enable `security_cwe_audit` preflight when `security_auditor` is recommended.

---

## Deferred

- `orch-r2-competitor-stubs`, `orch-r3-missing-package-sweep`, `orch-r4-ui-ux-signals` (snapshot stale).
- Whitepaper publish to `research-findings` (staging only).
- ph-db security bench (`wp-n5-security-bench`) — no backlog mapping yet.
